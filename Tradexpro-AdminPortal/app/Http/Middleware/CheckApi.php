<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class CheckApi
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $lang = $request->header('lang') ?? 'en';
        try {
            app()->setLocale($lang);
        } catch (\Exception $e) {
            storeException('error', "lang key got: $lang");
            storeException('error', processExceptionMsg($e));
            app()->setLocale('en');
        }

        $rawOrigins = trim(env('FRONTEND_URL', ''));
        $allowedOrigins = !empty($rawOrigins) ? array_filter(array_map('trim', explode(',', $rawOrigins))) : [];
        $origin = $request->header('Origin');

        $apiKey = env('USER_API_SECRET_KEY', 'h0vWu6MkInNlWHJVfIXmHbIbC66cQvlbSUQI09Whbp');

        $rawIps = trim(env('ALLOWED_IPS', ''));
        $allowedIPs = !empty($rawIps) ? array_filter(array_map('trim', explode(',', $rawIps))) : [];

        // Conditions check
        $originAllowed = empty($allowedOrigins) || empty($origin) || in_array($origin, $allowedOrigins);
        $headerKeyMatches = ($request->header('userapisecret') && $request->header('userapisecret') === $apiKey) ||
                            ($request->header('userpublickey') && $request->header('userpublickey') === $apiKey);
        $ipAllowed = empty($allowedIPs) || in_array($request->ip(), $allowedIPs);

        // Final check
        if ($originAllowed || $headerKeyMatches || $ipAllowed) {
            return $next($request);
        }

        return response()->json(['error' => 'Unaccessable', 'success' => false, 'message' => __('Access denied')], 403);

    }
}
