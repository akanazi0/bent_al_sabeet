import 'package:flutter/material.dart';

class RoundDetailsScreen extends StatelessWidget {
  final int roundNumber;
  final Map<String, int> roundData;

  const RoundDetailsScreen({super.key, required this.roundNumber, required this.roundData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        elevation: 0,
        title: Text('ROUND $roundNumber DETAILS', 
          style: const TextStyle(color: Color(0xFFA9B7C6), fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              border: Border.all(color: const Color(0xFF3E3E3E)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: roundData.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(color: Color(0xFFA9B7C6), fontSize: 16)),
                    Text('${entry.value}', 
                      style: const TextStyle(color: Color(0xFF3574F0), fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}