@extends('templates.bento.blades.admin.layouts.admin')

@section('content')
    <div
        class="bg-secondary/40 border border-white/5 rounded-[2.5rem] shadow-2xl overflow-hidden flex flex-col lg:flex-row backdrop-blur-xl min-h-[calc(100vh-160px)]">
        {{-- Settings Sidebar --}}
        <div
            class="w-full lg:w-80 bg-secondary/60 shrink-0 border-b lg:border-b-0 lg:border-r border-white/5 flex flex-col relative group">
            <div
                class="absolute inset-0 bg-gradient-to-b from-accent-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
            </div>
            <div class="relative z-10 flex-1 py-8 px-6 lg:px-8 overflow-y-auto custom-scrollbar">
                @include("templates.$template.blades.admin.settings.partials.sidebar")
            </div>
        </div>

        {{-- Settings Content --}}
        <div class="flex-1 p-6 md:p-10 lg:p-12 space-y-8 overflow-y-auto custom-scrollbar">

            {{-- Foxtech Architecture Banner --}}
            <div
                class="bg-secondary relative border border-accent-primary/30 rounded-3xl p-8 overflow-hidden flex flex-col md:flex-row items-start md:items-center justify-between gap-6 shadow-2xl">
                <div class="absolute inset-0 bg-gradient-to-r from-accent-primary/10 via-transparent to-transparent pointer-events-none z-0">
                </div>
                <div class="relative z-10 flex items-center gap-5">
                    <div
                        class="w-16 h-16 rounded-2xl bg-accent-primary/15 border border-accent-primary/30 flex items-center justify-center text-accent-primary shrink-0 shadow-[0_0_20px_rgba(240,185,11,0.2)]">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                        </svg>
                    </div>
                    <div>
                        <div class="flex items-center gap-3 mb-1">
                            <h3 class="text-2xl font-bold text-white tracking-tight">{{ __('Foxtech Enterprise Core') }}</h3>
                            <span class="px-2.5 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase tracking-wider">{{ __('Active') }}</span>
                        </div>
                        <p class="text-xs text-text-secondary leading-relaxed max-w-xl">
                            {{ __('Engineered by Foxtech (the builders of this software). Real-time financial execution engine, multi-platform synchronized clients, and autonomous institutional infrastructure.') }}
                        </p>
                    </div>
                </div>
                <div class="relative z-10 flex flex-col md:items-end gap-1 shrink-0">
                    <span class="text-[10px] font-mono text-text-secondary uppercase tracking-widest">{{ __('Engine Version') }}</span>
                    <span class="text-xl font-mono font-bold text-white">v{{ config('site.version', '2.4.0') }}</span>
                    <span class="text-[10px] text-emerald-400 font-medium flex items-center gap-1.5 mt-1">
                        <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                        {{ __('All Services Operational') }}
                    </span>
                </div>
            </div>

            {{-- System Telemetry Grid --}}
            <div>
                <h4 class="text-xs font-mono font-bold text-text-secondary uppercase tracking-widest mb-4">
                    {{ __('Integrated Engine Telemetry') }}
                </h4>
                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">

                    {{-- 1. Free Market Engine --}}
                    <div class="bg-secondary-dark/60 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-accent-primary/30 transition-all">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-accent-primary/10 border border-accent-primary/20 flex items-center justify-center text-accent-primary">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                                </svg>
                            </div>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase">{{ __('Active · Free') }}</span>
                        </div>
                        <h5 class="text-base font-bold text-white mb-1">{{ __('Foxtech Free Market Feed') }}</h5>
                        <p class="text-xs text-text-secondary leading-relaxed mb-4">
                            {{ __('Binance Public REST API, Frankfurter ECB rates, and autonomous high-availability ticker engines. Zero subscription fees required.') }}
                        </p>
                        <div class="pt-3 border-t border-white/5 flex items-center justify-between text-[11px] font-mono text-text-secondary">
                            <span>{{ __('Feed Latency') }}</span>
                            <span class="text-emerald-400 font-bold">&lt; 120ms</span>
                        </div>
                    </div>

                    {{-- 2. Futures & Margins Trading Engine --}}
                    <div class="bg-secondary-dark/60 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-accent-primary/30 transition-all">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                                </svg>
                            </div>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase">{{ __('Operational') }}</span>
                        </div>
                        <h5 class="text-base font-bold text-white mb-1">{{ __('Futures & Margin Engine') }}</h5>
                        <p class="text-xs text-text-secondary leading-relaxed mb-4">
                            {{ __('Continuous order matching, automated TP/SL execution, leverage risk manager, and automated liquidation protection.') }}
                        </p>
                        <div class="pt-3 border-t border-white/5 flex items-center justify-between text-[11px] font-mono text-text-secondary">
                            <span>{{ __('Cron Manager') }}</span>
                            <span class="text-emerald-400 font-bold">{{ __('Running (1m)') }}</span>
                        </div>
                    </div>

                    {{-- 3. Forex Engine --}}
                    <div class="bg-secondary-dark/60 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-accent-primary/30 transition-all">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            </div>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase">{{ __('Operational') }}</span>
                        </div>
                        <h5 class="text-base font-bold text-white mb-1">{{ __('Forex Trading Server') }}</h5>
                        <p class="text-xs text-text-secondary leading-relaxed mb-4">
                            {{ __('Global currency pair feeds, real-time bid/ask spread routing, demo & live account isolation, and instant position closing.') }}
                        </p>
                        <div class="pt-3 border-t border-white/5 flex items-center justify-between text-[11px] font-mono text-text-secondary">
                            <span>{{ __('Server Cluster') }}</span>
                            <span class="text-white font-bold">London-Pro-1</span>
                        </div>
                    </div>

                    {{-- 4. Stocks, ETFs & Bonds --}}
                    <div class="bg-secondary-dark/60 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-accent-primary/30 transition-all">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase">{{ __('Operational') }}</span>
                        </div>
                        <h5 class="text-base font-bold text-white mb-1">{{ __('Capital Instruments Engine') }}</h5>
                        <p class="text-xs text-text-secondary leading-relaxed mb-4">
                            {{ __('Fractional stock investments, ETF portfolio tracking, automated PnL updates, and Treasury/Corporate bond maturity scheduler.') }}
                        </p>
                        <div class="pt-3 border-t border-white/5 flex items-center justify-between text-[11px] font-mono text-text-secondary">
                            <span>{{ __('PnL Recalculator') }}</span>
                            <span class="text-emerald-400 font-bold">{{ __('Active') }}</span>
                        </div>
                    </div>

                    {{-- 5. Native Clients Suite --}}
                    <div class="bg-secondary-dark/60 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-accent-primary/30 transition-all">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase">{{ __('Built · 8 Apps') }}</span>
                        </div>
                        <h5 class="text-base font-bold text-white mb-1">{{ __('Native Mobile & Desktop Apps') }}</h5>
                        <p class="text-xs text-text-secondary leading-relaxed mb-4">
                            {{ __('Dedicated Client and Admin apps compiled for Android (APK), Windows (.exe), macOS (Universal), and iOS (.ipa). Synced with live platform.') }}
                        </p>
                        <div class="pt-3 border-t border-white/5 flex items-center justify-between text-[11px] font-mono text-text-secondary">
                            <span>{{ __('Platform Sync') }}</span>
                            <span class="text-emerald-400 font-bold">100% Synced</span>
                        </div>
                    </div>

                    {{-- 6. Social Auth & Security --}}
                    <div class="bg-secondary-dark/60 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-accent-primary/30 transition-all">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-10 h-10 rounded-xl bg-cyan-500/10 border border-cyan-500/20 flex items-center justify-center text-cyan-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.153-2.05-.438-3.016z" />
                                </svg>
                            </div>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono font-bold uppercase">{{ __('Active') }}</span>
                        </div>
                        <h5 class="text-base font-bold text-white mb-1">{{ __('Authentication & Social OAuth') }}</h5>
                        <p class="text-xs text-text-secondary leading-relaxed mb-4">
                            {{ __('Google & Twitter (X) single-click registration, Email OTP verification, biometric unlock token handler, and Laravel Sanctum API security.') }}
                        </p>
                        <div class="pt-3 border-t border-white/5 flex items-center justify-between text-[11px] font-mono text-text-secondary">
                            <span>{{ __('OAuth Providers') }}</span>
                            <span class="text-white font-bold">{{ __('Google, Twitter (X)') }}</span>
                        </div>
                    </div>

                </div>
            </div>

            {{-- Quick Administration Navigation --}}
            <div class="pt-6 border-t border-white/5">
                <h4 class="text-xs font-mono font-bold text-text-secondary uppercase tracking-widest mb-4">
                    {{ __('Quick Configuration Shortcuts') }}
                </h4>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3">
                    <a href="{{ route('admin.settings.financial') }}" class="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/5 transition-all text-center group">
                        <span class="text-xs font-bold text-white block group-hover:text-accent-primary transition-colors">{{ __('Financial') }}</span>
                        <span class="text-[10px] text-text-secondary font-mono">{{ __('Fees & Limits') }}</span>
                    </a>
                    <a href="{{ route('admin.settings.activation') }}" class="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/5 transition-all text-center group">
                        <span class="text-xs font-bold text-white block group-hover:text-accent-primary transition-colors">{{ __('Activation') }}</span>
                        <span class="text-[10px] text-text-secondary font-mono">{{ __('Market Feeds') }}</span>
                    </a>
                    <a href="{{ route('admin.settings.cronjob') }}" class="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/5 transition-all text-center group">
                        <span class="text-xs font-bold text-white block group-hover:text-accent-primary transition-colors">{{ __('Cron Jobs') }}</span>
                        <span class="text-[10px] text-text-secondary font-mono">{{ __('Schedulers') }}</span>
                    </a>
                    <a href="{{ route('admin.settings.deposit.index') }}" class="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/5 transition-all text-center group">
                        <span class="text-xs font-bold text-white block group-hover:text-accent-primary transition-colors">{{ __('Deposits') }}</span>
                        <span class="text-[10px] text-text-secondary font-mono">{{ __('Gateways') }}</span>
                    </a>
                    <a href="{{ route('admin.settings.withdrawal.index') }}" class="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/5 transition-all text-center group">
                        <span class="text-xs font-bold text-white block group-hover:text-accent-primary transition-colors">{{ __('Withdrawals') }}</span>
                        <span class="text-[10px] text-text-secondary font-mono">{{ __('Payout Methods') }}</span>
                    </a>
                    <a href="{{ route('admin.settings.security') }}" class="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/5 transition-all text-center group">
                        <span class="text-xs font-bold text-white block group-hover:text-accent-primary transition-colors">{{ __('Security') }}</span>
                        <span class="text-[10px] text-text-secondary font-mono">{{ __('2FA & Session') }}</span>
                    </a>
                </div>
            </div>

        </div>
    </div>
@endsection
