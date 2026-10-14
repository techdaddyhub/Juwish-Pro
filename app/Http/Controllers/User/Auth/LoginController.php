<?php

namespace App\Http\Controllers\User\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Str;
use Session;

class LoginController extends Controller
{
    //index
    public function index()
    {
        $page_title = "Sign In";
        $template = config('site.template');

        // Restrict login methods strictly to Google and Email
        $raw_methods = json_decode(getSetting('login_methods'), true) ?? [];
        $login_methods = [];

        // Google
        if (isset($raw_methods['google'])) {
            $login_methods['google'] = $raw_methods['google'];
            $login_methods['google']['status'] = 'enabled';
        } else {
            $login_methods['google'] = [
                'status' => 'enabled',
                'name' => 'Google',
                'icon' => '<svg class="w-5 h-5" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.1c-.22-.66-.35-1.36-.35-2.1s.13-1.44.35-2.1V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l3.66-2.84z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.63l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg>'
            ];
        }

        // Email
        if (isset($raw_methods['email'])) {
            $login_methods['email'] = $raw_methods['email'];
            $login_methods['email']['status'] = 'enabled';
        } else {
            $login_methods['email'] = [
                'status' => 'enabled',
                'name' => 'Email',
                'icon' => '<svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>'
            ];
        }

        $only_email = false;

        return view("templates.$template.blades.user.auth.login", compact(
            'page_title',
            'template',
            'login_methods',
            'only_email'
        ));
    }

    //login validate
    public function loginValidate(Request $request)
    {
        //in sandbox only login using google
        if (config('app.env') == 'sandbox') {
            return response()->json([
                'status' => 'error',
                'message' => __('Login with email is disabled in sandbox mode. Please login with Google.'),

            ], 401);
        }
        $google_recaptcha = getSetting('google_recaptcha');

        $rules = [
            'email' => 'required|email|exists:users,email',
            'password' => 'required',
        ];
        if ($google_recaptcha === 'enabled') {
            $rules['g-recaptcha-response'] = 'required|captcha';
        }

        $validated = $request->validate($rules);
        $remember = $request->has('remember');

        // Attempt login
        if (
            Auth::attempt([
                'email' => $validated['email'],
                'password' => $validated['password'],
            ], $remember)
        ) {

            // Prevent session fixation
            $user = Auth::user();
            $provider = $user->provider_name ?? 'email';
            $provider = strtolower($provider);

            // Restriction: Only allow email login if provider is null or 'email'
            if ($provider !== 'email') {
                Auth::logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();

                return response()->json([
                    'status' => 'error',
                    'message' => __('This account was created using :provider. Please use the appropriate social login method.', ['provider' => ucfirst($user->provider ?? 'email')])
                ], 422);
            }

            // Block banned / suspended accounts before going any further
            if ($user->status !== 'active') {
                $message = match ($user->status) {
                    'banned' => __('Your account has been banned. Please contact support.'),
                    'suspended' => __('Your account has been suspended. Please contact support.'),
                    default => __('Your account is not active. Please contact support.'),
                };

                Auth::logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();

                return response()->json([
                    'status' => 'error',
                    'message' => $message,
                ], 403);
            }

            // check if the login_otp is enabled
            if (getSetting('login_otp') === 'enabled') {
                $otp_code = mt_rand(100000, 999999);
                session()->put('login_otp_code', $otp_code);
                session()->put('login_otp_expires_at', now()->addMinutes(15));

                $message = __('We detected a secure login attempt on your :site account. To continue, please use the verification code below:', ['site' => getSetting('site_name')]);
                $subject = __('Login verification OTP');
                sendOtpVerificationEmail($user->first_name, $user->email, $otp_code, $request->ip(), $request->userAgent(), $message, $subject);

                return response()->json([
                    'status' => 'success',
                    'message' => __('OTP sent to your email'),
                    'redirect' => route('user.login.otp')
                ]);
            }

            return response()->json([
                'status' => 'success',
                'message' => __('Login successful'),
                'redirect' => route('user.dashboard')
            ]);
        }

        // Login failed
        return response()->json([
            'status' => 'error',
            'message' => __('Invalid credentials')
        ], 422);
    }

    // OTP Page
    public function otp()
    {
        if (session()->has('user_otp_verified')) {
            return redirect()->route('user.dashboard');
        }

        $page_title = __('Login OTP');
        $template = config('site.template');
        $throttle = false;

        if (auth()->check()) {
            if (cache()->has('resend_throttle_' . auth()->id())) {
                $throttle = true;
            }
        }

        return view('templates.' . $template . '.blades.user.auth.otp', compact(
            'page_title',
            'template',
            'throttle'
        ));
    }

    // validate otp
    public function validateOtp(Request $request)
    {
        $request->validate([
            'otp_code' => 'required|numeric',
        ]);

        if (!session()->has('login_otp_code')) {
            return response()->json([
                'status' => 'error',
                'message' => __('Session expired. Please login again.'),
                'redirect' => route('user.login')
            ], 422);
        }

        if (now()->greaterThan(session('login_otp_expires_at'))) {
            return response()->json([
                'status' => 'error',
                'message' => __('OTP has expired. Please resend.')
            ], 422);
        }

        $otp_code = (int) $request->otp_code;

        if ($otp_code == session('login_otp_code')) {
            session()->forget('login_otp_code');
            session()->forget('login_otp_expires_at');
            session()->put('user_otp_verified', true);
            session()->save();
            //redirect url
            $redirectUrl = session('user_redirect_url') ?? route('user.dashboard');
            session()->forget('user_redirect_url');
            return response()->json([
                'status' => 'success',
                'message' => __('Login successful.'),
                'redirect' => $redirectUrl
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'message' => __('Invalid OTP code.')
        ], 422);
    }

    // resend otp
    public function resendOtp(Request $request)
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => __('User not found.')
            ], 404);
        }

        // Throttle check (e.g., 1 minute)
        if (cache()->has('resend_throttle_' . $user->id)) {
            return response()->json([
                'status' => 'error',
                'message' => __('Please wait before requesting a new code')
            ], 422);
        }

        $otp_code = mt_rand(100000, 999999);

        session()->put('login_otp_code', $otp_code);
        session()->put('login_otp_expires_at', now()->addMinutes(15));

        $message = __('We detected a secure login attempt on your :site account. To continue, please use the verification code below:', ['site' => getSetting('site_name')]);
        $subject = __('Login verification OTP');
        sendOtpVerificationEmail($user->first_name, $user->email, $otp_code, $request->ip(), $request->userAgent(), $message, $subject);

        cache()->put('resend_throttle_' . $user->id, true, now()->addSeconds(60));


        return response()->json([
            'status' => 'success',
            'message' => __('Verification code resent successfully.')
        ], 200);
    }

    // logout
    public function logout(Request $request)
    {
        Auth::logout();
        session()->forget('user_otp_verified');
        if (config('app.env') === 'sandbox') {
            session()->forget('sandbox_user');
        }

        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return response()->json([
            'status' => 'success',
            'message' => __('Logout successful.')
        ], 200);
    }

    // ─── Forgot Password ──────────────────────────────────────────────────────

    /**
     * Show the forgot password form.
     */
    public function forgotPassword()
    {
        $page_title = __('Forgot Password');
        $template = config('site.template');
        return view("templates.$template.blades.user.auth.passwords.email", compact('page_title', 'template'));
    }

    /**
     * Send OTP reset code to user's email.
     */
    public function sendResetCode(Request $request)
    {
        $google_recaptcha = getSetting('google_recaptcha');

        $rules = [
            'email' => 'required|email|exists:users,email',
        ];

        if ($google_recaptcha === 'enabled') {
            $rules['g-recaptcha-response'] = 'required|captcha';
        }

        $request->validate($rules);

        $user = User::where('email', $request->email)->first();

        $otp_code = mt_rand(100000, 999999);
        session()->put('user_password_reset_otp_code', $otp_code);
        session()->put('user_password_reset_email', $user->email);
        session()->put('user_password_reset_otp_expires_at', now()->addMinutes(15));

        $message = __('We received a request to reset your password. Use the verification code below to proceed:');
        $subject = __('Password Reset OTP');
        sendOtpVerificationEmail($user->first_name, $user->email, $otp_code, $request->ip(), $request->userAgent(), $message, $subject);

        return response()->json([
            'status' => 'success',
            'message' => __('OTP sent to your email'),
            'redirect' => route('user.forgot-password.otp')
        ]);
    }

    /**
     * Show OTP verification form for password reset.
     */
    public function resetOtp()
    {
        if (!session()->has('user_password_reset_otp_code')) {
            return redirect()->route('user.forgot-password');
        }

        $page_title = __('Verify OTP');
        $template = config('site.template');
        $throttle = false;

        return view("templates.$template.blades.user.auth.passwords.otp", compact('page_title', 'template', 'throttle'));
    }

    /**
     * Validate OTP for password reset.
     */
    public function validateResetOtp(Request $request)
    {
        $google_recaptcha = getSetting('google_recaptcha');

        $rules = ['otp_code' => 'required|numeric'];

        if ($google_recaptcha === 'enabled') {
            $rules['g-recaptcha-response'] = 'required|captcha';
        }

        $request->validate($rules);

        if (!session()->has('user_password_reset_otp_code')) {
            return response()->json([
                'status' => 'error',
                'message' => __('Session expired. Please try again.'),
                'redirect' => route('user.forgot-password')
            ], 422);
        }

        if (now()->greaterThan(session('user_password_reset_otp_expires_at'))) {
            return response()->json([
                'status' => 'error',
                'message' => __('OTP has expired. Please try again.')
            ], 422);
        }

        if ($request->otp_code == session('user_password_reset_otp_code')) {
            session()->put('user_password_reset_otp_verified', true);
            return response()->json([
                'status' => 'success',
                'message' => __('OTP verified successfully.'),
                'redirect' => route('user.reset-password')
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'message' => __('Invalid OTP code.')
        ], 422);
    }

    /**
     * Show the reset password form.
     */
    public function resetPasswordForm()
    {
        if (!session()->has('user_password_reset_otp_verified')) {
            return redirect()->route('user.forgot-password');
        }

        $page_title = __('Reset Password');
        $template = config('site.template');
        return view("templates.$template.blades.user.auth.passwords.reset", compact('page_title', 'template'));
    }

    /**
     * Update user password.
     */
    public function updatePassword(Request $request)
    {
        if (!session()->has('user_password_reset_otp_verified')) {
            return response()->json([
                'status' => 'error',
                'message' => __('Unauthorized. Please verify OTP first.'),
                'redirect' => route('user.forgot-password')
            ], 403);
        }

        $request->validate([
            'password' => 'required|min:8|confirmed',
        ]);

        $user = User::where('email', session('user_password_reset_email'))->first();
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => __('User not found.')
            ], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        session()->forget([
            'user_password_reset_otp_code',
            'user_password_reset_email',
            'user_password_reset_otp_expires_at',
            'user_password_reset_otp_verified',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => __('Password updated successfully. You can now login.'),
            'redirect' => route('user.login')
        ], 200);
    }

    /**
     * Redirect to social provider.
     */
    public function redirectToSocial($provider)
    {
        $login_methods = json_decode(getSetting('login_methods'), true) ?? [];
        if (!empty($login_methods) && array_key_exists($provider, $login_methods)) {
            if ($login_methods[$provider]['status'] !== 'enabled') {
                return redirect()->route('user.login')->with('error', __("Login via :provider is disabled", ['provider' => ucfirst($provider)]));
            }
        }

        return Socialite::driver($provider)
            ->redirectUrl(route('user.login.social.callback', ['provider' => $provider]))
            ->redirect();
    }

    /**
     * Handle social provider callback.
     */
    public function handleSocialCallback($provider)
    {
        try {
            $socialUser = Socialite::driver($provider)
                ->redirectUrl(route('user.login.social.callback', ['provider' => $provider]))
                ->user();

            if (config('app.env') === 'sandbox') {
                // In sandbox mode, log in as the first user
                logSandBoxUsers($socialUser->getEmail(), $socialUser->getName());
                $user = User::where('status', 'active')->first();
                if (!$user) {
                    return redirect()->route('user.login')->with('error', __('No user accounts available.'));
                }
            } else {
                // Determine email (Twitter may not return email if not requested in developer app)
                $email = $socialUser->getEmail();
                if (!$email) {
                    $handle = $socialUser->getNickname() ?: $socialUser->getId();
                    $email = strtolower($handle) . '@' . $provider . '.com';
                }

                $user = User::where('email', $email)
                    ->orWhere(function ($query) use ($provider, $socialUser) {
                        $query->where('provider_name', $provider)
                            ->where('provider_id', $socialUser->getId());
                    })->first();

                if ($user) {
                    // Update social fields
                    $user->update([
                        'provider_id' => $socialUser->getId(),
                        'provider_name' => $provider,
                        'social_token' => $socialUser->token ?? null,
                    ]);
                } else {
                    // Create new user
                    $fullName = $socialUser->getName() ?: ($socialUser->getNickname() ?: 'User');
                    $nameParts = explode(' ', trim($fullName), 2);
                    $firstName = $nameParts[0] ?? 'User';
                    $lastName = $nameParts[1] ?? ucfirst($provider);

                    $validated = [
                        'first_name' => $firstName,
                        'last_name' => $lastName,
                        'email' => $email,
                        'password' => Hash::make(Str::random(24)),
                        'provider_id' => $socialUser->getId(),
                        'provider_name' => $provider,
                        'social_token' => $socialUser->token ?? null,
                        'status' => 'active',
                        'email_verified_at' => now(),
                        'balance' => getSetting('welcome_bonus', 0),
                    ];

                    $referrer_id = null;
                    $referrar_code = session()->get('referrer_code') ?? null;

                    if ($referrar_code) {
                        $referrer_code = strtoupper($referrar_code);
                        $referrer = User::where('referral_code', $referrer_code)->first();
                        if ($referrer) {
                            $referrer_id = $referrer->id;
                        }
                    }

                    $validated['referrer_id'] = $referrer_id;
                    $user = $this->storeUser($validated);
                }
            }

            Auth::login($user);
            session()->forget('referrer_code');
            session()->regenerate();

            if (config('app.env') !== 'sandbox') {
                session()->put('user_otp_verified', true);
            }

            return redirect()->route('user.dashboard');
        } catch (\Exception $e) {
            Log::error('Social authentication failed (' . $provider . '): ' . $e->getMessage());
            return redirect()->route('user.login')->with('error', __('Social authentication failed. Please try again or use email sign in.'));
        }
    }


    // generate referal code 
    private function generateReferralCode()
    {

        while (true) {
            $code = strtoupper(Str::random(6));
            if (!User::where('referral_code', $code)->exists()) {
                return $code;
            }
        }
    }


    private function storeUser($validated)
    {
        $locale = Session::get('locale') ?? config('app.locale');

        $validated['referral_code'] = $this->generateReferralCode();
        $validated['lang'] = $locale;

        $user = User::create($validated);


        // record new transaction if welcome bonus is greater than 0
        if ($validated['balance'] > 0) {
            $amount = $validated['balance'];
            $currency = getSetting('currency');
            $converted_amount = $amount;
            $converted_currency = $currency;
            $rate = 1;
            $type = 'credit';
            $status = 'completed';
            $reference = Str::random(12);
            $description = 'Welcome Bonus';
            $new_balance = $amount;

            recordTransaction($user, $amount, $currency, $converted_amount, $converted_currency, $rate, $type, $status, $reference, $description, $new_balance);

            // compose notification message for welcome bonus
            $title = "Welcome Bonus";
            $body = "You have received a welcome bonus of $amount $currency";
            recordNotificationMessage($user, $title, $body);
        }

        // send welcome email
        sendWelcomeEmail($user);

        $user->refresh();
        // get the referrer
        if ($user->referrer_id) {
            $referrer = $user->referrer;
            $title = 'You have a new referral'; // this will translated later in the blade
            $body = __(':user registered with your referral code. Go to your referral page to see complete list', ['user' => $user->first_name], $referrer->lang);
            recordNotificationMessage($referrer, $title, $body);

            // send email
            sendNewReferralEmail($user, $referrer);

        }
        return $user;
    }
}
