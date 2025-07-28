<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Operasional extends Model
{
    use HasFactory;

    protected $table = 'operasional';

    protected $fillable = [
        'nama_item',
        'tanggal',
        'jenis_operasional',
        'nominal',
        'keterangan',
    ];
}
