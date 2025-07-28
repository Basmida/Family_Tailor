<?php

namespace App\Http\Controllers;

use App\Models\order_produk_rilis;
use App\Models\OrderKatalog;
use Illuminate\Http\Request;
use Midtrans\Config;
use Midtrans\Snap;

class MidtransController extends Controller
{
    public function getSnapToken(Request $request)
    {
        // Coba cari di order produk rilis
        $order = order_produk_rilis::with('customer')->find($request->order_id);

        // Kalau tidak ditemukan, coba cari di order katalog
        if (!$order) {
            $order = OrderKatalog::with('customer')->find($request->order_id);
        }

        // Kalau tetap tidak ditemukan
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order tidak ditemukan'
            ], 404);
        }

        $params = [
            'transaction_details' => [
                'order_id' => 'ORDER-' . $order->id, // Tambahkan prefix biar tidak bentrok ID-nya
                'gross_amount' => (int) $order->total_harga,
            ],
            'customer_details' => [
                'first_name' => $order->customer->nama ?? $order->customer->name,
                'email' => $order->customer->email ?? 'customer@email.com',
            ],
        ];

        \Midtrans\Config::$serverKey = config('midtrans.server_key');
        \Midtrans\Config::$isProduction = false;
        \Midtrans\Config::$isSanitized = true;
        \Midtrans\Config::$is3ds = true;

        $snapToken = \Midtrans\Snap::getSnapToken($params);

        return response()->json([
            'success' => true,
            'token' => $snapToken,
        ]);
    }
}
