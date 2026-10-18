@extends('templates.bento.mail.layout')

@section('content')
    @php
        $isRtl = config('languages.' . app()->getLocale() . '.rtl', false);
        $status = strtolower($kyc_record->status ?? 'pending');
        $isApproved = ($status === 'approved');
        $isRejected = ($status === 'rejected');

        $statusColors = [
            'approved' => '#0ECB81',
            'pending' => '#F0B90B',
            'rejected' => '#F6465D',
        ];
        $statusBgs = [
            'approved' => 'rgba(14, 203, 129, 0.12)',
            'pending' => 'rgba(240, 185, 11, 0.12)',
            'rejected' => 'rgba(246, 70, 93, 0.12)',
        ];
        $statusBorder = [
            'approved' => 'rgba(14, 203, 129, 0.25)',
            'pending' => 'rgba(240, 185, 11, 0.25)',
            'rejected' => 'rgba(246, 70, 93, 0.25)',
        ];
        $color = $statusColors[$status] ?? '#F0B90B';
        $bg = $statusBgs[$status] ?? 'rgba(240, 185, 11, 0.12)';
        $border = $statusBorder[$status] ?? 'rgba(240, 185, 11, 0.25)';
    @endphp

    {{-- Category Badge --}}
    <div style="margin-bottom: 20px; text-align: {{ $isRtl ? 'right' : 'left' }};">
        <span style="display: inline-block; padding: 4px 12px; background-color: rgba(240, 185, 11, 0.12); border: 1px solid rgba(240, 185, 11, 0.3); border-radius: 9999px; font-size: 11px; font-weight: 700; color: #F0B90B; letter-spacing: 0.08em; text-transform: uppercase;">
            {{ __('Identity Verification (KYC)') }}
        </span>
    </div>

    {{-- Main Heading --}}
    <h1 style="box-sizing: border-box; color: #EAECEF; font-size: 26px; font-weight: 700; margin: 0 0 16px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; letter-spacing: -0.02em; line-height: 1.3;">
        {{ $subject }}
    </h1>

    {{-- Greeting & Message --}}
    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 12px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #EAECEF;">
        {{ __('Hello :name,', ['name' => $kyc_record->user->first_name]) }}
    </p>

    <p style="box-sizing: border-box; font-size: 15px; line-height: 1.6; margin: 0 0 28px 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #B7BDC6;">
        @if ($isApproved)
            {{ __('Congratulations! Your identity documents have been approved by compliance. Your account now enjoys Tier 1 privileges, including unrestricted withdrawals, institutional trading limits, and advanced investment tools.') }}
        @elseif ($isRejected)
            {{ __('Your identity verification could not be validated by our compliance department. Please examine the feedback below and submit updated or clearer credentials.') }}
        @else
            {{ __('Your verification documents have been received and queued for audit. Our automated and manual verification desks usually review submissions within 2 to 24 hours.') }}
        @endif
    </p>

    {{-- KYC Details Box (Binance Card Surface #1E2329) --}}
    <div style="box-sizing: border-box; background-color: #1E2329; border: 1px solid #2B313A; border-radius: 12px; padding: 22px 24px; margin-bottom: 28px;">
        <p style="margin: 0 0 18px 0; font-size: 12px; font-weight: 700; color: #F0B90B; text-transform: uppercase; letter-spacing: 0.08em; text-align: {{ $isRtl ? 'right' : 'left' }};">
            {{ __('Verification Submission Record') }}
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse;">
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Document Type') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 14px; font-weight: 600; text-align: {{ $isRtl ? 'left' : 'right' }}; text-transform: capitalize;">
                    {{ str_replace('_', ' ', $kyc_record->document_type) }}
                </td>
            </tr>
            <tr>
                <td style="padding-bottom: 12px; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Submitted On') }}
                </td>
                <td style="padding-bottom: 12px; color: #EAECEF; font-size: 13px; font-weight: 500; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    {{ $kyc_record->created_at->format('M d, Y H:i A') }}
                </td>
            </tr>
            <tr>
                <td style="padding-top: {{ $isRejected && $kyc_record->rejection_reason ? '12px' : '10px' }}; border-top: 1px solid #2B313A; color: #848E9C; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                    {{ __('Review Status') }}
                </td>
                <td style="padding-top: {{ $isRejected && $kyc_record->rejection_reason ? '12px' : '10px' }}; border-top: 1px solid #2B313A; text-align: {{ $isRtl ? 'left' : 'right' }};">
                    <span style="display: inline-block; padding: 3px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background-color: {{ $bg }}; border: 1px solid {{ $border }}; color: {{ $color }};">
                        {{ __(ucfirst($kyc_record->status)) }}
                    </span>
                </td>
            </tr>
            @if ($isRejected && $kyc_record->rejection_reason)
                <tr>
                    <td style="padding-top: 12px; border-top: 1px solid rgba(246, 70, 93, 0.2); color: #F6465D; font-size: 13px; text-align: {{ $isRtl ? 'right' : 'left' }};">
                        {{ __('Reason for Rejection') }}
                    </td>
                    <td style="padding-top: 12px; border-top: 1px solid rgba(246, 70, 93, 0.2); color: #FFA1A1; font-size: 13px; font-weight: 500; text-align: {{ $isRtl ? 'left' : 'right' }};">
                        {{ $kyc_record->rejection_reason }}
                    </td>
                </tr>
            @endif
        </table>
    </div>

    {{-- CTA Button --}}
    <table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="margin: 28px 0;">
        <tr>
            <td align="{{ $isRtl ? 'right' : 'left' }}">
                <a href="{{ route('user.kyc') }}" target="_blank"
                    style="box-sizing: border-box; display: inline-block; padding: 14px 34px; background-color: #FCD535; color: #0B0E11; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 15px; letter-spacing: 0.02em; text-align: center; box-shadow: 0 4px 16px rgba(240, 185, 11, 0.3);">
                    {{ $isRejected ? __('Resubmit KYC Documents') : __('View Identity Status') }} &rarr;
                </a>
            </td>
        </tr>
    </table>

    <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 24px 0 0 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
        {{ __('Identity verification complies with global regulatory standards to keep all client assets safeguarded.') }}
    </p>

    {{-- Regards Block --}}
    <div style="box-sizing: border-box; margin-top: 32px; padding-top: 24px; border-top: 1px solid #2B313A;">
        <p style="box-sizing: border-box; font-size: 13px; line-height: 1.5; margin: 0; text-align: {{ $isRtl ? 'right' : 'left' }}; color: #848E9C;">
            {{ __('Best regards,') }}<br>
            <strong style="color: #F0B90B; font-size: 14px;">{{ getSetting('name', 'JuwishPro') }} Compliance & AML Desk</strong>
        </p>
    </div>
@endsection
