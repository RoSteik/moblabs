import 'package:flutter/material.dart';

class EditCredentialsDialog extends StatefulWidget {
  final String initialDeviceId;
  final String initialDeviceKey;
  final void Function(String, String) onSave;

  const EditCredentialsDialog({
    required this.initialDeviceId,
    required this.initialDeviceKey,
    required this.onSave,
    super.key,
  });

  @override
  State<EditCredentialsDialog> createState() => _EditCredentialsDialogState();
}

class _EditCredentialsDialogState extends State<EditCredentialsDialog> {
  late final TextEditingController deviceIdController;
  late final TextEditingController deviceKeyController;

  @override
  void initState() {
    super.initState();
    deviceIdController = TextEditingController(text: widget.initialDeviceId);
    deviceKeyController = TextEditingController(text: widget.initialDeviceKey);
  }

  @override
  void dispose() {
    deviceIdController.dispose();
    deviceKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Device Credentials'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(labelText: 'Device ID'),
            ),
            TextField(
              controller: deviceKeyController,
              decoration: const InputDecoration(labelText: 'Device Key'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            widget.onSave(deviceIdController.text, deviceKeyController.text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
