<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PesananController extends Controller
{
    public function index(Request $request)
    {
        $customerId = $request->query('customer_id');

        try {
            // ✅ Ambil semua pesanan katalog + gambar produk katalog + estimasi selesai
            $orderKatalog = DB::table('order_katalog as ok')
                ->join('katalog as k', 'ok.id_produk_katalog', '=', 'k.id')
                ->select(
                    'ok.id as order_id',
                    'ok.id_customer',
                    'k.nama_produk',
                    'k.gambar as gambar',
                    'ok.jadwal_ukur_badan',
                    'ok.total_harga',
                    'ok.estimasi_selesai', // ✅ Tambahkan
                    'ok.status',
                    DB::raw("COALESCE(ok.status_pembayaran, 'belum_lunas') as status_pembayaran"),
                    'ok.created_at'
                )
                ->where('ok.id_customer', $customerId)
                ->orderBy('ok.created_at', 'desc')
                ->get();

            // ✅ Ambil semua pesanan produk rilis + gambar produk rilis + estimasi tiba min/max
            $orderProdukRilis = DB::table('order_produk_rilis as opr')
                ->join('detail_order_produk_rilis as dpr', 'opr.id', '=', 'dpr.order_id')
                ->join('produk_rilis as pr', 'dpr.produk_rilis_id', '=', 'pr.id')
                ->select(
                    'opr.id as order_id',
                    'opr.id_customer',
                    'opr.total_harga',
                    'opr.status',
                    'opr.status_pembayaran',
                    'opr.created_at',
                    'pr.nama_produk',
                    'pr.gambar as gambar',
                    'dpr.jumlah_item',
                    'dpr.harga_per_item',
                    'dpr.subtotal',
                    'opr.estimasi_tiba_min', // ✅ Tambahkan
                    'opr.estimasi_tiba_max'  // ✅ Tambahkan
                )
                ->where('opr.id_customer', $customerId)
                ->orderBy('opr.created_at', 'desc')
                ->get();

            return response()->json([
                'message' => 'Data pesanan berhasil diambil',
                'data' => [
                    'order_katalog' => $orderKatalog,
                    'order_produk_rilis' => $orderProdukRilis
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('PesananController Error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Terjadi kesalahan',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
