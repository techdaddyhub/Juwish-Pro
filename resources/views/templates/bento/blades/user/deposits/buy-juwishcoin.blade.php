@extends('templates.bento.blades.layouts.user')

@section('content')
    <div class="max-w-5xl mx-auto space-y-8">
        
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div class="flex items-center gap-4">
                <a href="{{ route('user.dashboard') }}"
                    class="w-10 h-10 flex items-center justify-center rounded-xl bg-[#181A20] border border-white/10 text-slate-400 hover:text-white hover:bg-white/5 transition-all">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                </a>
                <div>
                    <h2 class="text-2xl sm:text-3xl font-black text-white font-heading tracking-tight flex items-center gap-3">
                        <span>{{ __('Buy JuwishCoin & Deposit') }}</span>
                        <span class="text-xs px-2.5 py-1 rounded-lg bg-[#F0B90B]/15 text-[#FCD535] border border-[#F0B90B]/30 font-mono font-bold">JWC</span>
                    </h2>
                    <p class="text-xs text-slate-400 mt-1">
                        {{ __('Acquire JuwishCoin (JWC) to automatically credit funds to your cash balance at 1:1 USD.') }}
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <div class="px-3.5 py-1.5 rounded-xl bg-[#F0B90B]/10 border border-[#F0B90B]/20 text-[#FCD535] text-xs font-mono font-bold flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-[#F0B90B] animate-pulse"></span>
                    <span>1 JWC = 1.00 USD</span>
                </div>
            </div>
        </div>

        <!-- Terminal Card -->
        <div class="relative bg-gradient-to-br from-[#0B0E11] via-[#12161C] to-[#181A20] border border-[#F0B90B]/30 rounded-3xl p-6 sm:p-10 overflow-hidden shadow-[0_15px_50px_rgba(240,185,11,0.12)]">
            
            {{-- Mesh Overlay --}}
            <div class="absolute inset-0 bg-[url('{{ asset('/assets/images/noise.svg') }}')] opacity-15 pointer-events-none"></div>
            <div class="absolute -top-32 -right-32 w-96 h-96 bg-[#F0B90B]/15 rounded-full blur-3xl pointer-events-none"></div>
            <div class="absolute -bottom-32 -left-32 w-96 h-96 bg-[#FCD535]/10 rounded-full blur-3xl pointer-events-none"></div>

            <div class="relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
                
                <!-- Left Identity & Telemetry -->
                <div class="lg:col-span-5 space-y-6">
                    <div class="text-center lg:text-left">
                        <div class="relative w-28 h-28 mx-auto lg:mx-0 mb-6">
                            <div class="absolute inset-0 bg-gradient-to-tr from-[#F0B90B]/40 to-[#FCD535]/20 rounded-full blur-2xl animate-pulse"></div>
                            <img src="{{ asset('assets/images/juwishcoin.png') }}"
                                alt="JuwishCoin (JWC)"
                                class="w-full h-full object-contain drop-shadow-[0_15px_30px_rgba(240,185,11,0.5)] transform hover:scale-105 transition-transform duration-300">
                        </div>

                        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#F0B90B]/10 border border-[#F0B90B]/30 text-[#FCD535] text-[10px] font-black uppercase tracking-widest mb-3">
                            <span class="w-1.5 h-1.5 rounded-full bg-[#FCD535] animate-ping"></span>
                            {{ __('Instant Account Funding') }}
                        </div>

                        <h3 class="text-3xl font-black text-white tracking-tight">
                            {{ __('JuwishCoin Protocol') }}
                        </h3>
                        <p class="text-slate-400 text-xs mt-2 leading-relaxed">
                            {{ __('Purchasing JuwishCoin is the premier method to deposit capital into your account. Zero deposit fees, guaranteed 1:1 USD peg, and immediate availability across all trading terminals.') }}
                        </p>
                    </div>

                    <!-- Highlights Grid -->
                    <div class="grid grid-cols-3 gap-3">
                        <div class="bg-white/[0.03] border border-white/5 rounded-xl p-3.5 text-center">
                            <span class="text-[9px] text-slate-400 font-bold uppercase tracking-wider block mb-1">{{ __('Peg') }}</span>
                            <span class="text-sm font-mono font-bold text-white">1:1 USD</span>
                        </div>
                        <div class="bg-white/[0.03] border border-white/5 rounded-xl p-3.5 text-center">
                            <span class="text-[9px] text-slate-400 font-bold uppercase tracking-wider block mb-1">{{ __('Fee') }}</span>
                            <span class="text-sm font-bold text-emerald-400">0% FREE</span>
                        </div>
                        <div class="bg-white/[0.03] border border-white/5 rounded-xl p-3.5 text-center">
                            <span class="text-[9px] text-slate-400 font-bold uppercase tracking-wider block mb-1">{{ __('Yield') }}</span>
                            <span class="text-sm font-mono font-bold text-[#FCD535]">+14.5%</span>
                        </div>
                    </div>

                    <!-- Security Badge -->
                    <div class="bg-[#181A20] border border-white/5 rounded-2xl p-4 flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center shrink-0">
                            <svg class="w-5 h-5 text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                            </svg>
                        </div>
                        <div>
                            <h4 class="text-xs font-bold text-white">{{ __('Bank-Grade Security') }}</h4>
                            <p class="text-[10px] text-slate-400">{{ __('Automated multi-sig verification & instant balance credit.') }}</p>
                        </div>
                    </div>
                </div>

                <!-- Right Form Terminal -->
                <div class="lg:col-span-7 bg-[#181A20]/95 backdrop-blur-md border border-white/10 rounded-2xl p-6 sm:p-8 shadow-2xl">
                    <form action="{{ route('user.deposits.buy-juwishcoin-process') }}" method="POST" class="ajax-form space-y-5" data-action="redirect">
                        @csrf
                        <input type="hidden" name="is_juwishcoin" value="1">
                        <input type="hidden" name="payment_method_id" id="page-buy-jwc-payment-id" value="{{ $payment_methods->first()?->id ?? 16 }}">

                        <!-- Amount Input -->
                        <div>
                            <div class="flex justify-between items-center mb-2">
                                <label class="text-xs font-bold text-slate-300 uppercase tracking-wider">
                                    {{ __('You Pay (USD)') }}
                                </label>
                                <span class="text-xs font-mono font-bold text-slate-400">
                                    {{ __('Min') }}: {{ getSetting('currency_symbol', '$') }}{{ number_format(getSetting('min_deposit', 10)) }}
                                </span>
                            </div>

                            <div class="relative group">
                                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                    <span class="text-xl font-bold text-[#FCD535]">{{ getSetting('currency_symbol', '$') }}</span>
                                </div>
                                <input type="number" name="amount" id="page-buy-jwc-amount" step="any" required
                                    min="{{ getSetting('min_deposit', 10) }}" max="{{ getSetting('max_deposit', 1000000) }}"
                                    value="500"
                                    class="w-full bg-[#0B0E11] border border-white/10 rounded-2xl py-4 pl-10 pr-24 text-2xl font-mono font-black text-white placeholder-slate-500 focus:outline-none focus:border-[#F0B90B] focus:ring-1 focus:ring-[#F0B90B] transition-all text-right group-hover:border-white/20"
                                    placeholder="500.00">
                                <div class="absolute inset-y-0 right-4 flex items-center pointer-events-none">
                                    <span class="text-xs font-bold text-slate-300 bg-white/10 px-2.5 py-1 rounded-md">USD</span>
                                </div>
                            </div>

                            <!-- Preset Chips -->
                            <div class="grid grid-cols-6 gap-2 mt-3">
                                @foreach([50, 100, 250, 500, 1000, 5000] as $preset)
                                    <button type="button" onclick="setPageBuyJwcAmount({{ $preset }})"
                                        class="page-preset-chip py-2 px-1 rounded-xl bg-[#0B0E11] border border-white/10 text-slate-300 hover:text-white hover:border-[#F0B90B]/50 hover:bg-[#F0B90B]/10 text-xs font-bold font-mono transition-all text-center cursor-pointer {{ $preset == 500 ? 'border-[#F0B90B] text-[#FCD535] bg-[#F0B90B]/10' : '' }}"
                                        data-preset="{{ $preset }}">
                                        ${{ $preset >= 1000 ? ($preset/1000).'k' : $preset }}
                                    </button>
                                @endforeach
                            </div>
                        </div>

                        <!-- Live Conversion Box -->
                        <div class="bg-[#0B0E11] border border-white/10 rounded-2xl p-4 flex items-center justify-between">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#F0B90B]/20 to-[#FCD535]/10 border border-[#F0B90B]/30 flex items-center justify-center shrink-0">
                                    <img src="{{ asset('assets/images/juwishcoin.png') }}" class="w-6 h-6 object-contain" alt="JWC">
                                </div>
                                <div>
                                    <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest block">{{ __('Credited to Wallet Balance') }}</span>
                                    <div class="flex items-baseline gap-1.5">
                                        <span id="page-buy-jwc-receive-display" class="text-2xl font-mono font-black text-[#FCD535]">500.00</span>
                                        <span class="text-xs font-black text-white">JWC</span>
                                    </div>
                                </div>
                            </div>
                            <div class="text-right">
                                <span class="text-[9px] font-bold text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-1 rounded-full uppercase tracking-wider inline-block">
                                    {{ __('Direct Deposit') }}
                                </span>
                            </div>
                        </div>

                        <!-- Gateway Selection -->
                        <div>
                            <label class="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2.5">
                                {{ __('Select Payment Gateway') }}
                            </label>
                            <div class="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
                                @foreach($payment_methods as $idx => $method)
                                    <button type="button" onclick="selectPageBuyJwcMethod({{ $method->id }})"
                                        class="page-jwc-method-btn p-3 rounded-xl border text-left flex items-center gap-2.5 transition-all cursor-pointer {{ $idx === 0 ? 'bg-[#F0B90B]/15 border-[#F0B90B] text-white shadow-[0_0_15px_rgba(240,185,11,0.2)]' : 'bg-[#0B0E11] border-white/10 text-slate-300 hover:border-white/20 hover:text-white' }}"
                                        data-id="{{ $method->id }}">
                                        <div class="w-8 h-8 rounded-lg bg-black/40 border border-white/10 p-1 flex items-center justify-center shrink-0">
                                            @if($method->logo)
                                                <img src="{{ asset('assets/images/deposit-methods/' . $method->logo) }}" alt="{{ $method->name }}" class="w-full h-full object-contain">
                                            @else
                                                <span class="text-xs font-bold text-white">{{ substr($method->name, 0, 1) }}</span>
                                            @endif
                                        </div>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-xs font-bold text-white truncate">{{ $method->name }}</p>
                                            <p class="text-[9px] text-slate-400 uppercase tracking-wider">{{ $method->type }}</p>
                                        </div>
                                    </button>
                                @endforeach
                            </div>
                        </div>

                        <!-- Summary Breakdown -->
                        <div class="bg-white/[0.02] border border-white/5 rounded-xl p-4 space-y-2 text-xs">
                            <div class="flex justify-between items-center text-slate-400">
                                <span>{{ __('Exchange Rate') }}</span>
                                <span class="font-mono text-white font-bold">1 JWC = 1.00 USD</span>
                            </div>
                            <div class="flex justify-between items-center text-slate-400">
                                <span>{{ __('Processing Fee') }}</span>
                                <span class="text-emerald-400 font-bold uppercase tracking-wide">{{ __('0% Fee (Free)') }}</span>
                            </div>
                            <div class="flex justify-between items-center text-slate-400">
                                <span>{{ __('Credited Account') }}</span>
                                <span class="text-[#FCD535] font-bold">{{ __('Primary Cash Balance') }}</span>
                            </div>
                        </div>

                        <!-- Submit CTA -->
                        <button type="submit"
                            class="w-full py-4 rounded-2xl bg-gradient-to-r from-[#F0B90B] via-[#FCD535] to-[#F0B90B] bg-[length:200%_auto] hover:bg-right text-[#0B0E11] font-black text-sm uppercase tracking-wider flex items-center justify-center gap-3 shadow-[0_0_25px_rgba(240,185,11,0.4)] hover:shadow-[0_0_35px_rgba(240,185,11,0.6)] active:scale-[0.99] transition-all duration-300 cursor-pointer">
                            <img src="{{ asset('assets/images/juwishcoin.png') }}" class="w-5 h-5 object-contain" alt="JWC">
                            <span id="page-buy-jwc-submit-text">{{ __('Proceed to Payment (Receive 500.00 JWC)') }}</span>
                            <svg class="w-5 h-5 text-[#0B0E11]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3"/>
                            </svg>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('scripts')
    <script>
        function setPageBuyJwcAmount(amount) {
            const input = document.getElementById('page-buy-jwc-amount');
            if (input) {
                input.value = amount;
                updatePageBuyJwcCalc();
            }
            document.querySelectorAll('.page-preset-chip').forEach(chip => {
                const preset = parseInt(chip.getAttribute('data-preset'), 10);
                if (preset === amount) {
                    chip.className = "page-preset-chip py-2 px-1 rounded-xl bg-[#F0B90B]/10 border border-[#F0B90B] text-[#FCD535] text-xs font-bold font-mono transition-all text-center cursor-pointer";
                } else {
                    chip.className = "page-preset-chip py-2 px-1 rounded-xl bg-[#0B0E11] border border-white/10 text-slate-300 hover:text-white hover:border-[#F0B90B]/50 hover:bg-[#F0B90B]/10 text-xs font-bold font-mono transition-all text-center cursor-pointer";
                }
            });
        }

        function selectPageBuyJwcMethod(methodId) {
            const input = document.getElementById('page-buy-jwc-payment-id');
            if (input) input.value = methodId;
            document.querySelectorAll('.page-jwc-method-btn').forEach(btn => {
                const id = parseInt(btn.getAttribute('data-id'), 10);
                if (id === methodId) {
                    btn.className = "page-jwc-method-btn p-3 rounded-xl border text-left flex items-center gap-2.5 transition-all cursor-pointer bg-[#F0B90B]/15 border-[#F0B90B] text-white shadow-[0_0_15px_rgba(240,185,11,0.2)]";
                } else {
                    btn.className = "page-jwc-method-btn p-3 rounded-xl border text-left flex items-center gap-2.5 transition-all cursor-pointer bg-[#0B0E11] border-white/10 text-slate-300 hover:border-white/20 hover:text-white";
                }
            });
        }

        function updatePageBuyJwcCalc() {
            const input = document.getElementById('page-buy-jwc-amount');
            const display = document.getElementById('page-buy-jwc-receive-display');
            const submitText = document.getElementById('page-buy-jwc-submit-text');
            const val = parseFloat(input?.value || 0);
            const jwc = isNaN(val) ? 0 : val;

            if (display) {
                display.textContent = jwc.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }
            if (submitText) {
                submitText.textContent = jwc > 0
                    ? `Proceed to Payment (Receive ${jwc.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} JWC)`
                    : 'Buy JuwishCoin & Deposit Funds';
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            const input = document.getElementById('page-buy-jwc-amount');
            if (input) {
                input.addEventListener('input', function() {
                    updatePageBuyJwcCalc();
                    const currentVal = parseFloat(this.value);
                    document.querySelectorAll('.page-preset-chip').forEach(chip => {
                        const preset = parseInt(chip.getAttribute('data-preset'), 10);
                        if (preset === currentVal) {
                            chip.className = "page-preset-chip py-2 px-1 rounded-xl bg-[#F0B90B]/10 border border-[#F0B90B] text-[#FCD535] text-xs font-bold font-mono transition-all text-center cursor-pointer";
                        } else {
                            chip.className = "page-preset-chip py-2 px-1 rounded-xl bg-[#0B0E11] border border-white/10 text-slate-300 hover:text-white hover:border-[#F0B90B]/50 hover:bg-[#F0B90B]/10 text-xs font-bold font-mono transition-all text-center cursor-pointer";
                        }
                    });
                });
            }
        });
    </script>
@endsection
