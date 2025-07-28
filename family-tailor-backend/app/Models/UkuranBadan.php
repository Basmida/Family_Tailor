<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UkuranBadan extends Model
{
    protected $table = 'ukuran_badan';

    protected $fillable = [
        'lingkar_dada',
        'lebar_depan',
        'lebar_pundak',
        'panjang_depan',
        'lingkar_panggul',
        'tinggi_nat',
        'lebar_nat',
        'panjang_baju',
        'lingkar_pinggang',
        'panjang_lengan',
        'lingkar_tangan',
        'panjang_rok',
    ];

    public function orderKatalog()
    {
        return $this->hasOne(OrderKatalog::class, 'id_ukuran_badan');
    }
}
