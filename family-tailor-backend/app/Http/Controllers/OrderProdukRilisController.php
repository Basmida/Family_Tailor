<?php

namespace App\Http\Controllers;

use App\Models\DetailOrderProdukRilis;
use App\Models\order_produk_rilis;
use App\Models\ProdukRilis;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;


class OrderProdukRilisController extends Controller
{
    public function checkout(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_customer' => 'required|exists:customers,id',
            'metode_pengiriman' => 'required|in:ambil di tempat,diantar ke alamat',
            'metode_pembayaran' => 'required|in:bayar ditempat,transfer',
            'zona' => 'required|in:dalam kota,luar kota',
            'items' => 'required|array|min:1',
            'items.*.produk_rilis_id' => 'required|exists:produk_rilis,id',
            'items.*.jumlah_item' => 'required|integer|min:1',
        ]);

        
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $ongkir = $request->zona === 'dalam kota' ? 15000 : 25000;

        $estimasiMin = Carbon::now()->addDays(3)->toDateString();
        $estimasiMax = Carbon::now()->addDays(7)->toDateString();

        // ✅ 1. Buat order utama
        $order = order_produk_rilis::create([
            'id_customer' => $request->id_customer,
            'metode_pengiriman' => $request->metode_pengiriman,
            'metode_pembayaran' => $request->metode_pembayaran,
            'status' => 'diantrian',
            'zona' => $request->zona,
            'ongkir' => $ongkir,
            'total_harga' => 0,
            'estimasi_tiba_min' => $estimasiMin,
            'estimasi_tiba_max' => $estimasiMax,
        ]);

        $totalHarga = 0;

        // ✅ 2. Simpan detail produk
        foreach ($request->items as $item) {
            $produk = ProdukRilis::find($item['produk_rilis_id']);
            $subtotal = $produk->harga * $item['jumlah_item'];

            DetailOrderProdukRilis::create([
                'order_id' => $order->id,
                'produk_rilis_id' => $item['produk_rilis_id'],
                'jumlah_item' => $item['jumlah_item'],
                'harga_per_item' => $produk->harga,
                'subtotal' => $subtotal,
            ]);

            $totalHarga += $subtotal;
        }

        // ✅ 3. Update total harga
        $order->total_harga = $totalHarga + $ongkir;
        $order->save();

        return response()->json([
            'message' => 'Checkout berhasil',
            'order' => $order,
            'total_harga' => $order->total_harga
        ]);
    }


    public function index()
    {
        return response()->json(order_produk_rilis::all());
    }

    public function show($id)
    {
        $order = order_produk_rilis::with([
            'customer',
            'detailOrders.produkRilis'
        ])->find($id);

        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }

        return response()->json($order);
    }


    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_customer' => 'required|exists:customers,id',
            'metode_pengiriman' => 'required|in:ambil di tempat,diantar ke alamat',
            'metode_pembayaran' => 'required|in:bayar ditempat,transfer',
            'zona' => 'required|in:dalam kota,luar kota',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $ongkir = $request->zona === 'dalam kota' ? 15000 : 25000;

        $estimasiMin = Carbon::now()->addDays(3)->toDateString();
        $estimasiMax = Carbon::now()->addDays(7)->toDateString();

        $order = order_produk_rilis::create([
            'id_customer' => $request->id_customer,
            'metode_pengiriman' => $request->metode_pengiriman,
            'metode_pembayaran' => $request->metode_pembayaran,
            'status' => 'diantrian',
            'zona' => $request->zona,
            'ongkir' => $ongkir,
            'total_harga' => 0,
            'estimasi_tiba_min' => $estimasiMin,
            'estimasi_tiba_max' => $estimasiMax,
        ]);

        return response()->json([
            'message' => 'Order berhasil dibuat, silahkan tambahkan detail produk',
            'data' => $order
        ]);
    }



    public function update(Request $request, $id)
    {
        $order = order_produk_rilis::find($id);
        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'id_customer' => 'sometimes|exists:customers,id',
            'metode_pengiriman' => 'sometimes|in:ambil di tempat,diantar ke alamat',
            'metode_pembayaran' => 'sometimes|in:bayar ditempat,transfer',
            'status' => 'sometimes|in:diantrian,dikirim,selesai',
            'zona' => 'sometimes|in:dalam kota,luar kota',
            'ongkir' => 'sometimes|numeric',
            'total_harga' => 'sometimes|numeric',
            'estimasi_tiba_min' => 'sometimes|date',
            'estimasi_tiba_max' => 'sometimes|date',

        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $order->update($request->all());

        return response()->json(['message' => 'Order berhasil diupdate', 'data' => $order]);
    }

    public function destroy($id)
    {
        $order = order_produk_rilis::find($id);
        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }

        $order->delete();

        return response()->json(['message' => 'Order berhasil dihapus']);
    }


    //update status oleh admin
    public function updateStatus(Request $request, $id)
    {
        $order = order_produk_rilis::find($id);
        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:diantrian,dikirim,selesai',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $order->status = $request->status;
        $order->save();

        return response()->json([
            'message' => 'Status order berhasil diperbarui',
            'data' => $order
        ]);
    }

    public function updateStatusPembayaran(Request $request, $id)
    {
        $request->validate([
            'status_pembayaran' => 'required|in:belum_lunas,lunas',
        ]);

        $order = order_produk_rilis::findOrFail($id);
        $order->status_pembayaran = $request->status_pembayaran;
        $order->save();

        return response()->json([
            'message' => 'Status pembayaran berhasil diupdate',
            'data' => $order
        ]);
    }

    //CANCEL ORDERAN
    public function cancel($id)
    {
        $order = order_produk_rilis::findOrFail($id);
        $order->status = 'dibatalkan';
        $order->save();

        return response()->json(['message' => 'Pesanan berhasil dibatalkan']);
    }
}
