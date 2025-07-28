import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/HomePageAdmin.dart';
import '../customer/HomePageCustomer.dart';
import '../services/auth_service.dart';
import 'registerCustomer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;

  void loginUser() async {
    setState(() => isLoading = true);

    try {
      final result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => isLoading = false);
      print(jsonEncode(result));

      if (result['success']) {
        final role = result['role'];

        // Simpan data customer jika role customer
        if (role == 'customer') {
          final customer = result['customer'];
          if (customer != null) {
            final nama = customer['nama'];
            final idCustomer = customer['id'];

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('nama', nama);
            await prefs.setInt('id_customer', idCustomer);
          }
        }

        // Navigasi ke halaman sesuai role
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePageAdmin()),
          );
        } else if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepagecustomer()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role tidak dikenali.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF30BA), Color(0xFF2D005A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome\nBack!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF30BA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    "- OR Continue with -",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.g_mobiledata, color: Colors.blue),
                    ),
                    SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.apple, color: Colors.black),
                    ),
                    SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.facebook, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Create An Account ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPageCustomer()),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
