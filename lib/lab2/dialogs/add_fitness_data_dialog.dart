import 'package:flutter/material.dart';
import 'package:moblabs/lab2/logic/model/fitness_data.dart';

class AddFitnessDataDialog extends StatefulWidget {
  final void Function(FitnessData) onAdd;

  const AddFitnessDataDialog({required this.onAdd, super.key});

  @override
  State<AddFitnessDataDialog> createState() => _AddFitnessDataDialogState();
}

class _AddFitnessDataDialogState extends State<AddFitnessDataDialog> {
  final dateController = TextEditingController();
  final stepsController = TextEditingController();
  final caloriesController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    stepsController.dispose();
    caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Fitness Data'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                hintText: 'Enter date (YYYY-MM-DD)',
              ),
            ),
            TextField(
              controller: stepsController,
              decoration: const InputDecoration(hintText: 'Enter steps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: caloriesController,
              decoration: const InputDecoration(
                hintText: 'Enter calories burned',
              ),
              keyboardType: TextInputType.number,
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
          child: const Text('Add'),
          onPressed: () => _submitData(context),
        ),
      ],
    );
  }

  void _submitData(BuildContext context) {
    final date = DateTime.tryParse(dateController.text);
    final steps = int.tryParse(stepsController.text);
    final calories = int.tryParse(caloriesController.text);

    if (date != null && steps != null && calories != null) {
      final newData = FitnessData(
        date: date,
        steps: steps,
        caloriesBurned: calories,
      );
      widget.onAdd(newData);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid data')));
    }
  }
}
