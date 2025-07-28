<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class order_produk_rilis extends Model
{
    protected $table = 'order_produk_rilis';

    protected $fillable = [
        'id_customer',
        'metode_pengiriman',
        'metode_pembayaran',
        'status',
        'zona',
        'ongkir',
        'total_harga',
        'status_pembayaran',
        'estimasi_tiba_min',
        'estimasi_tiba_max',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'id_customer');
    }

    public function detailOrders()
    {
        return $this->hasMany(DetailOrderProdukRilis::class, 'order_id');
    }
}
