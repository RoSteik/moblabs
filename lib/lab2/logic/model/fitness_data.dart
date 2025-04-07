class FitnessData {
  DateTime date;
  int steps;
  int caloriesBurned;

  FitnessData({
    required this.date,
    required this.steps,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'steps': steps,
    'caloriesBurned': caloriesBurned,
  };

  static FitnessData fromJson(Map<String, dynamic> json) => FitnessData(
    date: DateTime.parse(json['date'] as String),
    steps: json['steps'] as int,
    caloriesBurned: json['caloriesBurned'] as int,
  );
}
