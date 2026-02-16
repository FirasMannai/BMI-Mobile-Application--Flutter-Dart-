// BMI measurement model
// This class stores BMI data with date
class BMIMeasurement {
  final double bmi;
  final DateTime date;

  BMIMeasurement({required this.bmi, required this.date});

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'bmi': bmi,
        'date': date.toIso8601String(),
      };

  // Create from JSON
  factory BMIMeasurement.fromJson(Map<String, dynamic> json) => BMIMeasurement(
        bmi: json['bmi'],
        date: DateTime.parse(json['date']),
      );
}
