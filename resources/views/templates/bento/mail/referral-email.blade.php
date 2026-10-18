@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
        $referralLink = route('user.register', ['referral_code' => $referrer->referral_code]);
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('Affiliate & Referral Network') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ __('You Have a New Referral!') }} 🚀
    </h1>

    {{-- Greeting & Message --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 12px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #EAECEF;">
        {{ __('Hi :name,', ['name' => $referrer->first_name]) }}
    </p>

    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        {{ __(':name just signed up using your referral invitation link. Your network is expanding, and you are eligible for automated multi-tier commissions.', ['name' => $referral->first_name]) }}
    </p>

    {{-- Referral Details Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px 24px; margin-bottom: 24px;">
        <p style="margin: 0 0 18px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('Affiliate Performance Overview') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Total Active Invites') }}
                </td>
                <td style="padding-bottom: 12px; color: #F0B90B; font-size: 16px; font-weight: 800; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $referrer->referrals()->count() }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Your Referral Code') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 14px; font-weight: 700; text-align: {{ $isRtl ? 'left' : 'right' }}; font-family: monospace; letter-spacing: 0.05em;">
                    {{ $referrer->referral_code }}
                </td>
            </tr>
            <tr>
                <td style="padding-top: 10px; border-top: 1px solid #2B313A; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }}; vertical-align: top;">
                    {{ __('Shareable Link') }}
                </td>
                <td style="padding-top: 10px; border-top: 1px solid #2B313A; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    <a href="{{ $referralLink }}" target="_blank"
                        style="color: #F0B90B; text-decoration: none; font-size: 12px; font-weight: 600; word-break: break-all;">
                        {{ $referralLink }}
                    </a>
                </td>
            </tr>
        </table>
    </div>

    {{-- Binance Gold High-Converting Promo Card (Replacing old purple/indigo gradient) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid rgba(240, 185, 11, 0.4); border-radius: 12px; padding: 22px 24px; margin-bottom: 28px; box-shadow: 0 4px 16px rgba(240, 185, 11, 0.1);">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td style="vertical-align: top; width: 32px; font-size: 20px; color: #F0B90B; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    💰
                </td>
                <td style="text-align: {{ $isRtl ? 'right' : 'left' }};">
                    <p style="margin: 0 0 6px 0; font-size: 14px; font-weight: 700; color: #F0B90B;">
                        {{ __('Keep the momentum building!') }}
                    </p>
                    <p style="margin: 0; font-size: 13px; line-height: 1.5; color: #B7BDC6;">
                        {{ __('Share your link on WhatsApp, Telegram, and social channels. You earn immediate commission rewards each time your referees fund accounts or activate investment plans.') }}
                    </p>
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
                    {{ __('Open Referral Dashboard') }} &rarr;
                </a>
            </td>
        </tr>
    </table>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Growth & Partnerships</strong>
        </p>
    </div>
@endsection
