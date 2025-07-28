<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    //  ADMIN REGISTER
    public function register(Request $request)
    {
        $request->validate([
            'nama' => 'required|string',
            'email' => 'required|email|unique:users', // hanya untuk tabel users (admin)
            'password' => 'required|string|min:6|confirmed' //  butuh input `password_confirmation`
        ]);

        $user = User::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => Hash::make($request->password)
        ]);

        // 🔐 Token untuk admin
        $token = $user->createToken('admin-token')->plainTextToken;

        return response()->json([
            'message' => 'Register berhasil',
            'token' => $token,
            'user_type' => 'admin', //  Tambahkan tipe user untuk frontend
            'user' => $user
        ]);
    }

    // ✅ ADMIN LOGIN
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah'
            ], 400);  // Return 400 if login fails
        }

        $token = $user->createToken('admin-token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token' => $token,
            'user_type' => 'admin',
            'user' => $user
        ]);
    }


    //  GET USER YANG SEDANG LOGIN
    public function user(Request $request)
    {
        return response()->json($request->user()); //  Akan otomatis pakai guard sanctum
    }

    //  LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil']);
    }
}
