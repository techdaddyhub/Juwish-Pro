@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
        $isBan = ($action ?? 'ban') === 'ban';
        $accentColor = $isBan ? '#F6465D' : '#0ECB81';
        $accentBg = $isBan ? 'rgba(246, 70, 93, 0.12)' : 'rgba(14, 203, 129, 0.12)';
        $accentBorder = $isBan ? 'rgba(246, 70, 93, 0.25)' : 'rgba(14, 203, 129, 0.25)';
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: {{ $accentBg }}; border: 1px solid {{ $accentBorder }}; border-radius: 9999px; font-size: 11px; font-weight: 700; color: {{ $accentColor }}; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ $isBan ? __('Security Suspension') : __('Account Restored') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ $isBan ? __('Your Account Has Been Suspended') : __('Your Account Has Been Reactivated') }}
    </h1>

    {{-- Greeting & Text --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 12px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #EAECEF;">
        {{ __('Hello :name,', ['name' => $user->first_name]) }}
    </p>

    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        @if ($isBan)
            {{ __('We are writing to inform you that access to your :site account has been suspended following a compliance or security review. Active trading sessions have been revoked.', ['site' => getSetting('name', 'JuwishPro')]) }}
        @else
            {{ __('We are pleased to inform you that your :site account has been fully reactivated. All restrictions have been lifted, and you can resume normal trading and investment operations.', ['site' => getSetting('name', 'JuwishPro')]) }}
        @endif
    </p>

    {{-- Account Details Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px 24px; margin-bottom: 24px;">
        <p style="margin: 0 0 18px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('Account Record') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }}; width: 130px;">
                    {{ __('Account Holder') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 14px; font-weight: 700; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $user->first_name }} {{ $user->last_name }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Username') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 13px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }}; font-family: monospace;">
                    {{ $user->username }}
                </td>
            </tr>
            <tr>
                <td style="padding-top: 10px; border-top: 1px solid #2B313A; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Account Status') }}
                </td>
                <td style="padding-top: 10px; border-top: 1px solid #2B313A; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    <span style="display: inline-block; padding: 3px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background-color: {{ $accentBg }}; border: 1px solid {{ $accentBorder }}; color: {{ $accentColor }};">
                        {{ $isBan ? __('Suspended') : __('Active') }}
                    </span>
                </td>
            </tr>
        </table>
    </div>

    {{-- What This Means Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px 24px; margin-bottom: 28px;">
        <p style="margin: 0 0 12px 0; font-size: 12px; font-weight: 700; color: #848E9C; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('What This Means') }}
        </p>

        @if ($isBan)
            <ul style="margin: 0; padding-{{ $isRtl ? 'right' : 'left' }}: 18px; font-size: 13px; line-height: 1.7; color: #B7BDC6;">
                <li>{{ __('Account authentication and new sessions are blocked.') }}</li>
                <li>{{ __('Withdrawal processing is temporarily halted pending verification.') }}</li>
                <li>{{ __('If you believe this was done in error, you may file an appeal with our compliance office.') }}</li>
            </ul>
        @else
            <ul style="margin: 0; padding-{{ $isRtl ? 'right' : 'left' }}: 18px; font-size: 13px; line-height: 1.7; color: #B7BDC6;">
                <li>{{ __('You can now log in normally using your regular credentials.') }}</li>
                <li>{{ __('All deposit, trading, and withdrawal modules are active.') }}</li>
                <li>{{ __('We recommend enabling two-factor authentication for enhanced protection.') }}</li>
            </ul>
        @endif
    </div>

    {{-- CTA Button --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="margin: 28px 0;">
        <tr>
            <td align="{{ $isRtl ? 'right' : 'left' }}">
                @if ($isBan)
                    <a href="mailto:{{ getSetting('email') ?? config('mail.from.address') }}" target="_blank"
                        style="box-sizing: border-box; display: inline-block; padding: 14px 34px; background-color: #FCD535; color: #0B0E11; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 15px; letter-spacing: 0.02em; text-align: center; box-shadow: 0 4px 16px rgba(240, 185, 11, 0.3);">
                        {{ __('Contact Security Compliance') }} &rarr;
                    </a>
                @else
                    <a href="{{ route('user.dashboard') }}" target="_blank"
                        style="box-sizing: border-box; display: inline-block; padding: 14px 34px; background-color: #FCD535; color: #0B0E11; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 15px; letter-spacing: 0.02em; text-align: center; box-shadow: 0 4px 16px rgba(240, 185, 11, 0.3);">
                        {{ __('Go to Dashboard') }} &rarr;
                    </a>
                @endif
            </td>
        </tr>
    </table>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Compliance Authority</strong>
        </p>
    </div>
@endsection