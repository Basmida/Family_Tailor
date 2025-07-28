import 'package:family_tailor_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPageCustomer extends StatefulWidget {
  const RegisterPageCustomer({super.key});

  @override
  State<RegisterPageCustomer> createState() => _RegisterPageCustomerState();
}

class _RegisterPageCustomerState extends State<RegisterPageCustomer> {
  // Controller input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(); // For phone number
  final addressController = TextEditingController(); // For address
  final passwordController = TextEditingController();

  // State loading dan toggle password visibility
  bool isLoading = false;
  bool _obscurePassword = true;

  // Fungsi untuk registrasi customer ke backend
  void registerUser() async {
    setState(() => isLoading = true);
    final result = await AuthService.registerCustomer(
      nameController.text,
      emailController.text,
      phoneController.text,
      addressController.text,
      passwordController.text,
    );
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

    // Jika berhasil, navigasi ke login
    if (result.contains('berhasil')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🌈 Background gradien
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF30BA), Color(0xFF2B0A79)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        height: MediaQuery.of(context).size.height, // Full screen height
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Create an\nAccount',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🧑 Input Nama
                  _buildInputField(
                    controller: nameController,
                    hintText: "Nama",
                    icon: Icons.person,
                    obscure: false,
                  ),

                  const SizedBox(height: 15),

                  // 📧 Input Email
                  _buildInputField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                    obscure: false,
                  ),

                  const SizedBox(height: 15),

                  // 📱 Input No HP
                  _buildInputField(
                    controller: phoneController,
                    hintText: "Nomor HP",
                    icon: Icons.phone,
                    obscure: false,
                  ),

                  const SizedBox(height: 15),

                  // 🏠 Input Alamat
                  _buildInputField(
                    controller: addressController,
                    hintText: "Alamat",
                    icon: Icons.location_on,
                    obscure: false,
                  ),

                  const SizedBox(height: 15),

                  // 🔒 Input Password
                  _buildInputField(
                    controller: passwordController,
                    hintText: "Password",
                    icon: Icons.lock,
                    obscure: _obscurePassword,
                    toggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),

                  const SizedBox(height: 40),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF30BA),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              "Registration",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Tautan ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? ",
                          style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧱 Widget Input
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscure,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.deepPurple,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
