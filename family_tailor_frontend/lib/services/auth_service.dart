import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://192.168.100.65:8000/api";

  //============================== ADMIN ==============================//

  static Future<String> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/register"),
        headers: {"Accept": "application/json"},
        body: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return "Register berhasil";
      } else {
        final body = jsonDecode(response.body);
        return "Register gagal: ${body['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      return "Register error: $e";
    }
  }

  static Future<String> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return "Token tidak ditemukan";

      final response = await http.post(
        Uri.parse("$baseUrl/admin/logout"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        return "Logout berhasil";
      } else {
        final body = jsonDecode(response.body);
        return "Logout gagal: ${body['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      return "Logout error: $e";
    }
  }

  //============================== CUSTOMER ==============================//

  static Future<String> registerCustomer(
    String name,
    String email,
    String phone,
    String address,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/customer/register");

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'nama': name,
          'email': email,
          'no_hp': phone,
          'alamat': address,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Registration successful';
      } else {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Something went wrong';
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  //============================== LOGIN GABUNGAN ==============================//

  /// Fungsi login universal: mencoba login ke admin lebih dulu, jika gagal baru ke customer
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final headers = {"Accept": "application/json"};
    final body = {
      "email": email,
      "password": password,
    };

    final prefs = await SharedPreferences.getInstance();

    // 1. Coba login sebagai ADMIN
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/login"),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        await prefs.setString('token', token);
        await prefs.setString('role', 'admin');

        return {
          'success': true,
          'role': 'admin',
          'message': 'Login berhasil sebagai admin',
          'token': token,
        };
      }
    } catch (_) {}

    // 2. Coba login sebagai CUSTOMER
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/customer/login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json", 
        },
        body: json.encode(body), //customer pakai JSON body
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final customer = data['customer'];

        await prefs.setString('token', token);
        await prefs.setString('role', 'customer');
        await prefs.setInt('id_customer', customer['id']);

        return {
          'success': true,
          'role': 'customer',
          'message': 'Login berhasil sebagai customer',
          'token': token,
          'customer': customer,
          'id_customer': customer['id'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error: $e',
      };
    }

    return {
      'success': false,
      'message': 'Email atau password tidak cocok',
    };
  }
}
