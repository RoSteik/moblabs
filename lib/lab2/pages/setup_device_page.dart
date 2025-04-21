import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupDevicePage extends StatefulWidget {
  const SetupDevicePage({super.key});

  @override
  State<SetupDevicePage> createState() => _SetupDevicePageState();
}

class _SetupDevicePageState extends State<SetupDevicePage> {
  bool _scanned = false;
  final MobileScannerController _cameraController = MobileScannerController();

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return; // only handle one scan at a time
    setState(() => _scanned = true);

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      _showSnack('No QR code detected');
      setState(() => _scanned = false);
      return;
    }

    final raw = barcodes.first.rawValue;
    if (raw == null) {
      _showSnack('Empty QR code');
      setState(() => _scanned = false);
      return;
    }

    try {
      // cast the dynamic result into the expected Map type
      final creds = jsonDecode(raw) as Map<String, dynamic>;
      final deviceId = creds['deviceId']?.toString();
      final deviceKey = creds['deviceKey']?.toString();

      if (deviceId == null || deviceKey == null) {
        throw const FormatException('Required keys missing');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceId', deviceId);
      await prefs.setString('deviceKey', deviceKey);

      _showSnack('Device credentials saved!');
      await Future<void>.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _showSnack('Invalid QR format: $e');
      setState(() => _scanned = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Device')),
      body: MobileScanner(controller: _cameraController, onDetect: _onDetect),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
