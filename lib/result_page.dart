// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'utils.dart';

// Result page
// This page displays the BMI calculation results
class ResultPage extends StatefulWidget {
  final String bmi;
  final String result;
  final String message;
  final String healthyRange;
  final double bodyFat;
  final double water;
  final double? targetBMI;

  const ResultPage({
    super.key,
    required this.bmi,
    required this.result,
    required this.message,
    required this.healthyRange,
    required this.bodyFat,
    required this.water,
    this.targetBMI,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isRecalculatePressed = false;
  bool _isHealthTipsExpanded = false;

  // Build health checklist based on BMI
  Widget buildHealthChecklist(double bmiValue) {
    List<Widget> items = [];
    if (bmiValue < 16.5) {
      items.addAll([
        _buildChecklistItem(
          'Health Risks',
          'Prone to malnutrition, weakened immune system, infertility, and osteoporosis.',
          Colors.redAccent,
          Icons.warning,
        ),
        _buildChecklistItem(
          'Recommendations',
          'Consult a dietitian for a high-calorie, nutrient-dense diet. Start light strength training.',
          Colors.redAccent,
          Icons.recommend,
        ),
        _buildChecklistItem(
          'Preventions',
          'Eat frequent, small meals to boost calorie intake. Monitor weight weekly.',
          Colors.redAccent,
          Icons.health_and_safety,
        ),
      ]);
    } else if (bmiValue < 18.5) {
      items.addAll([
        _buildChecklistItem(
          'Health Risks',
          'Prone to fatigue, weakened immunity, hormonal imbalances, and low bone density.',
          Colors.yellowAccent,
          Icons.warning,
        ),
        _buildChecklistItem(
          'Recommendations',
          'Increase calorie intake with healthy fats and proteins. Include 3-4 balanced meals daily.',
          Colors.yellowAccent,
          Icons.recommend,
        ),
        _buildChecklistItem(
          'Preventions',
          'Track calorie intake with a food diary. Avoid excessive cardio.',
          Colors.yellowAccent,
          Icons.health_and_safety,
        ),
      ]);
    } else if (bmiValue >= 18.5 && bmiValue < 25) {
      items.addAll([
        _buildChecklistItem(
          'Health Risks',
          'Minimal risks if lifestyle is healthy.',
          Colors.greenAccent,
          Icons.info,
        ),
        _buildChecklistItem(
          'Recommendations',
          'Maintain a balanced diet with fruits/vegetables. Engage in 150 min/week of moderate exercise.',
          Colors.greenAccent,
          Icons.recommend,
        ),
        _buildChecklistItem(
          'Preventions',
          'Limit processed foods. Schedule annual physical exams.',
          Colors.greenAccent,
          Icons.health_and_safety,
        ),
      ]);
    } else if (bmiValue >= 25 && bmiValue < 30) {
      items.addAll([
        _buildChecklistItem(
          'Health Risks',
          'Prone to type 2 diabetes, hypertension, heart disease, and joint issues.',
          Colors.orangeAccent,
          Icons.warning,
        ),
        _buildChecklistItem(
          'Recommendations',
          'Incorporate 30 min/day of cardio 5 days/week. Reduce calorie intake.',
          Colors.orangeAccent,
          Icons.recommend,
        ),
        _buildChecklistItem(
          'Preventions',
          'Use a fitness tracker to monitor steps. Practice portion control.',
          Colors.orangeAccent,
          Icons.health_and_safety,
        ),
      ]);
    } else if (bmiValue >= 30) {
      items.addAll([
        _buildChecklistItem(
          'Health Risks',
          'Prone to heart disease, stroke, type 2 diabetes, sleep apnea, and osteoarthritis.',
          Colors.redAccent,
          Icons.warning,
        ),
        _buildChecklistItem(
          'Recommendations',
          'Consult a doctor for a weight loss plan. Start with low-impact exercises.',
          Colors.redAccent,
          Icons.recommend,
        ),
        _buildChecklistItem(
          'Preventions',
          'Track food intake. Monitor blood pressure and blood sugar regularly.',
          Colors.redAccent,
          Icons.health_and_safety,
        ),
      ]);
    }

    return ExpansionTile(
      title: Text(
        'Health Checklist',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      initiallyExpanded: _isHealthTipsExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isHealthTipsExpanded = expanded;
        });
      },
      children: items.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No specific health recommendations available.',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ]
          : items,
    );
  }

  // Build checklist item
  Widget _buildChecklistItem(
      String title, String subtitle, Color color, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            fontSize: 14),
      ),
    );
  }

  // Show progress toward target BMI
  Widget buildGoalProgress(double bmiValue) {
    if (widget.targetBMI == null) return const SizedBox.shrink();
    final difference = (bmiValue - widget.targetBMI!).abs();
    final progress = (difference / bmiValue).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Toward Target BMI (${widget.targetBMI!.toStringAsFixed(1)})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 1 - progress,
            backgroundColor: Colors.grey.shade300,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 5),
          Text(
            bmiValue > widget.targetBMI!
                ? 'You need to lose ${difference.toStringAsFixed(1)} BMI points.'
                : bmiValue < widget.targetBMI!
                    ? 'You need to gain ${difference.toStringAsFixed(1)} BMI points.'
                    : 'You’ve reached your target BMI!',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  // Show BMI category information
  void _showBMICategoryInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${widget.result} BMI Category',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        content: Text(
          getBMICategoryInfo(widget.result),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bmiValue = double.parse(widget.bmi);
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI CALCULATOR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showBMICategoryInfo,
            tooltip: 'BMI Category Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Your Result",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.result.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.bmi,
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Healthy Weight Range:',
                    style: TextStyle(
                      color:Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.7),
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    widget.healthyRange,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 8.0,
                            percent: (widget.water / 100).clamp(0.0, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                ),
                                Text(
                                  "${widget.water.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            progressColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.grey.shade300,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Water",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 8.0,
                            percent: (widget.bodyFat / 100).clamp(0.0, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.accessibility_new,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 30,
                                ),
                                Text(
                                  "${widget.bodyFat.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            progressColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundColor: Colors.grey.shade300,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Body Fat",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildGoalProgress(bmiValue),
                  buildHealthChecklist(bmiValue),
                ],
              ),
            ),
            GestureDetector(
              onTapDown: (_) => setState(() => _isRecalculatePressed = true),
              onTapUp: (_) => setState(() => _isRecalculatePressed = false),
              onTapCancel: () => setState(() => _isRecalculatePressed = false),
              onTap: () => Navigator.pop(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                color: _isRecalculatePressed
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Theme.of(context).colorScheme.primary,
                height: 60,
                child: Center(
                  child: Text(
                    "RE-CALCULATE",
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
    );
  }
}
