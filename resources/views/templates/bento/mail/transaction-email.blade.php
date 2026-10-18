@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
        $status = strtolower($transaction->status ?? 'completed');
        $statusColors = [
            'completed' => '#0ECB81',
            'approved' => '#0ECB81',
            'pending' => '#F0B90B',
            'failed' => '#F6465D',
            'rejected' => '#F6465D',
        ];
        $statusBgs = [
            'completed' => 'rgba(14, 203, 129, 0.12)',
            'approved' => 'rgba(14, 203, 129, 0.12)',
            'pending' => 'rgba(240, 185, 11, 0.12)',
            'failed' => 'rgba(246, 70, 93, 0.12)',
            'rejected' => 'rgba(246, 70, 93, 0.12)',
        ];
        $statusBorder = [
            'completed' => 'rgba(14, 203, 129, 0.25)',
            'approved' => 'rgba(14, 203, 129, 0.25)',
            'pending' => 'rgba(240, 185, 11, 0.25)',
            'failed' => 'rgba(246, 70, 93, 0.25)',
            'rejected' => 'rgba(246, 70, 93, 0.25)',
        ];
        $color = $statusColors[$status] ?? '#0ECB81';
        $bg = $statusBgs[$status] ?? 'rgba(14, 203, 129, 0.12)';
        $border = $statusBorder[$status] ?? 'rgba(14, 203, 129, 0.25)';
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('Transaction Alert') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ __('Account Balance Updated') }}
    </h1>

    {{-- Greeting & Text --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 12px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #EAECEF;">
        {{ __('Hello :name,', ['name' => $transaction->user->first_name]) }}
    </p>

    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        {{ __('A new financial movement has been recorded on your account ledger. Review the transaction receipt below:') }}
    </p>

    {{-- Transaction Details Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px 24px; margin-bottom: 28px;">
        <p style="margin: 0 0 18px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('Transaction Ledger Receipt') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Transaction Type') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 14px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }}; text-transform: capitalize;">
                    {{ __($transaction->type) }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Transaction Amount') }}
                </td>
                <td style="padding-bottom: 12px; color: {{ $transaction->type === 'credit' ? '#0ECB81' : '#EAECEF' }}; font-size: 16px; font-weight: 700; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $transaction->type === 'credit' ? '+' : '-' }}{{ $transaction->amount }} {{ $transaction->currency }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Execution Status') }}
                </td>
                <td style="padding-bottom: 12px; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    <span style="display: inline-block; padding: 3px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background-color: {{ $bg }}; border: 1px solid {{ $border }}; color: {{ $color }};">
                        {{ __($transaction->status) }}
                    </span>
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Timestamp') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 13px; font-weight: 500; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $transaction->created_at->format('M d, Y H:i:s A') }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Description') }}
                </td>
                <td style="padding-bottom: 12px; color: #B7BDC6; font-size: 13px; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ __($transaction->description) }}
                </td>
            </tr>
            <tr>
                <td style="padding-top: 12px; border-top: 1px solid #2B313A; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Updated Balance') }}
                </td>
                <td style="padding-top: 12px; border-top: 1px solid #2B313A; color: #F0B90B; font-size: 16px; font-weight: 800; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $transaction->new_balance }} {{ $transaction->currency }}
                </td>
            </tr>
        </table>
    </div>

    {{-- CTA Button --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="margin: 28px 0;">
        <tr>
            <td align="{{ $isRtl ? 'right' : 'left' }}">
                <a href="{{ route('user.dashboard') }}" target="_blank"
                    style="box-sizing: border-box; display: inline-block; padding: 14px 34px; background-color: #FCD535; color: #0B0E11; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 15px; letter-spacing: 0.02em; text-align: center; box-shadow: 0 4px 16px rgba(240, 185, 11, 0.3);">
                    {{ __('View Transaction on Dashboard') }} &rarr;
                </a>
            </td>
        </tr>
    </table>

    <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 24px 0 0 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
        {{ __('If you did not authorize this balance movement, please contact our 24/7 fraud prevention desk immediately.') }}
    </p>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Ledger Systems</strong>
        </p>
    </div>
@endsection
