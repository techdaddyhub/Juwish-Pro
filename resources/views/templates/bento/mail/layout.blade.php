<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
@php
    $locale = app()->getLocale();
    $isRtl = config('languages.' . $locale . '.rtl', false);
    $siteName = getSetting('name', 'JuwishPro');
    $logo = getSetting('logo_rectangle', 'logo-rectangle.png');
    $logoPath = public_path('assets/images/' . $logo);
    $logoVersion = file_exists($logoPath) ? filemtime($logoPath) : time();
@endphp
<html xmlns="http://www.w3.org/1999/xhtml" lang="{{ $locale }}" dir="{{ $isRtl ? 'rtl' : 'ltr' }}">

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="color-scheme" content="dark" />
    <meta name="supported-color-schemes" content="dark" />
    <title>{{ $siteName }}</title>
    <style>
        /* Base Resets */
        body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; outline: none; text-decoration: none; }

        @media only screen and (max-width: 620px) {
            .email-container {
                width: 100% !important;
                max-width: 100% !important;
            }
            .content-padding {
                padding: 24px 18px !important;
            }
            .header-padding {
                padding: 24px 16px 20px 16px !important;
            }
            .footer-padding {
                padding: 24px 18px !important;
            }
            .mobile-full-width {
                width: 100% !important;
                display: block !important;
            }
            .mobile-center {
                text-align: center !important;
            }
            .otp-code {
                font-size: 32px !important;
                letter-spacing: 8px !important;
            }
        }
    </style>
</head>

<body style="box-sizing: border-box; margin: 0; padding: 0; width: 100% !important; height: 100%; background-color: #0B0E11; color: #EAECEF; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.5; -webkit-font-smoothing: antialiased;">

    {{-- Outer Canvas Table --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation"
        style="box-sizing: border-box; width: 100%; background-color: #0B0E11; margin: 0; padding: 32px 12px;">
        <tr>
            <td align="center" style="box-sizing: border-box;">
                
                {{-- Master Container (Max 600px) --}}
                <table class="email-container" width="600" cellpadding="0" cellspacing="0" border="0" role="presentation"
                    style="box-sizing: border-box; width: 600px; max-width: 600px; margin: 0 auto;">
                    
                    {{-- Header with Brand Logo --}}
                    <tr>
                        <td class="header-padding" align="center" style="box-sizing: border-box; padding: 12px 0 28px 0; text-align: center;">
                            <a href="{{ config('app.url') }}" target="_blank"
                                style="box-sizing: border-box; display: inline-block; text-decoration: none; outline: none;">
                                <img src="{{ url('assets/images/' . $logo) . '?v=' . $logoVersion }}"
                                    alt="{{ $siteName }}"
                                    style="max-height: 44px; max-width: 220px; height: auto; width: auto; display: block; border: 0; outline: none;">
                            </a>

                            {{-- Subtle Binance Gold Anti-Phishing & Security Tag --}}
                            <div style="margin-top: 14px;">
                                <span style="display: inline-block; padding: 3px 10px; background-color: rgba(240, 185, 11, 0.08); border: 1px solid rgba(240, 185, 11, 0.2); border-radius: 9999px; font-size: 10px; font-weight: 700; color: #F0B90B; letter-spacing: 0.06em; text-transform: uppercase;">
                                    &#128274; {{ __('Official Verified Notification') }}
                                </span>
                            </div>
                        </td>
                    </tr>

                    {{-- Main Card Box (Binance Dark Surface #181A20 with Gold Top Highlight) --}}
                    <tr>
                        <td style="box-sizing: border-box; background-color: #181A20; border: 1px solid #2B313A; border-top: 3px solid #F0B90B; border-radius: 16px; overflow: hidden; box-shadow: 0 12px 32px rgba(0, 0, 0, 0.45);">
                            <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation">
                                <tr>
                                    <td class="content-padding" style="box-sizing: border-box; padding: 40px 36px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                                        @yield('content')
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    {{-- Binance Style Security & Compliance Card --}}
                    <tr>
                        <td style="box-sizing: border-box; padding-top: 20px;">
                            <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation"
                                style="box-sizing: border-box; background-color: rgba(24, 26, 32, 0.7); border: 1px solid #2B313A; border-radius: 12px; padding: 14px 18px;">
                                <tr>
                                    <td style="box-sizing: border-box; font-size: 11px; line-height: 1.5; color: #848E9C; text-align: {{ $isRtl ? 'right' : 'left' }};">
                                        <span style="color: #F0B90B; font-weight: 700;">{{ __('Security Note:') }}</span>
                                        {{ __('Never share your password, 2FA backup codes, or verification pins with anyone. Official staff will never ask for your private credentials.') }}
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    {{-- Footer --}}
                    <tr>
                        <td class="footer-padding" align="center" style="box-sizing: border-box; padding: 32px 20px; text-align: center;">
                            {{-- Quick Navigation Links --}}
                            <p style="margin: 0 0 14px 0; font-size: 12px; color: #848E9C;">
                                <a href="{{ route('user.dashboard') }}" target="_blank"
                                    style="color: #F0B90B; text-decoration: none; font-weight: 600; margin: 0 8px;">
                                    {{ __('Dashboard') }}
                                </a>
                                <span style="color: #2B313A;">|</span>
                                <a href="{{ route('about') }}" target="_blank"
                                    style="color: #848E9C; text-decoration: none; margin: 0 8px;">
                                    {{ __('About') }}
                                </a>
                                <span style="color: #2B313A;">|</span>
                                <a href="{{ route('contact') }}" target="_blank"
                                    style="color: #848E9C; text-decoration: none; margin: 0 8px;">
                                    {{ __('Support 24/7') }}
                                </a>
                                <span style="color: #2B313A;">|</span>
                                <a href="{{ route('terms-and-conditions') }}" target="_blank"
                                    style="color: #848E9C; text-decoration: none; margin: 0 8px;">
                                    {{ __('Terms') }}
                                </a>
                            </p>

                            {{-- Copyright and Disclaimer --}}
                            <p style="margin: 0 0 8px 0; font-size: 11px; line-height: 1.6; color: #5E6673;">
                                © {{ date('Y') }} {{ $siteName }}. {{ __('All rights reserved.') }}
                            </p>
                            <p style="margin: 0; font-size: 10px; line-height: 1.5; color: #474D57;">
                                {{ __('This is an automated system email. Please do not reply directly to this email address.') }}
                            </p>
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
    </table>
</body>

</html>
