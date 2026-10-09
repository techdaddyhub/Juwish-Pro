<?php

namespace App\Http\Controllers;

use App\Model\Coin;
use App\Model\CoinPair;
use App\Model\Wallet;
use App\Model\WalletAddressHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class UserPortalController extends Controller
{
    const JWC_CONTRACT = '0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99';

    public function index(Request $request)
    {
        $data['title'] = 'JuwishPro - Smart Crypto Exchange & PancakeSwap JWC Gateway';
        $data['app_title'] = settings('app_title') ?: 'JuwishPro';
        $data['logo'] = show_image(1, 'logo');
        $data['jwc_contract'] = self::JWC_CONTRACT;
        $data['pancakeswap_url'] = 'https://pancakeswap.finance/swap?outputCurrency=' . self::JWC_CONTRACT . '&chainId=56';

        // Load active coins
        $data['coins'] = Coin::where('status', STATUS_ACTIVE)->get();
        $data['jwc_coin'] = Coin::where('coin_type', 'JWC')->first();

        // User balance and deposit address if logged in
        $data['user'] = Auth::user();
        $data['jwc_balance'] = 0;
        $data['user_deposit_address'] = '';

        if ($data['user']) {
            $jwcWallet = Wallet::where(['user_id' => $data['user']->id, 'coin_type' => 'JWC'])->first();
            if ($jwcWallet) {
                $data['jwc_balance'] = (float)$jwcWallet->balance;
                $addressHistory = WalletAddressHistory::where('wallet_id', $jwcWallet->id)->first();
                if ($addressHistory) {
                    $data['user_deposit_address'] = $addressHistory->address;
                }
            }
        }

        return view('user_portal.index', $data);
    }
}
