@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('Account Activated') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ __('Welcome, :name!', ['name' => $user->first_name]) }}
    </h1>

    {{-- Introduction Text --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 24px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        {{ __('Welcome to :site. Your account is now active and ready. You have joined a global ecosystem built for intelligent wealth creation, high-yield investment programs, and seamless digital asset trading.', ['site' => getSetting('name', 'JuwishPro')]) }}
    </p>

    {{-- Platform Highlights Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px; margin-bottom: 28px;">
        <p style="margin: 0 0 14px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('What You Can Do Next') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 12px; vertical-align: top; width: 28px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <span style="color: #F0B90B; font-size: 16px;">✦</span>
                </td>
                <td style="padding-bottom: 12px; font-size: 14px; line-height: 1.5; color: #EAECEF; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <strong style="color: #FFFFFF;">{{ __('Deposit & Fund Account:') }}</strong>
                    <span style="color: #848E9C;"> {{ __('Multiple secure payment channels with instant verification.') }}</span>
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; vertical-align: top; width: 28px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <span style="color: #F0B90B; font-size: 16px;">✦</span>
                </td>
                <td style="padding-bottom: 12px; font-size: 14px; line-height: 1.5; color: #EAECEF; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <strong style="color: #FFFFFF;">{{ __('Explore Markets:') }}</strong>
                    <span style="color: #848E9C;"> {{ __('Stocks, ETFs, Crypto, Forex, Margin & Futures trading at your fingertips.') }}</span>
                </td>
            </tr>
            <tr>
                <td style="vertical-align: top; width: 28px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <span style="color: #F0B90B; font-size: 16px;">✦</span>
                </td>
                <td style="font-size: 14px; line-height: 1.5; color: #EAECEF; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <strong style="color: #FFFFFF;">{{ __('Earn Passive ROI:') }}</strong>
                    <span style="color: #848E9C;"> {{ __('Automated yield plans calculated and credited round-the-clock.') }}</span>
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
                    {{ __('Go to Dashboard') }} &rarr;
                </a>
            </td>
        </tr>
    </table>

    {{-- Help note --}}
    <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 24px 0 0 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
        {{ __('If you have any questions or require personalized assistance, our 24/7 dedicated support team is always available.') }}
    </p>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Team</strong>
        </p>
    </div>
@endsection
