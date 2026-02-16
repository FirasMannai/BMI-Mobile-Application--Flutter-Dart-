// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'result_page.dart';
import 'bmi_history_page.dart';
import 'bmi_provider.dart';
import 'notification_service.dart';
import 'theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bmi_measurement.dart'; // Ensure this import is present for BMIMeasurement

// Enum for gender selection
enum Gender { male, female }

// Input page
// This page allows users to input their data to calculate BMI
class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender? selectedGender;
  int height = 180;
  int weight = 60;
  int age = 20;
  double? targetBMI;
  bool enableReminders = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isCalculatePressed = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  // Request permissions for notifications
  Future<void> _requestNotificationPermissions() async {
    bool granted = await NotificationService().requestPermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Notification permissions are required for reminders.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  // Send a test notification
  Future<void> _testNotification() async {
    bool granted = await NotificationService().requestPermissions();
    if (granted) {
      await NotificationService().sendTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test notification sent!')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Cannot send test notification: Permission denied.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  // Schedule a daily reminder
  Future<void> _scheduleReminder() async {
    bool granted = await NotificationService().requestPermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Cannot set reminder: Notification permission denied.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    await NotificationService().scheduleDailyReminderAt(
      hour: reminderTime.hour,
      minute: reminderTime.minute,
    );

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    final isNextDay = scheduledDate.isBefore(now);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder set for ${reminderTime.format(context)}${isNextDay ? ' tomorrow' : ''}',
          ),
        ),
      );
    }
  }

  // Calculate BMI based on weight and height
  double calculateBMI() {
    return weight / ((height / 100) * (height / 100));
  }

  // Determine BMI category
  String getResult(double bmi) {
    if (bmi >= 30) return 'OBESE';
    if (bmi >= 25) return 'OVERWEIGHT';
    if (bmi >= 18.5) return 'NORMAL';
    return 'UNDERWEIGHT';
  }

  // Get message based on BMI category
  String getMessage(String result) {
    switch (result) {
      case 'OBESE':
        return 'You are heavily overweight.\nConsider consulting a doctor.';
      case 'OVERWEIGHT':
        return 'You are slightly overweight.\nMore activity could help.';
      case 'NORMAL':
        return 'You have a normal body weight.\nGreat job! Keep it up!';
      case 'UNDERWEIGHT':
        return 'You are underweight.\nTry eating more and staying healthy!';
      default:
        return '';
    }
  }

  // Calculate healthy weight range
  String getHealthyWeightRange() {
    double heightInMeters = height / 100;
    double minWeight = 18.5 * heightInMeters * heightInMeters;
    double maxWeight = 24.9 * heightInMeters * heightInMeters;
    return '${minWeight.toStringAsFixed(0)} kg - ${maxWeight.toStringAsFixed(0)} kg';
  }

  // Estimate body fat percentage
  double estimateBodyFat(double bmi, int age, Gender gender) {
    int genderFactor = (gender == Gender.male) ? 1 : 0;
    return (1.20 * bmi + 0.23 * age - 10.8 * genderFactor - 5.4).clamp(0, 100);
  }

  // Estimate body water percentage
  double estimateWaterPercent(double bodyFat, Gender gender) {
    double leanFraction = 1 - (bodyFat / 100);
    double result = leanFraction * 0.73 * 100;
    return result.clamp(0, 100);
  }

  // Build gender selection card
  Widget buildGenderCard(Gender gender, IconData icon, String label) {
    final isSelected = selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGender = gender;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(10.0),
          height: 180,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 80, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(height: 15),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build card for weight and age input
  Widget buildRoundedCard(
      String label, int value, VoidCallback minus, VoidCallback plus) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: minus,
                  icon: Icon(Icons.remove,
                      color: Theme.of(context).colorScheme.onPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: plus,
                  icon: Icon(Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Select reminder time
  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null && picked != reminderTime) {
      setState(() {
        reminderTime = picked;
      });
      if (enableReminders) {
        await _scheduleReminder();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI CALCULATOR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const BMIHistoryPage(),
                ),
              );
            },
          ),
          Switch(
            value: themeProvider.isDarkTheme,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  buildGenderCard(Gender.male, Icons.male, "MALE"),
                  buildGenderCard(Gender.female, Icons.female, "FEMALE"),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "HEIGHT",
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          height.toString(),
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          "cm",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Colors.grey.shade400,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        overlayColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 25.0),
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: height.toDouble(),
                        min: 100,
                        max: 220,
                        onChanged: (val) =>
                            setState(() => height = val.round()),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  buildRoundedCard(
                    "WEIGHT",
                    weight,
                    () => setState(
                        () => weight = weight > 20 ? weight - 1 : weight),
                    () => setState(
                        () => weight = weight < 200 ? weight + 1 : weight),
                  ),
                  buildRoundedCard(
                    "AGE",
                    age,
                    () => setState(() => age = age > 10 ? age - 1 : age),
                    () => setState(() => age = age < 100 ? age + 1 : age),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Target BMI (15.0 - 40.0)',
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.1),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final bmi = double.tryParse(value);
                        if (bmi == null || bmi < 15.0 || bmi > 40.0) {
                          return 'Enter a valid BMI (15.0 - 40.0)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          targetBMI = double.tryParse(value);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        'Enable Daily Reminders',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      trailing: Switch(
                        value: enableReminders,
                        onChanged: (value) {
                          setState(() {
                            enableReminders = value;
                            if (value) {
                              _scheduleReminder();
                            } else {
                              NotificationService().cancelReminder();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Daily reminders disabled')),
                                );
                              }
                            }
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Reminder Time: ${reminderTime.format(context)}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      trailing: Icon(Icons.access_time,
                          color: Theme.of(context).colorScheme.onPrimary),
                      onTap: _selectReminderTime,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _testNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Send Test Notification'),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTapDown: (_) => setState(() => _isCalculatePressed = true),
                onTapUp: (_) => setState(() => _isCalculatePressed = false),
                onTapCancel: () => setState(() => _isCalculatePressed = false),
                onTap: () {
                  if (_formKey.currentState!.validate() &&
                      selectedGender != null) {
                    final bmi = calculateBMI();
                    Provider.of<BMIProvider>(context, listen: false)
                        .addMeasurement(
                            BMIMeasurement(bmi: bmi, date: DateTime.now()));
                    final result = getResult(bmi);
                    final msg = getMessage(result);
                    final range = getHealthyWeightRange();
                    final bodyFat = estimateBodyFat(bmi, age, selectedGender!);
                    final water =
                        estimateWaterPercent(bodyFat, selectedGender!);

                    if (enableReminders) {
                      _scheduleReminder();
                    }

                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: ResultPage(
                          bmi: bmi.toStringAsFixed(1),
                          result: result,
                          message: msg,
                          healthyRange: range,
                          bodyFat: bodyFat,
                          water: water,
                          targetBMI: targetBMI,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please select a gender and enter valid inputs')),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  color: _isCalculatePressed
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                      : Theme.of(context).colorScheme.primary,
                  height: 60,
                  child: Center(
                    child: Text(
                      "CALCULATE",
                      style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
