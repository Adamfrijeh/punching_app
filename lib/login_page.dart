import 'package:flutter/material.dart';
import 'database.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController empCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool loading = false;

  void doLogin() {
    if (loading) return;

    final emp = empCtrl.text.trim();
    final pass = passCtrl.text;

    if (emp.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Employee ID and Password')),
      );
      return;
    }

    setState(() => loading = true);

    login(emp, pass, (ok, msg) {
      if (!mounted) return;

      setState(() => loading = false);

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFB4557B);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 70),

               Logo placeholder (you can replace with Image.asset)
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    "ABC",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: mainColor),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Welcome to ABC community",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: empCtrl,
                decoration: const InputDecoration(
                  labelText: "Employee ID",
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: loading ? null : doLogin,
                  child: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Explore mode can be added later')),
                    );
                  },
                  child: const Text("Explore the App", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
