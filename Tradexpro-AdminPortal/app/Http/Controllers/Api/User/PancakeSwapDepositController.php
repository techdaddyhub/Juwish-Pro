<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Model\Coin;
use App\Model\DepositeTransaction;
use App\Model\Wallet;
use App\Model\WalletAddressHistory;
use App\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PancakeSwapDepositController extends Controller
{
    const JWC_CONTRACT = '0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99';
    const TRANSFER_TOPIC = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
    const BSC_RPC_URLS = [
        'https://bsc-dataseed.binance.org',
        'https://bsc-dataseed1.defibit.io',
        'https://bsc-dataseed1.ninicoin.io',
        'https://rpc.ankr.com/bsc'
    ];

    /**
     * Get PancakeSwap Integration Configuration
     */
    public function getInfo(Request $request)
    {
        $jwcCoin = Coin::where('coin_type', 'JWC')->first();
        $user = Auth::guard('api')->user() ?: Auth::user();
        
        $depositAddress = '';
        if ($user) {
            $wallet = Wallet::where(['user_id' => $user->id, 'coin_type' => 'JWC'])->first();
            if ($wallet) {
                $addressHistory = WalletAddressHistory::where('wallet_id', $wallet->id)->first();
                if ($addressHistory) {
                    $depositAddress = $addressHistory->address;
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'token_name' => 'JuwishCoin',
                'token_symbol' => 'JWC',
                'token_decimals' => 18,
                'token_contract' => self::JWC_CONTRACT,
                'chain_id' => 56,
                'network' => 'BNB Smart Chain (BSC)',
                'pancakeswap_url' => 'https://pancakeswap.finance/swap?outputCurrency=' . self::JWC_CONTRACT . '&chainId=56',
                'pancakeswap_router' => '0x10ED43C718714eb63d5aA57B78B54704E256024E',
                'current_price_usd' => $jwcCoin ? (float)$jwcCoin->coin_price : 0.05,
                'user_deposit_address' => $depositAddress
            ]
        ]);
    }

    /**
     * Verify on-chain PancakeSwap deposit and credit balance automatically
     */
    public function verifyDeposit(Request $request)
    {
        $request->validate([
            'tx_hash' => 'required|string|regex:/^0x[a-fA-F0-9]{64}$/'
        ]);

        $txHash = strtolower(trim($request->input('tx_hash')));

        // Check if transaction already credited
        $existing = DepositeTransaction::where('transaction_id', $txHash)->first();
        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => __('This transaction hash has already been credited to a wallet.'),
                'data' => [
                    'transaction_id' => $txHash,
                    'amount' => (float)$existing->amount,
                    'status' => 'already_credited'
                ]
            ], 422);
        }

        // Query BNB Smart Chain RPC for transaction receipt
        $receipt = $this->fetchBscReceipt($txHash);
        if (!$receipt) {
            return response()->json([
                'success' => false,
                'message' => __('Transaction was not found or has not been confirmed yet on BNB Smart Chain. Please wait a few seconds and retry.')
            ], 404);
        }

        // Check if transaction succeeded
        $status = hexdec($receipt['status'] ?? '0x0');
        if ($status !== 1) {
            return response()->json([
                'success' => false,
                'message' => __('The on-chain transaction failed or was reverted by the blockchain.')
            ], 400);
        }

        // Parse transfer logs for JWC BEP-20 token
        $transfers = $this->parseJwcTransfers($receipt['logs'] ?? []);
        if (empty($transfers)) {
            return response()->json([
                'success' => false,
                'message' => __('No valid JuwishCoin (JWC) transfer was detected in this transaction.')
            ], 400);
        }

        // Determine destination user and wallet
        $user = Auth::guard('api')->user() ?: Auth::user();
        $targetTransfer = null;
        $targetWallet = null;

        // Try to match transfer recipient with user's deposit address
        foreach ($transfers as $transfer) {
            $matchedAddress = WalletAddressHistory::where('address', $transfer['to'])
                ->where('coin_type', 'JWC')
                ->first();

            if ($matchedAddress) {
                $targetWallet = Wallet::find($matchedAddress->wallet_id);
                $targetTransfer = $transfer;
                break;
            }
        }

        // If not matched by dedicated address, attribute to authenticated user's JWC wallet
        if (!$targetWallet && $user) {
            $targetWallet = Wallet::firstOrCreate(
                ['user_id' => $user->id, 'coin_type' => 'JWC'],
                ['name' => 'JWC Wallet', 'balance' => 0]
            );
            $targetTransfer = $transfers[count($transfers) - 1]; // Latest transfer in swap
        }

        // If guest user without auth, fallback to admin user or first active user
        if (!$targetWallet) {
            $firstUser = User::where('role', USER_ROLE_ADMIN)->first() ?: User::first();
            if ($firstUser) {
                $targetWallet = Wallet::firstOrCreate(
                    ['user_id' => $firstUser->id, 'coin_type' => 'JWC'],
                    ['name' => 'JWC Wallet', 'balance' => 0]
                );
                $targetTransfer = $transfers[count($transfers) - 1];
            }
        }

        if (!$targetWallet || !$targetTransfer) {
            return response()->json([
                'success' => false,
                'message' => __('Unable to link deposit to an account. Please log in before verifying.')
            ], 403);
        }

        $creditedAmount = $targetTransfer['amount'];

        DB::beginTransaction();
        try {
            // Record deposit
            $deposit = DepositeTransaction::create([
                'address' => $targetTransfer['to'],
                'from_address' => $targetTransfer['from'],
                'receiver_wallet_id' => $targetWallet->id,
                'address_type' => ADDRESS_TYPE_EXTERNAL,
                'coin_type' => 'JWC',
                'amount' => $creditedAmount,
                'transaction_id' => $txHash,
                'status' => STATUS_SUCCESS,
                'confirmations' => 15
            ]);

            // Increment user wallet balance
            $targetWallet->increment('balance', $creditedAmount);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => __("PancakeSwap deposit successful! Credited :amount JWC to your balance.", ['amount' => number_format($creditedAmount, 4)]),
                'data' => [
                    'amount' => $creditedAmount,
                    'coin_type' => 'JWC',
                    'tx_hash' => $txHash,
                    'new_balance' => (float)$targetWallet->fresh()->balance,
                    'deposit_id' => $deposit->id
                ]
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('PancakeSwap Deposit Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => __('Failed to credit deposit: ') . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Query BSC RPC for transaction receipt
     */
    private function fetchBscReceipt(string $txHash): ?array
    {
        foreach (self::BSC_RPC_URLS as $rpcUrl) {
            try {
                $ch = curl_init($rpcUrl);
                curl_setopt_array($ch, [
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_POST => true,
                    CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
                    CURLOPT_TIMEOUT => 6,
                    CURLOPT_POSTFIELDS => json_encode([
                        'jsonrpc' => '2.0',
                        'method' => 'eth_getTransactionReceipt',
                        'params' => [$txHash],
                        'id' => 1
                    ])
                ]);
                $response = curl_exec($ch);
                curl_close($ch);

                if ($response) {
                    $json = json_decode($response, true);
                    if (isset($json['result']) && is_array($json['result'])) {
                        return $json['result'];
                    }
                }
            } catch (\Exception $e) {
                continue;
            }
        }
        return null;
    }

    /**
     * Parse Transfer events from transaction logs
     */
    private function parseJwcTransfers(array $logs): array
    {
        $transfers = [];
        foreach ($logs as $log) {
            $address = strtolower($log['address'] ?? '');
            $topics = $log['topics'] ?? [];

            if ($address === self::JWC_CONTRACT && !empty($topics) && strtolower($topics[0]) === self::TRANSFER_TOPIC) {
                $from = '0x' . substr($topics[1] ?? '', 26);
                $to = '0x' . substr($topics[2] ?? '', 26);
                $rawHex = $log['data'] ?? '0x0';
                $valueDec = hexdec($rawHex);
                $amount = $valueDec / 1e18;

                if ($amount > 0) {
                    $transfers[] = [
                        'from' => strtolower($from),
                        'to' => strtolower($to),
                        'amount' => (float)$amount
                    ];
                }
            }
        }
        return $transfers;
    }
}
