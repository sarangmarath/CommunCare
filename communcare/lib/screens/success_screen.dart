import 'package:flutter/material.dart';
import '../main.dart';
import 'logs_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String reportId;
  const SuccessScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final shortId = reportId.length >= 8 ? reportId.substring(0, 8).toUpperCase() : reportId;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: kLightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 56, color: kForestGreen),
              ),
              const SizedBox(height: 24),
              const Text('Success!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Your report has been submitted to the municipality.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text('REF# $shortId',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: kMidGreen)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LogsScreen())),
                  child: const Text('Track Status'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}