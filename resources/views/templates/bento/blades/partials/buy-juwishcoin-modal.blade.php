<!-- Buy JuwishCoin (JWC) Quick Deposit Modal -->
<div id="buy-juwishcoin-modal" class="fixed inset-0 z-50 hidden font-sans" role="dialog" aria-modal="true">
    <!-- Backdrop -->
    <div class="absolute inset-0 bg-black/90 backdrop-blur-md transition-opacity duration-300 opacity-0 buy-jwc-backdrop"></div>

    <!-- Modal Dialog Center -->
    <div class="absolute inset-0 flex items-center justify-center p-3 sm:p-4 overflow-y-auto">
        <div class="bg-[#0B0E11] border border-[#F0B90B]/30 rounded-3xl w-full max-w-lg transform scale-95 opacity-0 transition-all duration-300 buy-jwc-content relative overflow-hidden shadow-[0_0_50px_rgba(240,185,11,0.15)] my-auto">
            
            <!-- Top Gold Glow Bar -->
            <div class="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-transparent via-[#F0B90B] to-transparent"></div>
            
            <!-- Ambient Background Glows -->
            <div class="absolute -top-24 -right-24 w-52 h-52 bg-[#F0B90B]/10 rounded-full blur-3xl pointer-events-none"></div>
            <div class="absolute -bottom-24 -left-24 w-52 h-52 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none"></div>

            <!-- Close Button -->
            <button type="button" onclick="closeBuyJuwishCoinModal()"
                class="absolute top-5 right-5 w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-slate-400 hover:text-white hover:bg-white/10 transition-colors z-20 cursor-pointer">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>

            <!-- Modal Header -->
            <div class="p-6 sm:p-8 pb-4 relative z-10 text-center">
                <!-- Coin 3D Medallion -->
                <div class="relative w-20 h-20 mx-auto mb-4 flex items-center justify-center">
                    <div class="absolute inset-0 bg-gradient-to-tr from-[#F0B90B]/30 to-[#FCD535]/10 rounded-full blur-xl animate-pulse"></div>
                    <img src="{{ asset('assets/images/juwishcoin.png') }}"
                        alt="JuwishCoin (JWC)"
                        class="w-18 h-18 object-contain drop-shadow-[0_10px_20px_rgba(240,185,11,0.4)] transform hover:scale-110 transition-transform duration-300">
                    <span class="absolute -bottom-1 -right-1 flex h-4 w-4">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#F0B90B] opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-4 w-4 bg-[#F0B90B] border-2 border-[#0B0E11]"></span>
                    </span>
                </div>

                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#F0B90B]/10 border border-[#F0B90B]/30 text-[#FCD535] text-[10px] font-black uppercase tracking-widest mb-2 shadow-sm">
                    <svg class="w-3 h-3 text-[#FCD535]" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                    </svg>
                    <span>1 JWC = $3.00 USD • PancakeSwap Pool</span>
                </div>

                <h3 class="text-2xl sm:text-3xl font-black text-white tracking-tight">
                    {{ __('Buy JuwishCoin') }}
                </h3>
                <p class="text-slate-400 text-xs mt-1 max-w-sm mx-auto">
                    {{ __('Fund your cash balance instantly by acquiring JuwishCoin at zero surcharge.') }}
                </p>
            </div>

            <!-- Form -->
            <form action="{{ route('user.deposits.buy-juwishcoin-process') }}" method="POST" class="ajax-form relative z-10" data-action="redirect">
                @csrf
                <input type="hidden" name="payment_method_id" id="buy-jwc-payment-method-id" value="{{ ($payment_methods ?? $enabled_payment_methods ?? collect())->first()?->id ?? 16 }}">
                <input type="hidden" name="is_juwishcoin" value="1">

                <div class="px-6 sm:px-8 space-y-5">
                    <!-- Amount Input -->
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <label class="text-[11px] font-bold text-slate-300 uppercase tracking-wider">
                                {{ __('You Pay (USD)') }}
                            </label>
                            <span class="text-[10px] font-mono font-bold text-slate-400">
                                {{ __('Min') }}: {{ getSetting('currency_symbol', '$') }}{{ number_format(getSetting('min_deposit', 10)) }}
                            </span>
                        </div>

                        <div class="relative group">
                            <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                <span class="text-xl font-bold text-[#FCD535]">{{ getSetting('currency_symbol', '$') }}</span>
                            </div>
                            <input type="number" name="amount" id="buy-jwc-amount-input" step="any" required
                                min="{{ getSetting('min_deposit', 10) }}" max="{{ getSetting('max_deposit', 1000000) }}"
                                value="300"
                                class="w-full bg-[#181A20] border border-white/10 rounded-2xl py-3.5 pl-10 pr-24 text-2xl font-mono font-black text-white placeholder-slate-500 focus:outline-none focus:border-[#F0B90B] focus:ring-1 focus:ring-[#F0B90B] transition-all text-right group-hover:border-white/20"
                                placeholder="300.00">
                            <div class="absolute inset-y-0 right-3 flex items-center pointer-events-none">
                                <span class="text-xs font-bold text-slate-300 bg-white/10 px-2 py-1 rounded-md">USD</span>
                            </div>
                        </div>

                        <!-- Preset Quick Chips -->
                        <div class="grid grid-cols-6 gap-1.5 mt-3">
                            @foreach([30, 90, 300, 600, 1500, 3000] as $preset)
                                <button type="button" onclick="setBuyJwcAmount({{ $preset }})"
                                    class="preset-chip py-1.5 px-1 rounded-lg bg-[#181A20] border border-white/10 text-slate-300 hover:text-white hover:border-[#F0B90B]/50 hover:bg-[#F0B90B]/10 text-[11px] font-bold font-mono transition-all text-center cursor-pointer {{ $preset == 300 ? 'border-[#F0B90B] text-[#FCD535] bg-[#F0B90B]/10' : '' }}"
                                    data-preset="{{ $preset }}">
                                    ${{ $preset >= 1000 ? ($preset/1000).'k' : $preset }}
                                </button>
                            @endforeach
                        </div>
                    </div>

                    <!-- Live Conversion Callout -->
                    <div class="bg-[#181A20] border border-white/10 rounded-2xl p-4 flex items-center justify-between">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#F0B90B]/20 to-[#FCD535]/10 border border-[#F0B90B]/30 flex items-center justify-center shrink-0">
                                <img src="{{ asset('assets/images/juwishcoin.png') }}" class="w-6 h-6 object-contain" alt="JWC">
                            </div>
                            <div>
                                <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest block">{{ __('You Receive') }}</span>
                                <div class="flex items-baseline gap-1.5">
                                    <span id="buy-jwc-receive-display" class="text-xl font-mono font-black text-[#FCD535]">100.00</span>
                                    <span class="text-xs font-black text-white">JWC</span>
                                </div>
                            </div>
                        </div>
                        <div class="text-right">
                            <span class="text-[9px] font-bold text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full uppercase tracking-wider inline-block">
                                {{ __('+ Balance Credit') }}
                            </span>
                            <p class="text-[10px] text-slate-400 mt-1 font-mono">1 JWC = $3.00 USD (PancakeSwap)</p>
                        </div>
                    </div>

                    <!-- Payment Gateway Selector -->
                    <div>
                        <div class="flex justify-between items-center mb-2">
                            <label class="text-[11px] font-bold text-slate-300 uppercase tracking-wider">
                                {{ __('Select Payment Gateway') }}
                            </label>
                            <span class="text-[10px] text-emerald-400 font-bold flex items-center gap-1">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                                {{ __('Instant Gateways') }}
                            </span>
                        </div>

                        @php
                            $available_methods = $payment_methods ?? $enabled_payment_methods ?? collect();
                        @endphp

                        <div class="grid grid-cols-2 sm:grid-cols-3 gap-2 max-h-48 overflow-y-auto pr-1 scrollbar-thin scrollbar-thumb-white/10">
                            @forelse($available_methods as $idx => $method)
                                <button type="button" onclick="selectBuyJwcPaymentMethod({{ $method->id }}, '{{ addslashes($method->name) }}')"
                                    class="buy-jwc-method-btn p-2.5 rounded-xl border text-left flex items-center gap-2.5 transition-all cursor-pointer {{ $idx === 0 ? 'bg-[#F0B90B]/15 border-[#F0B90B] text-white shadow-[0_0_15px_rgba(240,185,11,0.2)]' : 'bg-[#181A20] border-white/10 text-slate-300 hover:border-white/20 hover:text-white' }}"
                                    data-id="{{ $method->id }}"
                                    data-name="{{ $method->name }}">
                                    <div class="w-8 h-8 rounded-lg bg-black/40 border border-white/10 p-1 flex items-center justify-center shrink-0">
                                        @if($method->logo)
                                            <img src="{{ asset('assets/images/deposit-methods/' . $method->logo) }}"
                                                alt="{{ $method->name }}"
                                                class="w-full h-full object-contain">
                                        @else
                                            <span class="text-xs font-bold text-white">{{ substr($method->name, 0, 1) }}</span>
                                        @endif
                                    </div>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-xs font-bold text-white truncate">{{ $method->name }}</p>
                                        <p class="text-[9px] text-slate-400 uppercase tracking-wider">{{ $method->type }}</p>
                                    </div>
                                </button>
                            @empty
                                <div class="col-span-3 text-center py-4 text-xs text-slate-400">
                                    {{ __('No payment methods available') }}
                                </div>
                            @endforelse
                        </div>
                    </div>

                    <!-- Order Summary Row -->
                    <div class="bg-white/[0.02] border border-white/5 rounded-xl p-3.5 space-y-2 text-xs">
                        <div class="flex justify-between items-center text-slate-400">
                            <span>{{ __('Exchange Rate') }}</span>
                            <span class="font-mono text-white font-bold">1 JWC = $3.00 USD (PancakeSwap)</span>
                        </div>
                        <div class="flex justify-between items-center text-slate-400">
                            <span>{{ __('Deposit Fee') }}</span>
                            <span class="text-emerald-400 font-bold uppercase tracking-wide">{{ __('0% Zero Fee') }}</span>
                        </div>
                        <div class="flex justify-between items-center text-slate-400">
                            <span>{{ __('Credited Destination') }}</span>
                            <span class="text-[#FCD535] font-bold">{{ __('Main Cash Balance') }}</span>
                        </div>
                    </div>
                </div>

                <!-- Submit Button -->
                <div class="p-6 sm:p-8 pt-5">
                    <button type="submit"
                        class="w-full py-4 rounded-2xl bg-gradient-to-r from-[#F0B90B] via-[#FCD535] to-[#F0B90B] bg-[length:200%_auto] hover:bg-right text-[#0B0E11] font-black text-sm uppercase tracking-wider flex items-center justify-center gap-3 shadow-[0_0_25px_rgba(240,185,11,0.4)] hover:shadow-[0_0_35px_rgba(240,185,11,0.6)] active:scale-[0.99] transition-all duration-300 cursor-pointer">
                        <img src="{{ asset('assets/images/juwishcoin.png') }}" class="w-5 h-5 object-contain" alt="JWC">
                        <span id="buy-jwc-submit-text">{{ __('Buy JuwishCoin & Deposit Funds') }}</span>
                        <svg class="w-5 h-5 text-[#0B0E11]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3"/>
                        </svg>
                    </button>

                    <div class="flex items-center justify-center gap-2 mt-3.5 text-[10px] text-slate-400 font-medium">
                        <svg class="w-3.5 h-3.5 text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                        </svg>
                        <span>{{ __('256-bit Encrypted Settlement • Instant Balance Credit Upon Approval') }}</span>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openBuyJuwishCoinModal(defaultAmount = null) {
        const modal = document.getElementById('buy-juwishcoin-modal');
        if (!modal) return;
        const backdrop = modal.querySelector('.buy-jwc-backdrop');
        const content = modal.querySelector('.buy-jwc-content');

        if (defaultAmount) {
            setBuyJwcAmount(defaultAmount);
        } else {
            updateBuyJwcCalculations();
        }

        modal.classList.remove('hidden');
        setTimeout(() => {
            backdrop.classList.remove('opacity-0');
            content.classList.remove('opacity-0', 'scale-95');
            content.classList.add('scale-100');
        }, 10);
    }

    function closeBuyJuwishCoinModal() {
        const modal = document.getElementById('buy-juwishcoin-modal');
        if (!modal) return;
        const backdrop = modal.querySelector('.buy-jwc-backdrop');
        const content = modal.querySelector('.buy-jwc-content');

        backdrop.classList.add('opacity-0');
        content.classList.remove('scale-100');
        content.classList.add('opacity-0', 'scale-95');

        setTimeout(() => {
            modal.classList.add('hidden');
        }, 300);
    }

    function setBuyJwcAmount(amount) {
        const input = document.getElementById('buy-jwc-amount-input');
        if (input) {
            input.value = amount;
            updateBuyJwcCalculations();
        }

        document.querySelectorAll('.preset-chip').forEach(chip => {
            const preset = parseInt(chip.getAttribute('data-preset'), 10);
            if (preset === amount) {
                chip.classList.add('border-[#F0B90B]', 'text-[#FCD535]', 'bg-[#F0B90B]/10');
            } else {
                chip.classList.remove('border-[#F0B90B]', 'text-[#FCD535]', 'bg-[#F0B90B]/10');
            }
        });
    }

    function selectBuyJwcPaymentMethod(methodId, methodName) {
        const input = document.getElementById('buy-jwc-payment-method-id');
        if (input) input.value = methodId;

        document.querySelectorAll('.buy-jwc-method-btn').forEach(btn => {
            const id = parseInt(btn.getAttribute('data-id'), 10);
            if (id === methodId) {
                btn.className = "buy-jwc-method-btn p-2.5 rounded-xl border text-left flex items-center gap-2.5 transition-all cursor-pointer bg-[#F0B90B]/15 border-[#F0B90B] text-white shadow-[0_0_15px_rgba(240,185,11,0.2)]";
            } else {
                btn.className = "buy-jwc-method-btn p-2.5 rounded-xl border text-left flex items-center gap-2.5 transition-all cursor-pointer bg-[#181A20] border-white/10 text-slate-300 hover:border-white/20 hover:text-white";
            }
        });
    }

    function updateBuyJwcCalculations() {
        const input = document.getElementById('buy-jwc-amount-input');
        const display = document.getElementById('buy-jwc-receive-display');
        const submitText = document.getElementById('buy-jwc-submit-text');

        const val = parseFloat(input?.value || 0);
        const jwcAmount = isNaN(val) ? 0 : (val / 3.00); // 1 JWC = $3.00 USD (PancakeSwap)

        if (display) {
            display.textContent = jwcAmount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }
        if (submitText) {
            submitText.textContent = jwcAmount > 0
                ? `Buy ${jwcAmount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} JWC & Deposit`
                : 'Buy JuwishCoin & Deposit Funds';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const amountInput = document.getElementById('buy-jwc-amount-input');
        if (amountInput) {
            amountInput.addEventListener('input', function() {
                updateBuyJwcCalculations();
                const currentVal = parseFloat(this.value);
                document.querySelectorAll('.preset-chip').forEach(chip => {
                    const preset = parseInt(chip.getAttribute('data-preset'), 10);
                    if (preset === currentVal) {
                        chip.classList.add('border-[#F0B90B]', 'text-[#FCD535]', 'bg-[#F0B90B]/10');
                    } else {
                        chip.classList.remove('border-[#F0B90B]', 'text-[#FCD535]', 'bg-[#F0B90B]/10');
                    }
                });
            });
        }

        // Close on backdrop or Escape key
        const modal = document.getElementById('buy-juwishcoin-modal');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target.classList.contains('buy-jwc-backdrop')) {
                    closeBuyJuwishCoinModal();
                }
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeBuyJuwishCoinModal();
            }
        });
    });
</script>
