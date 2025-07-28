<?php

namespace App\Http\Controllers;

use App\Models\limit_produksi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LimitProduksiController extends Controller
{
    // Tampilkan semua data
    public function index()
    {
        return response()->json(limit_produksi::all());
    }

    // Tampilkan 1 data
    public function show($id)
    {
        $limit = limit_produksi::find($id);
        return $limit
            ? response()->json($limit)
            : response()->json(['message' => 'Limit produksi tidak ditemukan'], 404);
    }

    // Tambahkan data baru
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'jumlah_limit' => 'required|integer',
            'bulan' => 'required|integer|min:1|max:12',
            'tahun' => 'required|integer|min:1900|max:2100',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $limit = limit_produksi::create($request->all());

        return response()->json(['message' => 'Limit produksi berhasil ditambahkan', 'data' => $limit]);
    }

    // Update data
    public function update(Request $request, $id)
    {
        $limit = limit_produksi::find($id);
        if (!$limit) {
            return response()->json(['message' => 'Limit produksi tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'jumlah_limit' => 'sometimes|required|integer',
            'bulan' => 'sometimes|required|integer|min:1|max:12',
            'tahun' => 'sometimes|required|integer|min:1900|max:2100',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $limit->update($request->all());

        return response()->json(['message' => 'Limit produksi berhasil diperbarui', 'data' => $limit]);
    }

    // Hapus data
    public function destroy($id)
    {
        $limit = limit_produksi::find($id);
        if (!$limit) {
            return response()->json(['message' => 'Limit produksi tidak ditemukan'], 404);
        }

        $limit->delete();
        return response()->json(['message' => 'Limit produksi berhasil dihapus']);
    }
}
