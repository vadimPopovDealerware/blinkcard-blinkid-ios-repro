import 'package:blinkcard_flutter/blinkcard_flutter.dart';
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'package:flutter/material.dart';

// Minimal reproduction: an app that uses BlinkID and BlinkCard side by side.
// No license keys are needed to reproduce the problem, because the iOS build
// fails before the app runs. Put your own keys here to scan on a device.
const blinkIdLicenseKey = 'YOUR_BLINKID_LICENSE_KEY';
const blinkCardLicenseKey = 'YOUR_BLINKCARD_LICENSE_KEY';

void main() => runApp(const ReproApp());

class ReproApp extends StatelessWidget {
  const ReproApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: ReproPage());
}

class ReproPage extends StatefulWidget {
  const ReproPage({super.key});

  @override
  State<ReproPage> createState() => _ReproPageState();
}

class _ReproPageState extends State<ReproPage> {
  String _status = 'Tap a button to scan.';

  Future<void> _scanId() async {
    try {
      final result = await BlinkIdFlutter().performScan(
        blinkIdSdkSettings: BlinkIdSdkSettings(licenseKey: blinkIdLicenseKey, downloadResources: true),
        blinkIdSessionSettings: BlinkIdSessionSettings(scanningSettings: BlinkIdScanningSettings()),
        blinkidScanningUxSettings: BlinkIdScanningUxSettings(),
      );
      setState(() => _status = 'BlinkID: ${result?.documentNumber?.value ?? 'no result'}');
    } catch (e) {
      setState(() => _status = 'BlinkID error: $e');
    }
  }

  Future<void> _scanCard() async {
    try {
      final result = await BlinkCardFlutter().performScan(
        blinkCardSdkSettings: BlinkCardSdkSettings(licenseKey: blinkCardLicenseKey, downloadResources: true),
        blinkCardSessionSettings: BlinkCardSessionSettings(),
      );
      setState(() => _status = 'BlinkCard: ${result?.cardAccounts.length ?? 0} account(s)');
    } catch (e) {
      setState(() => _status = 'BlinkCard error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('BlinkID + BlinkCard')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(onPressed: _scanId, child: const Text('Scan ID (BlinkID)')),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _scanCard, child: const Text('Scan card (BlinkCard)')),
              const SizedBox(height: 24),
              Text(_status),
            ],
          ),
        ),
      );
}
