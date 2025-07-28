<?php

namespace App\Http\Controllers;

use App\Models\DetailOrderProdukRilis;
use App\Models\order_produk_rilis;
use App\Models\ProdukRilis;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class DetailOrderProdukRilisController extends Controller
{
    public function index()
    {
        return response()->json(DetailOrderProdukRilis::with('order', 'produkRilis')->get());
    }

    public function show($id)
    {
        $detail = DetailOrderProdukRilis::with('order', 'produkRilis')->find($id);
        return $detail
            ? response()->json($detail)
            : response()->json(['message' => 'Detail order tidak ditemukan'], 404);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|exists:order_produk_rilis,id',
            'produk_rilis_id' => 'required|exists:produk_rilis,id',
            'jumlah_item' => 'required|integer|min:1',
            // harga_per_item tidak diinput manual
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Ambil harga dari tabel produk_rilis
        $produk = ProdukRilis::find($request->produk_rilis_id);
        if (!$produk) {
            return response()->json(['message' => 'Produk rilis tidak ditemukan'], 404);
        }

        $harga_per_item = $produk->harga;
        $subtotal = $request->jumlah_item * $harga_per_item;

        $detail = DetailOrderProdukRilis::create([
            'order_id' => $request->order_id,
            'produk_rilis_id' => $request->produk_rilis_id,
            'jumlah_item' => $request->jumlah_item,
            'harga_per_item' => $harga_per_item,
            'subtotal' => $subtotal,
        ]);

        $this->updateTotalHarga($request->order_id);

        return response()->json([
            'message' => 'Detail order berhasil ditambahkan',
            'data' => $detail
        ]);
    }

    public function update(Request $request, $id)
    {
        $detail = DetailOrderProdukRilis::find($id);
        if (!$detail) {
            return response()->json(['message' => 'Detail order tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'jumlah_item' => 'sometimes|required|integer|min:1',
            'produk_rilis_id' => 'sometimes|required|exists:produk_rilis,id',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $jumlah_item = $request->jumlah_item ?? $detail->jumlah_item;
        $produk_rilis_id = $request->produk_rilis_id ?? $detail->produk_rilis_id;

        // Ambil harga dari produk_rilis
        $produk = ProdukRilis::find($produk_rilis_id);
        if (!$produk) {
            return response()->json(['message' => 'Produk rilis tidak ditemukan'], 404);
        }

        $harga_per_item = $produk->harga;
        $subtotal = $jumlah_item * $harga_per_item;

        $detail->update([
            'produk_rilis_id' => $produk_rilis_id,
            'jumlah_item' => $jumlah_item,
            'harga_per_item' => $harga_per_item,
            'subtotal' => $subtotal,
        ]);

        $this->updateTotalHarga($detail->order_id);

        return response()->json([
            'message' => 'Detail order berhasil diperbarui',
            'data' => $detail
        ]);
    }

    public function destroy($id)
    {
        $detail = DetailOrderProdukRilis::find($id);
        if (!$detail) {
            return response()->json(['message' => 'Detail order tidak ditemukan'], 404);
        }

        $orderId = $detail->order_id;
        $detail->delete();

        $this->updateTotalHarga($orderId);

        return response()->json(['message' => 'Detail order berhasil dihapus']);
    }

    private function updateTotalHarga($orderId)
    {
        $total = DetailOrderProdukRilis::where('order_id', $orderId)->sum('subtotal');
        $order = order_produk_rilis::find($orderId);

        if ($order) {
            $order->total_harga = $total + ($order->ongkir ?? 0);
            $order->save();
        }
    }
}
