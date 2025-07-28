<?php

namespace App\Http\Controllers;

use App\Models\Operasional;
use Illuminate\Http\Request;

class OperasionalController extends Controller
{
    // Get all data
    public function index()
    {
        $data = Operasional::all();
        return response()->json($data);
    }

    // Store data
    public function store(Request $request)
    {
        $request->validate([
            'nama_item' => 'required|string|max:100',
            'tanggal' => 'required|date',
            'jenis_operasional' => 'required|in:pemasukan,pengeluaran',
            'nominal' => 'required|numeric',
            'keterangan' => 'nullable|string|max:100',
        ]);

        $operasional = Operasional::create($request->all());
        return response()->json($operasional, 201);
    }

    // Show single data
    public function show($id)
    {
        $operasional = Operasional::findOrFail($id);
        return response()->json($operasional);
    }

    // Update data
    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_item' => 'required|string|max:100',
            'tanggal' => 'required|date',
            'jenis_operasional' => 'required|in:pemasukan,pengeluaran',
            'nominal' => 'required|numeric',
            'keterangan' => 'nullable|string|max:100',
        ]);

        $operasional = Operasional::findOrFail($id);
        $operasional->update($request->all());

        return response()->json($operasional);
    }

    // Delete data
    public function destroy($id)
    {
        $operasional = Operasional::findOrFail($id);
        $operasional->delete();

        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
