<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DetailOrderProdukRilis extends Model
{
    protected $table = 'detail_order_produk_rilis';

    protected $fillable = [
        'order_id',
        'produk_rilis_id',
        'jumlah_item',
        'harga_per_item',
        'subtotal',
    ];

    public function order()
    {
        return $this->belongsTo(order_produk_rilis::class, 'order_id');
    }

    public function produkRilis()
    {
        return $this->belongsTo(ProdukRilis::class, 'produk_rilis_id');
    }
}
