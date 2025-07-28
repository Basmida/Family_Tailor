<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ProdukRilis;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProdukRilisController extends Controller
{
    // TAMPILKAN SEMUA PRODUK
    public function index()
    {
        return response()->json(ProdukRilis::all());
    }

    // TAMPILKAN 1 PRODUK BERDASARKAN ID
    public function show($id)
    {
        $produk = ProdukRilis::find($id);
        return $produk
            ? response()->json($produk)
            : response()->json(['message' => 'Produk tidak ditemukan'], 404);
    }

    // TAMBAH PRODUK RILIS
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'required|max:25',
            'harga' => 'required|integer',
            'gambar' => 'nullable|image|mimes:png,jpg,jpeg|max:2048',
            'ukuran' => 'required|in:S,M,L,XL',
            'spesifikasi' => 'required|max:255',
            'deskripsi_produk' => 'required|max:255',
            'keterangan' => 'nullable|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $data = $request->all();

        if ($request->hasFile('gambar')) {
            $data['gambar'] = $request->file('gambar')->store('produk_rilis', 'public');
        }

        $produk = ProdukRilis::create($data);

        return response()->json([
            'message' => 'Produk berhasil ditambahkan',
            'data' => $produk
        ]);
    }

    // UPDATE PRODUK RILIS
    public function update(Request $request, $id)
    {
        $produk = ProdukRilis::findOrFail($id);
        $produk->nama_produk = $request->nama_produk;
        $produk->harga = $request->harga;
        $produk->ukuran = $request->ukuran;
        $produk->spesifikasi = $request->spesifikasi;
        $produk->deskripsi_produk = $request->deskripsi_produk;
        $produk->keterangan = $request->keterangan;
        //JIKA ADA FILE GAMBAR YANG DIUNGGAH
        if ($request->hasFile('gambar')) {
            // Hapus gambar lama jika ada
            if ($produk->gambar) {
                Storage::disk('public')->delete($produk->gambar);
            }
            // Simpan gambar baru
            $produk->gambar = $request->file('gambar')->store('produk', 'public');
        }
        $produk->save();
        return response()->json(['message' => 'Produk berhasil diperbarui'], 200);
    }

    // HAPUS PRODUK RILIS
    public function destroy($id)
    {
        $produk = ProdukRilis::find($id);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        if ($produk->gambar) {
            Storage::disk('public')->delete($produk->gambar);
        }

        $produk->delete();
        return response()->json(['message' => 'Produk berhasil dihapus']);
    }
}
