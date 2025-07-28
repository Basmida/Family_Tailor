<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Layanan extends Model
{
    use HasFactory;

    protected $table = 'layanan';

    protected $fillable = [
        'customer_id',
        'jenis_layanan',
        'harga',
        'waktu_layanan',
        'estimasi_selesai',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
