@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('Two-Factor Authentication') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ $subject }}
    </h1>

    {{-- Body Message --}}
    <div style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        {!! $body_message !!}
    </div>

    {{-- Binance Glowing OTP Box --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="margin: 32px 0;">
        <tr>
            <td align="center">
                <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #F0B90B; border-radius: 12px; padding: 24px 32px; display: inline-block; min-width: 260px; box-shadow: 0 0 24px rgba(240, 185, 11, 0.15);">
                    <p style="margin: 0 0 6px 0; font-size: 11px; font-weight: 700; color: #848E9C; text-transform: uppercase; letter-spacing: 0.12em; text-align: center;">
                        {{ __('One-Time Password (OTP)') }}
                    </p>
                    <span class="otp-code" style="font-family: 'SF Pro Display', -apple-system, 'JetBrains Mono', Consolas, 'Courier New', monospace; font-size: 40px; font-weight: 800; color: #F0B90B; letter-spacing: 12px; display: block; text-align: center; text-indent: 12px;">
                        {{ $otp_code }}
                    </span>
                </div>
            </td>
        </tr>
    </table>

    <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0 0 24px 0; text-align: center; color: #848E9C;">
        {{ __('This code will expire in') }} <span style="color: #F0B90B; font-weight: 700;">15 {{ __('minutes') }}</span>.
    </p>

    {{-- Request Metadata Card (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 20px 24px; margin-bottom: 28px;">
        <p style="margin: 0 0 14px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('Security Audit Details') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 10px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }}; width: 120px;">
                    {{ __('IP Address') }}
                </td>
                <td style="padding-bottom: 10px; color: #EAECEF; font-size: 13px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }}; font-family: monospace;">
                    {{ $ip }}
                </td>
            </tr>
            @if (!empty($user_agent))
                <tr>
                    <td style="padding-bottom: 10px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                        {{ __('Device / Client') }}
                    </td>
                    <td style="padding-bottom: 10px; color: #EAECEF; font-size: 12px; text-align: {{ $isRtl ? 'left' : 'right' }}; word-break: break-all;">
                        {{ $user_agent }}
                    </td>
                </tr>
            @endif
            @if (!empty($location))
                <tr>
                    <td style="padding-bottom: 0; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                        {{ __('Location') }}
                    </td>
                    <td style="padding-bottom: 0; color: #EAECEF; font-size: 13px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }};">
                        {{ $location }}
                    </td>
                </tr>
            @endif
        </table>
    </div>

    {{-- Binance Style "Didn't Request This?" Security Alert --}}
    <div style="box-sizing: border-box; background-color: rgba(246, 70, 93, 0.08); border: 1px solid rgba(246, 70, 93, 0.25); border-radius: 12px; padding: 20px; margin-bottom: 24px;">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td style="vertical-align: top; width: 28px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <span style="color: #F6465D; font-size: 18px;">⚠️</span>
                </td>
                <td style="text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <h4 style="margin: 0 0 6px 0; font-size: 14px; font-weight: 700; color: #F6465D;">
                        {{ __("Didn't Request This?") }}
                    </h4>
                    <p style="margin: 0 0 10px 0; font-size: 13px; line-height: 1.5; color: #B7BDC6;">
                        {{ __('If you did not initiate this authorization request, your credentials may be compromised. Take the following steps immediately:') }}
                    </p>
                    <ul style="margin: 0; padding-{{ $isRtl ? 'right' : 'left' }}: 18px; font-size: 13px; line-height: 1.6; color: #EAECEF;">
                        <li>{{ __('Do not share this code under any circumstances.') }}</li>
                        <li>{{ __('Reset your JuwishPro account password.') }}</li>
                        <li>{{ __('Contact our security desk at support.') }}</li>
                    </ul>
                </td>
            </tr>
        </table>
    </div>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Security Operations</strong>
        </p>
    </div>
@endsection
