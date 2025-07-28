<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Customer;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class CustomerAuthController extends Controller
{
    // GET SEMUA CUSTOMER
    public function getAllCustomers()
    {
        $customers = Customer::select('id', 'nama', 'no_hp', 'alamat')->get();

        return response()->json($customers);
    }
    // GET CUSTOMER BY ID
    // GET CUSTOMER YANG SEDANG LOGIN
    public function getCustomer(Request $request)
    {
        $customer = $request->user(); // ini otomatis ambil dari token sanctum

        if ($customer) {
            return response()->json([
                'message' => 'Data customer ditemukan',
                'customer' => [
                    'id' => $customer->id,
                    'nama' => $customer->nama,
                    'email' => $customer->email,
                    'no_hp' => $customer->no_hp,
                    'alamat' => $customer->alamat,
                ]
            ]);
        }

        return response()->json(['message' => 'Customer tidak ditemukan'], 404);
    }


    // CUSTOMER REGISTER
    public function register(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:25',
            'email' => 'required|email|unique:customers,email',
            'no_hp' => 'required|max:13',
            'alamat' => 'required|max:150',
            'password' => 'required|string|min:6',
        ]);

        $customer = Customer::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'no_hp' => $request->no_hp,
            'alamat' => $request->alamat,
            'password' => Hash::make($request->password),
        ]);

        // 🔐 Token untuk customer
        $token = $customer->createToken('customer-token')->plainTextToken;

        return response()->json([
            'message' => 'Register berhasil',
            'token' => $token,
            'customer_type' => 'customer', // Menambahkan tipe user untuk frontend
            'customer' => $customer
        ]);
    }

    // CUSTOMER LOGIN
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $customer = Customer::where('email', $request->email)->first();

        // Gagal login jika customer tidak ditemukan atau password salah
        if (! $customer || ! Hash::check($request->password, $customer->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah'],
            ]);
        }

        // 🔐 Token untuk customer
        $token = $customer->createToken('customer-token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token' => $token,
            'customer_type' => 'customer', // Memberitahukan frontend ini adalah customer
            'customer' => $customer
        ]);
    }

    // GET CUSTOMER YANG SEDANG LOGIN
    public function user(Request $request)
    {
        return response()->json($request->user()); // Menggunakan guard sanctum
    }

    // CUSTOMER LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil']);
    }

    public function destroy($id)
    {
        $customer = Customer::find($id);
        if ($customer) {
            $customer->delete();
            return response()->json(['message' => 'Customer deleted successfully']);
        }
        return response()->json(['message' => 'Customer not found'], 404);
    }
}
