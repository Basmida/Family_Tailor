<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use App\Models\Layanan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LayananController extends Controller
{
    public function index()
    {
        return response()->json(Layanan::with('customer')->get());
    }

    public function show($id)
    {
        $layanan = Layanan::find($id);
        return $layanan
            ? response()->json($layanan)
            : response()->json(['message' => 'Data tidak ditemukan'], 404);
    }



    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'customer_id' => 'required|exists:customers,id',
            'jenis_layanan' => 'required|in:custom,perbaikan,modifikasi,aksesoris',
            'harga' => 'required|numeric',
            'waktu_layanan' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $created_at = Carbon::now();
        $estimasi_selesai = $created_at->copy()->addDays($request->waktu_layanan);

        $layanan = Layanan::create([
            'customer_id' => $request->customer_id,
            'jenis_layanan' => $request->jenis_layanan,
            'harga' => $request->harga,
            'waktu_layanan' => $request->waktu_layanan,
            'estimasi_selesai' => $estimasi_selesai,
            'created_at' => $created_at,
            'updated_at' => $created_at,
        ]);

        return response()->json([
            'message' => 'Layanan berhasil dibuat',
            'data' => $layanan
        ]);
    }


    public function update(Request $request, $id)
    {
        $layanan = Layanan::find($id);
        if (!$layanan) {
            return response()->json(['message' => 'Data layanan tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'jenis_layanan' => 'in:custom,perbaikan,modifikasi,aksesoris',
            'harga' => 'numeric',
            'waktu_layanan' => 'integer|in:1,2,3',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $layanan->fill($request->all());

        if ($request->has('waktu_layanan')) {
            $estimasi_selesai = $layanan->created_at->copy()->addDays($request->waktu_layanan);
            $layanan->estimasi_selesai = $estimasi_selesai;
        }

        $layanan->save();

        return response()->json([
            'message' => 'Layanan berhasil diperbarui',
            'data' => $layanan
        ]);
    }


    public function destroy($id)
    {
        $layanan = Layanan::find($id);
        if (!$layanan) {
            return response()->json(['message' => 'Data tidak ditemukan'], 404);
        }

        $layanan->delete();
        return response()->json(['message' => 'Data layanan berhasil dihapus']);
    }
}
