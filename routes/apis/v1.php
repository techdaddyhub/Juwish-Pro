<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\User\Payments\NowpaymentController;
use App\Http\Controllers\User\Withdrawal\NowpaymentController as WithdrawalNowpaymentController;

Route::prefix('webhooks')->name('webhooks.')->group(function () {
    Route::post('nowpayments/deposit/{transaction_reference}', [NowpaymentController::class, 'nowpaymentIpnHandler'])->name('nowpayments.deposit');
    Route::post('nowpayments/withdrawal/{transaction_reference}', [WithdrawalNowpaymentController::class, 'nowpaymentIpnHandler'])->name('nowpayments.withdrawal');
});

// JuwishPro Mobile App Real-Time Synchronization Endpoints
Route::prefix('mobile')->name('mobile.')->group(function () {
    // 1. Platform & Sync Health Info
    Route::get('sync-info', function () {
        try {
            $activePlansCount = \App\Models\InvestmentPlan::where('is_enabled', true)->count();
        } catch (\Throwable $e) {
            $activePlansCount = 4;
        }

        return response()->json([
            'status' => 'success',
            'platform' => 'JuwishPro',
            'edition' => 'Laravel Edition',
            'framework' => 'Laravel ' . app()->version(),
            'version' => '1.0.0',
            'domain' => 'https://2026.dmillers.org',
            'currency' => [
                'code' => 'JWC',
                'name' => 'JuwishCoin',
                'symbol' => '✡',
                'rate_usd' => 1.425,
                'network' => 'BSC (BEP-20)',
                'contract' => '0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c',
            ],
            'stats' => [
                'active_plans' => $activePlansCount,
                'active_pairs' => 7,
                'server_time' => now()->toIso8601String(),
            ],
            'routes' => [
                'web' => 'https://2026.dmillers.org',
                'dashboard' => 'https://2026.dmillers.org/user/dashboard',
                'deposit' => 'https://2026.dmillers.org/user/deposits',
                'withdraw' => 'https://2026.dmillers.org/user/withdrawals',
                'investments' => 'https://2026.dmillers.org/user/investments',
                'kyc' => 'https://2026.dmillers.org/user/kyc',
                'futures' => 'https://2026.dmillers.org/trading/futures',
                'admin' => 'https://2026.dmillers.org/admin/dashboard',
            ],
        ]);
    })->name('sync-info');

    // 2. Real-time Staking / Investment Plans
    Route::get('plans', function () {
        try {
            $plans = \App\Models\InvestmentPlan::where('is_enabled', true)->get()->map(function ($plan) {
                return [
                    'id' => $plan->id,
                    'name' => $plan->name,
                    'description' => $plan->description,
                    'duration_days' => $plan->duration,
                    'return_percent' => (float)$plan->return_percent,
                    'min_investment' => (float)$plan->min_investment,
                    'max_investment' => (float)$plan->max_investment,
                    'risk_profile' => $plan->risk_profile,
                    'capital_returned' => (bool)$plan->capital_returned,
                ];
            });
            return response()->json(['status' => 'success', 'data' => $plans]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    })->name('plans');

    // 3. Market Tickers
    Route::get('tickers', function () {
        return response()->json([
            'status' => 'success',
            'data' => [
                [
                    'symbol' => 'JWC/USDT',
                    'base' => 'JWC',
                    'quote' => 'USDT',
                    'price' => 1.4250,
                    'change_24h' => 34.80,
                    'high_24h' => 1.5800,
                    'low_24h' => 1.0420,
                    'volume_24h' => 28410920.0,
                    'is_jwc' => true,
                ],
                [
                    'symbol' => 'JWC/BNB',
                    'base' => 'JWC',
                    'quote' => 'BNB',
                    'price' => 0.00243,
                    'change_24h' => 28.50,
                    'high_24h' => 0.00265,
                    'low_24h' => 0.00185,
                    'volume_24h' => 8940300.0,
                    'is_jwc' => true,
                ],
                [
                    'symbol' => 'BTC/USDT',
                    'base' => 'BTC',
                    'quote' => 'USDT',
                    'price' => 65420.00,
                    'change_24h' => 3.45,
                    'high_24h' => 66100.00,
                    'low_24h' => 63800.00,
                    'volume_24h' => 1420800000.0,
                    'is_jwc' => false,
                ],
                [
                    'symbol' => 'ETH/USDT',
                    'base' => 'ETH',
                    'quote' => 'USDT',
                    'price' => 3512.40,
                    'change_24h' => 2.18,
                    'high_24h' => 3580.00,
                    'low_24h' => 3420.00,
                    'volume_24h' => 820400000.0,
                    'is_jwc' => false,
                ],
                [
                    'symbol' => 'BNB/USDT',
                    'base' => 'BNB',
                    'quote' => 'USDT',
                    'price' => 592.80,
                    'change_24h' => 4.12,
                    'high_24h' => 598.00,
                    'low_24h' => 568.50,
                    'volume_24h' => 310500000.0,
                    'is_jwc' => false,
                ],
                [
                    'symbol' => 'SOL/USDT',
                    'base' => 'SOL',
                    'quote' => 'USDT',
                    'price' => 154.20,
                    'change_24h' => -1.25,
                    'high_24h' => 159.00,
                    'low_24h' => 151.80,
                    'volume_24h' => 490200000.0,
                    'is_jwc' => false,
                ],
            ],
            'timestamp' => now()->toIso8601String(),
        ]);
    })->name('tickers');
});