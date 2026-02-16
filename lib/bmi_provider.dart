// Importing necessary packages
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bmi_measurement.dart';
import 'dart:convert';

// BMI provider
// This class manages BMI history and persists it
class BMIProvider extends ChangeNotifier {
  List<BMIMeasurement> _bmiHistory = [];

  List<BMIMeasurement> get bmiHistory => _bmiHistory;

  // Load BMI history from shared preferences
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('bmi_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _bmiHistory =
          decoded.map((item) => BMIMeasurement.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Add a new BMI measurement
  void addMeasurement(BMIMeasurement measurement) {
    _bmiHistory.add(measurement);
    _saveHistory();
    notifyListeners();
  }

  // Remove a BMI measurement
  void removeMeasurement(int index) {
    _bmiHistory.removeAt(index);
    _saveHistory();
    notifyListeners();
  }

  // Save BMI history to shared preferences
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_bmiHistory.map((e) => e.toJson()).toList());
    await prefs.setString('bmi_history', encoded);
  }
}
