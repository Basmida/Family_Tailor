<?php

namespace App\Http\Controllers;

use App\Models\OrderKatalog;
use App\Models\Katalog;
use App\Models\UkuranBadan;
use Illuminate\Http\Request;

use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class OrderKatalogController extends Controller
{
    public function index()
    {
        return response()->json(OrderKatalog::with('customer', 'katalog', 'ukuranBadan')->get());
    }


    public function store(Request $request)
    {
        try {
            $request->validate([
                'id_customer' => 'required|exists:customers,id',
                'id_produk_katalog' => 'required|exists:katalog,id',
                'jadwal_ukur_badan' => 'required|date',
                'metode_pembayaran' => 'required|in:bayar_ditempat,transfer',
                'sumber_bahan' => 'required|in:pelanggan,penjahit',
            ]);

            $produk = Katalog::findOrFail($request->id_produk_katalog);
            $durasi = $request->input('durasi_estimasi', 7);

            if ($durasi == 2) {
                $totalHarga = $produk->harga_maksimum;
            } elseif ($durasi == 4) {
                $totalHarga = ($produk->harga_maksimum + $produk->harga_minimum) / 2;
            } else {
                $totalHarga = $produk->harga_minimum;
            }

            $estimasiSelesai = Carbon::parse($request->jadwal_ukur_badan)->addDays($durasi);

            $order = OrderKatalog::create([
                'id_customer' => $request->id_customer,
                'id_produk_katalog' => $request->id_produk_katalog,
                'jadwal_ukur_badan' => $request->jadwal_ukur_badan,
                'metode_pembayaran' => $request->metode_pembayaran,
                'sumber_bahan' => $request->sumber_bahan,
                'durasi_estimasi' => $durasi,
                'total_harga' => $totalHarga,
                'estimasi_selesai' => $estimasiSelesai,
                'status' => 'diantrian',
                'id_ukuran_badan' => null
            ]);

            return response()->json([
                'message' => 'Order katalog berhasil dibuat',
                'data' => $order
            ], 201);
        } catch (\Exception $e) {
            Log::error('Store OrderKatalog Error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Terjadi kesalahan saat membuat order',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    //simpan ukuran badan
    public function updateUkuranBadan(Request $request, $id)
    {
        try {
            // 1. Validasi data
            $request->validate([
                'durasi_estimasi' => 'required|integer',
                // Tambahkan validasi untuk ukuran badan jika perlu
            ]);

            // 2. Cari order
            $order = OrderKatalog::findOrFail($id);

            // 3. Simpan data ukuran badan
            $ukuran = UkuranBadan::create([
                'id_customer' => $order->id_customer, // jika ingin menyimpan ID customer juga
                'lingkar_dada' => $request->lingkar_dada,
                'lebar_depan' => $request->lebar_depan,
                'lebar_pundak' => $request->lebar_pundak,
                'panjang_depan' => $request->panjang_depan,
                'lingkar_panggul' => $request->lingkar_panggul,
                'tinggi_nat' => $request->tinggi_nat,
                'lebar_nat' => $request->lebar_nat,
                'panjang_baju' => $request->panjang_baju,
                'lingkar_pinggang' => $request->lingkar_pinggang,
                'panjang_lengan' => $request->panjang_lengan,
                'lingkar_tangan' => $request->lingkar_tangan,
                'panjang_rok' => $request->panjang_rok,
            ]);

            // 4. Update order
            $order->id_ukuran_badan = $ukuran->id;
            $order->durasi_estimasi = $request->durasi_estimasi;

            // ✅ Perbaikan di sini: gunakan jadwal_ukur_badan sebagai dasar
            $order->estimasi_selesai = Carbon::parse($order->jadwal_ukur_badan)
                ->addDays($request->durasi_estimasi);

            $order->save();

            return response()->json([
                'message' => 'Ukuran badan berhasil ditambahkan ke order',
                'data' => $order,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal menambahkan ukuran badan',
                'error' => $e->getMessage()
            ], 500);
        }
    }







    public function show($id)
    {
        $order = OrderKatalog::with('customer', 'katalog', 'ukuranBadan')->find($id);
        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }
        return response()->json($order);
    }

    public function update(Request $request, $id)
    {
        $order = OrderKatalog::findOrFail($id);

        $request->validate([
            'status' => 'nullable|in:diantrian,diproses,diambil,selesai',
        ]);

        // Hanya update status jika ada status yang diberikan
        if ($request->has('status')) {
            $order->status = $request->status;
        }

        $order->save();

        return response()->json([
            'message' => 'Status order katalog berhasil diupdate',
            'data' => $order
        ]);
    }

    public function updatePembayaran(Request $request, $id)
    {
        $order = OrderKatalog::findOrFail($id);

        $request->validate([
            'status_pembayaran' => 'required|in:belum_lunas,lunas',
        ]);

        $order->status_pembayaran = $request->status_pembayaran;
        $order->save();

        return response()->json([
            'message' => 'Status pembayaran berhasil diperbarui',
            'data' => $order
        ]);
    }



    public function destroy($id)
    {
        $order = OrderKatalog::find($id);
        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }

        $order->delete();
        return response()->json(['message' => 'Order berhasil dihapus']);
    }
}
