<?php

namespace App\Http\Controllers;

use App\Models\StokBahanBaku;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class StokBahanBakuController extends Controller
{
    public function index()
    {
        return response()->json(StokBahanBaku::all());
    }

    //MENAMPILKAN PRODUK YANG TELAH DITAMBAHKAN
    public function show($id)
    {
        $bahan = StokBahanBaku::find($id);
        return $bahan
            ? response()->json($bahan)
            : response()->json(['message' => 'bahan tidak ditemukan'], 404);
    }

    //MENAMBAHKAN DATA BAHAN BAKU
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_bahan' => 'required|max:50',
            'tanggal_masuk' => 'required|date',
            'jumlah' => 'required|integer',
            'satuan' => 'required|in:meter,pcs,lusin',
            'harga_beli' => 'required|integer',

        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $data = $request->all();


        $bahan = StokBahanBaku::create($data);

        return response()->json(['message' => 'Produk berhasil ditambahkan', 'data' => $bahan]);
    }

    //MENGUPDATE DATA PRODUK YANG TELAH DITAMBAHKAN
    public function update(Request $request, $id)
    {
        $bahan = StokBahanBaku::find($id);
        if (!$bahan) return response()->json(['message' => 'bahan tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'nama_bahan' => 'sometimes|required|max:50',
            'tanggal_masuk' => 'sometimes|required|date',
            'jumlah' => 'sometimes|required|integer',
            'satuann' => 'sometimes|required|in:meter,pcs,lusin',
            'harga_beli' => 'sometimes|required|integer',

        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $data = $request->json()->all(); // Kalau mau format json
        // $data = $request->all(); // bisa pakai form data

        //UNTUK DEBUGGING
        /*  Log::info('Data diterima untuk update:', $data);
        Log::info('Seluruh isi request:', [
            'all' => $request->all(),
            'isJson' => $request->isJson(),
            'contentType' => $request->header('Content-Type')
        ]); */
        $bahan->update($data);

        return response()->json(['message' => 'bahan berhasil diperbarui', 'data' => $bahan]);
    }

    public function destroy($id)
    {
        $bahan = StokBahanBaku::find($id);
        if (!$bahan) {
            return response()->json(['message' => 'bahan tidak ditemukan'], 404);
        }

        $bahan->delete();
        return response()->json(['message' => 'bahan berhasil dihapus']);
    }
}
