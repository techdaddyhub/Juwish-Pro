<?php

namespace App\Http\Controllers\User\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Hash;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Auth;

class RegisterController extends Controller
{
    //register page index
    public function index()
    {
        $page_title = __('Register');
        $template = config('site.template');

        // check if it has refferal code in the request
        if (request()->has('ref')) {
            $referrer_code = strtoupper(request()->ref);
            session()->put('referrer_code', $referrer_code);
        }

        $throttle = false;
        if (session('register_info')) {
            $otp_id = session('register_info')['otp_id'];
            if (cache()->has('resend_throttle_' . $otp_id)) {
                $throttle = true;
            }
        }

        // Restrict registration methods strictly to Google and Email
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

        return view("templates.$template.blades.user.auth.register", compact('page_title', 'throttle', 'login_methods', 'only_email'));
    }


    // validate registration
    public function registerValidate(Request $request)
    {
        //in sandbox only login using google
        if (config('app.env') == 'sandbox') {
            return response()->json([
                'status' => 'error',
                'message' => __('Registration with email is disabled in sandbox mode. Please register with Google.'),

            ], 401);
        }
        $google_recaptcha = getSetting('google_recaptcha');

        $rules = [
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users',
            'password' => validPassword(),
            'referral_code' => 'nullable|string|max:255',
        ];

        if ($google_recaptcha === 'enabled') {
            $rules['g-recaptcha-response'] = 'required|captcha';
        }

        $validated = $request->validate($rules);

        $referrer_id = null;

        $referrar_code = session()->get('referrer_code') ?? $request->referral_code ?? null;

        // check if the referral code is valid and get the referrer
        if ($referrar_code) {
            $referrer_code = strtoupper($referrar_code);
            $referrer = User::where('referral_code', $referrer_code)->first();
            if ($referrer) {
                $referrer_id = $referrer->id;
            }
        }

        $validated['referrer_id'] = $referrer_id;
        $validated['balance'] = getSetting('welcome_bonus');

        // generate unique id for this registration attempt from the email address
        $validated['otp_id'] = str_replace(['.', '@', '+'], '_', $validated['email']);

        session()->put('register_info', $validated);

        // register the user email verification is not required
        if (getSetting('email_verification') === 'disabled') {
            $this->storeUser($validated);
            return response()->json([
                'status' => 'success',
                'message' => __('Registration successful')
            ]);
        }


        // generate otp code, numeric 6 digit
        $otp_code = mt_rand(100000, 999999);

        // store the otp code in cache for 15 minutes
        cache()->put('otp_' . $validated['otp_id'], $otp_code, now()->addMinutes(15));

        // send verification email
        sendVerificationEmail($validated['first_name'], $validated['email'], $otp_code);

        // set throttle for 60 seconds for initial send
        cache()->put('resend_throttle_' . $validated['otp_id'], true, now()->addSeconds(60));

        return response()->json([
            'status' => 'success',
            'message' => __('Registration successful, please verify your email')
        ]);


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


    // store the user
    private function storeUser($validated)
    {
        $locale = Session::get('locale') ?? config('app.locale');
        $user = new User();
        $user->first_name = $validated['first_name'];
        $user->last_name = $validated['last_name'];
        $user->email = $validated['email'];
        $user->password = Hash::make($validated['password']);
        $user->referral_code = $this->generateReferralCode();
        $user->referrer_id = $validated['referrer_id'];
        $user->balance = $validated['balance'];
        $user->lang = $locale;
        $user->save();


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


        // remove validated data from session
        session()->forget('register_info');

        // forget referral code from session
        session()->forget('referrer_code');

        // automatically log the user in
        Auth::login($user);

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


    // Email verification
    public function emailVerification(Request $request)
    {
        $rules = [
            'email' => 'required|email|max:255',
            'otp_code' => 'required|digits:6',
        ];

        $validated = $request->validate($rules);

        $otp_id = str_replace(['.', '@', '+'], '_', $validated['email']);

        $otp_code = cache()->get('otp_' . $otp_id);

        if (!$otp_code) {
            return response()->json(['status' => 'error', 'message' => __('Invalid or expired OTP code')]);
        }

        // cast the validated otp to int
        $validated['otp_code'] = (int) $validated['otp_code'];
        if ($otp_code !== $validated['otp_code']) {

            return response()->json(['status' => 'error', 'message' => __('Invalid OTP code')]);
        }

        $register_info = session()->get('register_info');

        $user = $this->storeUser($register_info);

        // update the email_verified_at
        $user->email_verified_at = now();
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => __('Registration successful'),
            'redirect' => url('user/dashboard')
        ]);
    }

    // Resend verification code
    public function resendVerification(Request $request)
    {
        $register_info = session()->get('register_info');

        if (!$register_info) {
            return response()->json([
                'status' => 'error',
                'message' => __('Session expired, please register again'),
                'action' => 'redirect',
                'redirect_to' => route('user.register')
            ]);
        }

        // Throttle check (e.g., 1 minute)
        if (cache()->has('resend_throttle_' . $register_info['otp_id'])) {
            return response()->json([
                'status' => 'error',
                'message' => __('Please wait before requesting a new code')
            ]);
        }

        // generate otp code, numeric 6 digit
        $otp_code = mt_rand(100000, 999999);

        // store the otp code in cache for 15 minutes
        cache()->put('otp_' . $register_info['otp_id'], $otp_code, now()->addMinutes(15));

        // set throttle for 60 seconds
        cache()->put('resend_throttle_' . $register_info['otp_id'], true, now()->addSeconds(60));

        // send verification email 
        sendVerificationEmail($register_info['first_name'], $register_info['email'], $otp_code);

        return response()->json([
            'status' => 'success',
            'message' => __('Verification code resent successfully.')
        ]);
    }

    // Cancel registration and clear session
    public function registerCancel()
    {
        session()->forget('register_info');

        return response()->json([
            'status' => 'success',
            'message' => __('Registration cancelled'),
            'action' => 'redirect',
            'redirect_to' => route('user.register')
        ]);
    }

}
