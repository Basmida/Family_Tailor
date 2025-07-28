<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderKatalog extends Model
{
    use HasFactory;

    protected $table = 'order_katalog';

    protected $fillable = [
        'id_customer',
        'id_produk_katalog',
        'jadwal_ukur_badan',
        'metode_pembayaran',
        'sumber_bahan',
        'durasi_estimasi',
        'total_harga',
        'estimasi_selesai',
        'status',
         'id_ukuran_badan', // ✅ tambahkan ini
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'id_customer');
    }

    public function katalog()
    {
        return $this->belongsTo(Katalog::class, 'id_produk_katalog');
    }

    public function ukuranBadan()
    {
        return $this->belongsTo(UkuranBadan::class, 'id_ukuran_badan');
    }
}
