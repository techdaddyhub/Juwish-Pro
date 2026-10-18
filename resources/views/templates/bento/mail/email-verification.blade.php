@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('Email Verification') }}
        </span>
    </div>

    {{-- Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ __('Verify Your Email Address') }}
    </h1>

    {{-- Greeting & Text --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 12px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #EAECEF;">
        {{ __('Hello :name,', ['name' => $name]) }}
    </p>

    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        {{ __('Thank you for choosing :site. To complete your account verification and protect your identity, please enter the following verification code:', ['site' => getSetting('name', 'JuwishPro')]) }}
    </p>

    {{-- Binance Styled Glowing OTP Code Box --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="margin: 32px 0;">
        <tr>
            <td align="center">
                <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #F0B90B; border-radius: 12px; padding: 24px 32px; display: inline-block; min-width: 260px; box-shadow: 0 0 24px rgba(240, 185, 11, 0.15);">
                    <p style="margin: 0 0 6px 0; font-size: 11px; font-weight: 700; color: #848E9C; text-transform: uppercase; letter-spacing: 0.12em; text-align: center;">
                        {{ __('Verification Code') }}
                    </p>
                    <span class="otp-code" style="font-family: 'SF Pro Display', -apple-system, 'JetBrains Mono', Consolas, 'Courier New', monospace; font-size: 40px; font-weight: 800; color: #F0B90B; letter-spacing: 12px; display: block; text-align: center; text-indent: 12px;">
                        {{ $otp_code }}
                    </span>
                </div>
            </td>
        </tr>
    </table>

    {{-- Expiration & Security Info --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 10px; padding: 16px 20px; margin: 28px 0;">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td style="width: 24px; vertical-align: top; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #F0B90B; font-size: 16px;">
                    &#9200;
                </td>
                <td style="font-size: 13px; line-height: 1.5; color: #848E9C; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <strong style="color: #EAECEF;">{{ __('Validity:') }}</strong> {{ __('This code will expire in 15 minutes.') }}
                    {{ __('For your account security, never reveal this code to anyone, including JuwishPro staff.') }}
                </td>
            </tr>
        </table>
    </div>

    <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 16px 0 0 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #5E6673;">
        {{ __('If you did not attempt to sign up or log in to :site, please disregard this email or report unauthorized activity to our security department.', ['site' => getSetting('name', 'JuwishPro')]) }}
    </p>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Security Team</strong>
        </p>
    </div>
@endsection
