import 'package:flutter/material.dart';
import 'package:moblabs/lab2/logic/model/fitness_data.dart';

class FitnessDataList extends StatelessWidget {
  final List<FitnessData> fitnessDataList;
  final void Function(int) onDelete;

  const FitnessDataList({
    required this.fitnessDataList,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fitnessDataList.length,
      itemBuilder: (context, index) {
        final item = fitnessDataList[index];
        return ListTile(
          title: Text(
            'Date: ${item.date.toIso8601String()}, '
            'Steps: ${item.steps}, '
            'Calories Burned: ${item.caloriesBurned}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete(index),
          ),
        );
      },
    );
  }
}
