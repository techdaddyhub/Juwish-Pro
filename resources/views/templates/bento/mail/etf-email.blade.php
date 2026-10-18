@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
        $isBuy = ($holding_history->transaction_type !== 'sell');
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('ETF Order Executed') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ __($custom_subject) }}
    </h1>

    {{-- Greeting & Message --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 12px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #EAECEF;">
        {{ __('Hello :name,', ['name' => $holding_history->user->first_name]) }}
    </p>

    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        {{ __($custom_message) }}
    </p>

    {{-- ETF Trade Details Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px 24px; margin-bottom: 28px;">
        <p style="margin: 0 0 18px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('ETF Trade Execution Receipt') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('ETF Fund Ticker') }}
                </td>
                <td style="padding-bottom: 12px; color: #F0B90B; font-size: 15px; font-weight: 800; text-align: {{ $isRtl ? 'left' : 'right' }}; font-family: monospace;">
                    {{ $holding_history->ticker }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Order Direction') }}
                </td>
                <td style="padding-bottom: 12px; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    <span style="display: inline-block; padding: 3px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background-color: {{ $isBuy ? 'rgba(14, 203, 129, 0.12)' : 'rgba(246, 70, 93, 0.12)' }}; border: 1px solid {{ $isBuy ? 'rgba(14, 203, 129, 0.25)' : 'rgba(246, 70, 93, 0.25)' }}; color: {{ $isBuy ? '#0ECB81' : '#F6465D' }};">
                        {{ $isBuy ? __('BUY') : __('SELL') }}
                    </span>
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Shares Transacted') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 14px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ number_format($holding_history->shares, 6) }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Execution NAV / Price') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 14px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    ${{ number_format($holding_history->price_at_action, 2) }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Settlement Value') }}
                </td>
                <td style="padding-bottom: 12px; color: #F0B90B; font-size: 16px; font-weight: 800; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ getSetting('currency_symbol', '$') }}{{ number_format($holding_history->amount_usd, getSetting('decimal_places', 2)) }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Transaction Fee') }}
                </td>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; font-weight: 500; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ getSetting('currency_symbol', '$') }}{{ number_format($holding_history->fee_amount, getSetting('decimal_places', 2)) }}
                </td>
            </tr>
            <tr>
                <td style="padding-top: 10px; border-top: 1px solid #2B313A; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Execution Date') }}
                </td>
                <td style="padding-top: 10px; border-top: 1px solid #2B313A; color: #EAECEF; font-size: 13px; font-weight: 500; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $holding_history->created_at->format('M d, Y H:i:s A') }}
                </td>
            </tr>
        </table>
    </div>

    {{-- CTA Button --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="margin: 28px 0;">
        <tr>
            <td align="{{ $isRtl ? 'right' : 'left' }}">
                <a href="{{ route('user.capital-instruments.etfs') }}" target="_blank"
                    style="box-sizing: border-box; display: inline-block; padding: 14px 34px; background-color: #FCD535; color: #0B0E11; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 15px; letter-spacing: 0.02em; text-align: center; box-shadow: 0 4px 16px rgba(240, 185, 11, 0.3);">
                    {{ __('View ETF Portfolio') }} &rarr;
                </a>
            </td>
        </tr>
    </table>

    <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 24px 0 0 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
        {{ __('Your portfolio holdings update automatically on market close. Check your dashboard for sector allocation analytics.') }}
    </p>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Fund Operations</strong>
        </p>
    </div>
@endsection
