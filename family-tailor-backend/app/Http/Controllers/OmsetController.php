<?php

// app/Http/Controllers/OmsetController.php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OmsetController extends Controller
{
    public function getOmset(Request $request)
    {
        $filter = $request->query('filter'); // "Hari ini", "Minggu ini", "Bulan ini"
        $startDate = now();
        $endDate = now();

        if ($filter === 'Hari ini') {
            $startDate = now()->startOfDay();
        } elseif ($filter === 'Minggu ini') {
            $startDate = now()->startOfWeek();
        } elseif ($filter === 'Bulan ini') {
            $startDate = now()->startOfMonth();
        } elseif ($filter === 'Tahun ini') {
            $startDate = now()->startOfYear(); // 🆕 Tambahan
        }

        $totalProdukRilis = DB::table('order_produk_rilis')
            ->where('status_pembayaran', 'lunas')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('total_harga');

        $totalKatalog = DB::table('order_katalog')
            ->where('status_pembayaran', 'lunas')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('total_harga');

        $operasional = DB::table('operasional')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->select('jenis_operasional', 'nominal')
            ->get();

        $pemasukanOperasional = $operasional->where('jenis_operasional', 'pemasukan')->sum('nominal');
        $pengeluaranOperasional = $operasional->where('jenis_operasional', 'pengeluaran')->sum('nominal');

        return response()->json([
            'pemasukan' => $totalProdukRilis + $totalKatalog + $pemasukanOperasional,
            'pengeluaran' => $pengeluaranOperasional
        ]);
    }

    public function getDetailOmset(Request $request)
    {
        $filter = $request->query('filter'); // "Hari ini", "Minggu ini", dst
        $tipe = $request->query('tipe');     // "semua", "transaksi", "lain-lain"

        $startDate = now();
        $endDate = now();

        if ($filter === 'Hari ini') {
            $startDate = now()->startOfDay();
        } elseif ($filter === 'Minggu ini') {
            $startDate = now()->startOfWeek();
        } elseif ($filter === 'Bulan ini') {
            $startDate = now()->startOfMonth();
        } elseif ($filter === 'Tahun ini') {
            $startDate = now()->startOfYear();
        }

        $detail = [];

        if ($tipe === 'semua' || $tipe === 'transaksi') {
            $produkRilis = DB::table('order_produk_rilis')
                ->where('status_pembayaran', 'lunas')
                ->whereBetween('created_at', [$startDate, $endDate])
                ->get();

            $katalog = DB::table('order_katalog')
                ->where('status_pembayaran', 'lunas')
                ->whereBetween('created_at', [$startDate, $endDate])
                ->get();

            $detail['order_produk_rilis'] = $produkRilis;
            $detail['order_katalog'] = $katalog;
        }

        if ($tipe === 'semua' || $tipe === 'lain-lain') {
            $operasional = DB::table('operasional')
                ->whereBetween('created_at', [$startDate, $endDate])
                ->get();

            $detail['operasional'] = $operasional;
        }

        return response()->json($detail);
    }
}
