<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CustomerAuthController;
use App\Http\Controllers\DetailOrderProdukRilisController;
use App\Http\Controllers\KatalogController;
use App\Http\Controllers\LayananController;
use App\Http\Controllers\LimitProduksiController;
use App\Http\Controllers\MidtransController;
use App\Http\Controllers\OmsetController;
use App\Http\Controllers\ProdukRilisController;
use App\Http\Controllers\StokBahanBakuController;
use App\Http\Controllers\OperasionalController;
use App\Http\Controllers\OrderProdukRilisController;
use App\Http\Controllers\OrderKatalogController;
use App\Http\Controllers\PesananController;
use App\Http\Controllers\UkuranBadanController;
use App\Models\order_produk_rilis;

// ================= ADMIN AUTH =================
Route::prefix('admin')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/user', [AuthController::class, 'user']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

// ================= CUSTOMER AUTH =================
Route::prefix('customer')->group(function () {
    Route::post('/login', [CustomerAuthController::class, 'login']);
    Route::post('/register', [CustomerAuthController::class, 'register']);
    Route::get('/getAll', [CustomerAuthController::class, 'getAllCustomers']);
    Route::delete('/delete/{id}', [CustomerAuthController::class, 'destroy']);
    // ✅ Rute khusus yang butuh token login
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/profile', [CustomerAuthController::class, 'getCustomer']);
        Route::post('/logout', [CustomerAuthController::class, 'logout']);
    });
});

//produk rilis
Route::apiResource('produk-rilis', ProdukRilisController::class);
//katalog
Route::apiResource('katalog', KatalogController::class);
//Stokbahan baku
Route::apiResource('stok', StokBahanBakuController::class);
//operasional
Route::apiResource('operasional', OperasionalController::class);
//limit
Route::apiResource('limit-produksi', LimitProduksiController::class);
//order produk rilis
Route::apiResource('order-produk-rilis', OrderProdukRilisController::class);
//admin update status pesanan
Route::patch('/order-produk-rilis/{id}/status', [OrderProdukRilisController::class, 'updateStatus']);
//detail order produk rilis
Route::apiResource('detail-order-produk-rilis', DetailOrderProdukRilisController::class);
//Order katalog
Route::apiResource('order-katalog', OrderKatalogController::class);
Route::apiResource('layanan', LayananController::class);
//Ukuran badan
//Route::apiResource('ukuran-badan', UkuranBadanController::class);
// update ukuran badan
Route::put('/order-katalog/{id}/ukuran-badan', [OrderKatalogController::class, 'updateUkuranBadan']);
//OMSET
Route::get('/omset', [OmsetController::class, 'getOmset']);
Route::get('/omset/detail', [OmsetController::class, 'getDetailOmset']);

//PAYMENTGATEWAY
Route::post('/checkout', [OrderProdukRilisController::class, 'checkout']);
Route::post('/midtrans', [MidtransController::class, 'getSnapToken']);
Route::post('/midtrans-notification', [MidtransController::class, 'handleNotification']);

//UPDATE STATUS PEMBAYARAN produk rilis
Route::put('/order-produk-rilis/{id}/update-pembayaran', [OrderProdukRilisController::class, 'updateStatusPembayaran']);
//update pembayaran custom
Route::put('/order-katalog/{id}/pembayaran', [OrderKatalogController::class, 'updatePembayaran']);

//pesanan
Route::get('/pesanan', [PesananController::class, 'index']);
//cancel order
Route::delete('/order-produk-rilis/{id}/cancel', [OrderProdukRilisController::class, 'cancel']);
