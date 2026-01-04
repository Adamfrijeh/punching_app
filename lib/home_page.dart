import 'dart:async';
import 'package:flutter/material.dart';
import 'database.dart';
import 'history_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool load = false;
  int? selectedLocationId;

  DateTime now = DateTime.now();
  Timer? timer;

  @override
  void initState() {
    super.initState();


    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => now = DateTime.now());
    });


    getLocations((ok) {
      if (!mounted) return;

      if (!ok) {
        setState(() => load = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load locations')),
        );
        return;
      }


      if (locations.isNotEmpty) {
        selectedLocationId = locations.first.id;
      }

      getPunches((ok2) {
        if (!mounted) return;
        setState(() => load = true);
        if (!ok2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load history')),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String two(int n) => n.toString().padLeft(2, '0');

  String timeText() {
    final h = now.hour;
    final m = now.minute;
    final ampm = h >= 12 ? "PM" : "AM";
    final hh = h % 12 == 0 ? 12 : h % 12;
    return "${two(hh)}:${two(m)} $ampm";
  }

  String dateText() {

    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    const days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
    return "${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}";
  }

  void doPunch(String type) {
    if (!load) return;
    if (selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a location')),
      );
      return;
    }

    punch(selectedLocationId!, type, (ok) {
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Punch failed')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(type == 'checkin' ? 'Checked in ✅' : 'Checked out ✅')),
      );


      getPunches((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  void logout() {
    currentEmployee = null;
    locations.clear();
    punches.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFB4557B);

    final name = currentEmployee?.fullName ?? "Employee";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: mainColor),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: mainColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: mainColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: !load
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                "Welcome $name",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: mainColor),
              ),
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      dateText(),
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      timeText(),
                      style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),


                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white70),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedLocationId,
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          items: locations.map((loc) {
                            return DropdownMenuItem<int>(
                              value: loc.id,
                              child: Text(loc.name, style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectedLocationId = v),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),


                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => doPunch('checkin'),
                        icon: const Icon(Icons.fingerprint, color: mainColor),
                        label: const Text("Checkin", style: TextStyle(color: mainColor, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 12),


                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => doPunch('checkout'),
                        icon: const Icon(Icons.fingerprint, color: Colors.white),
                        label: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Let us journey together to the new\nchallenges and make great results",
                textAlign: TextAlign.center,
                style: TextStyle(color: mainColor.withOpacity(0.9), fontSize: 16),
              ),

              const SizedBox(height: 14),


              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryPage()),
                        );
                      },
                      child: const Text("History", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                      onPressed: logout,
                      child: const Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
