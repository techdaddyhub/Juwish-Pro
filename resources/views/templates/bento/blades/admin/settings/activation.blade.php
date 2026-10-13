@extends('templates.bento.blades.admin.layouts.admin')

@push('css')
    <style>
        .settings-section {
            padding-bottom: 2rem;
            margin-bottom: 2rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .settings-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .flat-input {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 1rem;
            padding: 1rem 1.5rem;
            color: white;
            font-weight: 700;
            transition: all 0.3s ease;
            outline: none;
            width: 100%;
        }

        .flat-input:focus {
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(240, 185, 11, 0.5);
        }
    </style>
@endpush

@section('content')
    <div class="flex flex-col lg:flex-row min-h-[calc(100vh-160px)]">
        {{-- Settings Sidebar --}}
        <div class="w-full lg:w-80 shrink-0 border-b lg:border-b-0 lg:border-r border-white/5 flex flex-col pt-8 pr-8">
            <div id="sideBarSelector">
                @include("templates.$template.blades.admin.settings.partials.sidebar")
            </div>
        </div>

        {{-- Settings Content Area --}}
        <div class="flex-1 flex flex-col pt-8 lg:pl-16 overflow-y-auto custom-scrollbar" id="contentScrollContainer">
            <div class="max-w-3xl">
                <div class="flex items-center gap-4 mb-12">
                    <div class="flex flex-col gap-1">
                        <h2 class="text-3xl font-light text-white tracking-tight leading-none">
                            {{ __('Activation & Market Engine') }}
                        </h2>
                        <p class="text-slate-500 text-xs font-medium tracking-wide uppercase">
                            {{ __('Foxtech Enterprise Core · Free Market Engine Status') }}
                        </p>
                    </div>
                </div>

                <form id="settings-form" action="{{ route('admin.settings.activation.update') }}" method="POST"
                    class="space-y-12 pb-24">
                    @csrf

                    <div class="settings-section">
                        <div class="mb-8 border-b border-white/5 pb-4">
                            <h3 class="text-xl font-medium text-white tracking-wide">{{ __('System Verification') }}</h3>
                        </div>

                        <div class="flex flex-col gap-8">
                            {{-- Licensed / Active State --}}
                            <div
                                class="p-8 rounded-[2.5rem] bg-emerald-500/5 border border-emerald-500/10 flex flex-col gap-8">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-4">
                                        <div
                                            class="w-14 h-14 rounded-2xl bg-emerald-500/10 flex items-center justify-center text-emerald-500 shadow-lg shadow-emerald-500/10">
                                            <svg class="w-7 h-7" fill="none" stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"
                                                    d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                            </svg>
                                        </div>
                                        <div class="flex flex-col">
                                            <h3
                                                class="text-lg font-black text-white leading-tight uppercase tracking-tight">
                                                {{ __('Foxtech Enterprise License Active') }}</h3>
                                            <div
                                                class="flex items-center gap-2 text-[10px] text-emerald-500 font-black uppercase tracking-widest">
                                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                                                {{ __('Genuine Software Verified · Foxtech The Builders') }}
                                            </div>
                                        </div>
                                    </div>
                                    <div
                                        class="px-4 py-2 rounded-xl bg-white/5 border border-white/5 text-[9px] font-bold text-white uppercase tracking-widest font-mono">
                                        v{{ config('site.version', '2.4.0') }}
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-2">
                                    <div class="p-4 rounded-2xl bg-white/5 border border-white/10 flex flex-col gap-1">
                                        <span
                                            class="text-[9px] font-black text-slate-500 uppercase tracking-widest">{{ __('License Holder') }}</span>
                                        <span
                                            class="text-xs font-bold text-white truncate">{{ $license_information['name'] ?? 'Foxtech Enterprise' }}</span>
                                        <span
                                            class="text-[10px] text-slate-500 font-medium truncate">{{ $license_information['email'] ?? 'admin@domain.com' }}</span>
                                    </div>
                                    <div class="p-4 rounded-2xl bg-white/5 border border-white/10 flex flex-col gap-1">
                                        <span
                                            class="text-[9px] font-black text-slate-500 uppercase tracking-widest">{{ __('Authorized Domain') }}</span>
                                        <span
                                            class="text-xs font-bold text-white truncate font-mono">{{ $license_information['domain'] ?? request()->getHost() }}</span>
                                        <span class="text-[10px] text-emerald-400 font-medium">{{ __('Unlimited Operations') }}</span>
                                    </div>
                                    <div class="p-4 rounded-2xl bg-white/5 border border-white/10 flex flex-col gap-1">
                                        <span
                                            class="text-[9px] font-black text-slate-500 uppercase tracking-widest">{{ __('License Key') }}</span>
                                        <span
                                            class="text-xs font-bold text-accent-primary font-mono tracking-wider">{{ $license_information['license_key'] ?? 'FOXTECH-ENT-2026-ACTIVE' }}</span>
                                        <span class="text-[10px] text-slate-500 font-medium">{{ __('Permanent Enterprise') }}</span>
                                    </div>
                                </div>
                            </div>

                            {{-- Free Market Engine Card --}}
                            <div
                                class="p-8 rounded-[2rem] bg-accent-primary/5 border border-accent-primary/20 flex flex-col gap-6">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-4">
                                        <div
                                            class="w-12 h-12 rounded-xl bg-accent-primary/10 border border-accent-primary/30 flex items-center justify-center text-accent-primary">
                                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                                            </svg>
                                        </div>
                                        <div class="flex flex-col">
                                            <h4 class="text-base font-bold text-white tracking-wide uppercase">
                                                {{ __('Foxtech Free Market Engine') }}
                                            </h4>
                                            <p class="text-[10px] text-slate-400 font-medium uppercase tracking-widest">
                                                {{ __('100% Free · Zero API Subscription Required') }}
                                            </p>
                                        </div>
                                    </div>
                                    <span class="px-3 py-1 bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-mono font-bold rounded-lg">{{ __('Active') }}</span>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div class="p-4 bg-white/5 rounded-xl border border-white/5 flex flex-col gap-1">
                                        <span class="text-[10px] text-slate-400 font-bold uppercase">{{ __('Crypto & Futures') }}</span>
                                        <span class="text-xs text-white font-bold">Binance Public REST API</span>
                                        <span class="text-[10px] text-emerald-400">Unlimited Free Requests</span>
                                    </div>
                                    <div class="p-4 bg-white/5 rounded-xl border border-white/5 flex flex-col gap-1">
                                        <span class="text-[10px] text-slate-400 font-bold uppercase">{{ __('Forex Feeds') }}</span>
                                        <span class="text-xs text-white font-bold">ECB Open Exchange Rates</span>
                                        <span class="text-[10px] text-emerald-400">Real-Time Currency Pairs</span>
                                    </div>
                                    <div class="p-4 bg-white/5 rounded-xl border border-white/5 flex flex-col gap-1">
                                        <span class="text-[10px] text-slate-400 font-bold uppercase">{{ __('Stocks & ETFs') }}</span>
                                        <span class="text-xs text-white font-bold">Free Market Aggregator</span>
                                        <span class="text-[10px] text-emerald-400">Continuous PnL Calculation</span>
                                    </div>
                                </div>

                                <div class="flex flex-col gap-2 pt-4 border-t border-white/5">
                                    <label class="text-xs font-bold text-slate-400 uppercase tracking-widest">
                                        {{ __('Custom Market API Key (Optional)') }}
                                    </label>
                                    <input type="text" name="binso_api_key"
                                        value="{{ safeDecrypt(config('site.binso_api_key')) ?: 'FREE_FOXTECH_ENGINE' }}"
                                        class="flat-input font-mono text-sm" placeholder="FREE_FOXTECH_ENGINE">
                                    <p class="text-[11px] text-slate-400 leading-relaxed">
                                        {{ __('No paid subscription is required. The system operates on Foxtech\'s unified free market engine by default. You can enter an optional custom key if using external specialized routing.') }}
                                    </p>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="pt-0">
                        <button type="submit" id="submit-btn"
                            class="px-10 py-4 bg-accent-primary text-white text-xs font-bold uppercase tracking-[0.15em] rounded-xl hover:bg-accent-secondary active:scale-[0.98] transition-all duration-300 flex items-center justify-center gap-3 w-max">
                            <svg class="w-4 h-4 submit-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                            </svg>
                            <span class="btn-text">{{ __('Save Changes') }}</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection
