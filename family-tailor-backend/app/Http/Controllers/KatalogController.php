<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Katalog;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class KatalogController extends Controller
{
    public function index()
    {
        return response()->json(Katalog::all());
    }

    public function show($id)
    {
        $produk = Katalog::find($id);
        return $produk
            ? response()->json($produk)
            : response()->json(['message' => 'data tidak ditemukan'], 404);
    }

    public function store(Request $request)
    {
        $validasi = Validator::make($request->all(), [
            'nama_produk' => 'required|max:25',
            'gambar' => 'nullable|image|mimes:png,jpg,jpeg|max:2048',
            'deskripsi_produk' => 'required|max:255',
            'spesifikasi' => 'required|max:255',
            'harga_minimum' => 'required|integer',
            'harga_maksimum' => 'required|integer',
            'keterangan' => 'nullable|max:255',
        ]);

        if ($validasi->fails()) {
            return response()->json($validasi->errors(), 422);
        }

        $data = $request->all();

        if ($request->hasFile('gambar')) {
            $data['gambar'] = $request->file('gambar')->store('katalog', 'public');
        }

        $produk = Katalog::create($data);

        return response()->json(['message' => 'Produk berhasil ditambahkan', 'data' => $produk]);
    }

    public function update(Request $request, $id)
    {
        $katalog = Katalog::findOrFail($id);
        $katalog->nama_produk = $request->nama_produk;
        $katalog->deskripsi_produk = $request->deskripsi_produk;
        $katalog->spesifikasi = $request->spesifikasi;
        $katalog->harga_minimum = $request->harga_minimum;
        $katalog->harga_maksimum = $request->harga_maksimum;
        $katalog->keterangan = $request->keterangan;
        // Jika ada file gambar yang diunggah
        if ($request->hasFile('gambar')) {
            // Hapus gambar lama jika ada
            if ($katalog->gambar) {
                Storage::disk('public')->delete($katalog->gambar);
            }
            // Simpan gambar baru
            $katalog->gambar = $request->file('gambar')->store('katalog', 'public');
        }
        $katalog->save();
        return response()->json(['message' => 'Katalog berhasil diperbarui'], 200);
    }

    
    public function destroy($id)
    {
        $produk = Katalog::find($id);
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
