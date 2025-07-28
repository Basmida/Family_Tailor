import 'package:family_tailor_frontend/CreateData/TambahKatalog.dart';
import 'package:family_tailor_frontend/CreateData/TambahOperasional.dart';
import 'package:family_tailor_frontend/admin/DaftarPelanggan.dart';
import 'package:family_tailor_frontend/admin/HomePageAdmin.dart';
import 'package:family_tailor_frontend/admin/KatalogPageAdmin.dart';
import 'package:family_tailor_frontend/admin/MenuPageAdmin.dart';
import 'package:family_tailor_frontend/admin/OperasionalPage.dart';
import 'package:family_tailor_frontend/admin/StokBahan.dart';
import 'package:family_tailor_frontend/customer/HomePageCustomer.dart';
import 'package:family_tailor_frontend/customer/MidtransPayment.dart';
import 'package:family_tailor_frontend/pages/login_page.dart';
import 'package:family_tailor_frontend/pages/registerCustomer.dart';
import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // INI WAJIB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tailor',
      theme: ThemeData(primarySwatch: Colors.pink),
      home:  LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
