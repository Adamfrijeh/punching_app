import 'package:flutter/material.dart';
import 'database.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool load = false;

  @override
  void initState() {
    super.initState();
    getPunches((ok) {
      if (!mounted) return;
      setState(() => load = true);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load history')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFB4557B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("History", style: TextStyle(color: mainColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: mainColor),
            onPressed: () {
              setState(() => load = false);
              getPunches((ok) {
                if (!mounted) return;
                setState(() => load = true);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to refresh')),
                  );
                }
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: !load
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: punches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final p = punches[i];
            final isIn = p.punchType == 'checkin';

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isIn ? Icons.arrow_outward : Icons.arrow_downward,
                    color: isIn ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          "${p.punchType}:  ${p.punchTime}",
                          style: TextStyle(color: isIn ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
