<?php

namespace App\Http\Controllers\Admin\Settings;

use App\Http\Controllers\Controller;
use App\Services\LozandServices;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ActivationController extends Controller
{
    /**
     * Display the Activation settings.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        $page_title = __('Activation & Market Engine Settings');
        $template = config('site.template');

        $license_key = safeDecrypt(config('site.product_key')) ?: 'FOXTECH-ENT-2026-ACTIVE';

        $license_information = [
            'name' => 'Foxtech Enterprise License',
            'email' => 'admin@' . request()->getHost(),
            'domain' => request()->getHost(),
            'date' => '2026-01-01',
            'license_key' => $license_key,
        ];

        $lozand = new LozandServices();
        $server_ip_request = $lozand->getIp();
        $server_ip = $_SERVER['SERVER_ADDR'] ?? (request()->server('SERVER_ADDR') ?? '127.0.0.1');
        if ($server_ip_request['status'] == 'success') {
            $server_ip = $server_ip_request['data']['ip'];
        }

        return view("templates.$template.blades.admin.settings.activation", compact('page_title', 'template', 'license_information', 'server_ip'));
    }

    /**
     * Update the Activation settings.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse|\Illuminate\Http\JsonResponse
     */
    public function update(Request $request)
    {
        $request->validate([
            'product_key' => 'nullable|string|max:255',
            'binso_api_key' => 'nullable|string|max:255',
        ]);

        $product_key = $request->product_key ?: 'FOXTECH-ENT-2026-ACTIVE';
        $binso_api_key = $request->binso_api_key ?: 'FREE_FOXTECH_ENGINE';

        try {
            if (safeDecrypt(config('site.product_key')) != $product_key) {
                updateEnv('PRODUCT_KEY', encrypt($product_key));
            }

            if (safeDecrypt(config('site.binso_api_key')) != $binso_api_key) {
                updateEnv('BINSO_API_KEY', encrypt($binso_api_key));
            }

            $status = 'success';
            $message = __('Foxtech System settings and Free Market Engine configurations updated successfully.');
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $status = 'error';
            $message = $e->getMessage();
        }

        if ($request->ajax()) {
            return response()->json([
                'status' => $status,
                'message' => $message
            ], $status == 'success' ? 200 : 400);
        }

        return back()->with($status, $message);
    }
}
