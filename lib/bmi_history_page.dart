// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'bmi_measurement.dart';
import 'bmi_provider.dart';
import 'dart:io';

// BMI history page
// This page displays the history of BMI measurements
class BMIHistoryPage extends StatefulWidget {
  const BMIHistoryPage({super.key});

  @override
  _BMIHistoryPageState createState() => _BMIHistoryPageState();
}

class _BMIHistoryPageState extends State<BMIHistoryPage> {
  // Export BMI history to a file
  Future<void> _exportHistory(List<BMIMeasurement> history) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final directory = await getExternalStorageDirectory();
        final file = File(
            '${directory!.path}/bmi_history_${DateTime.now().millisecondsSinceEpoch}.txt');
        final buffer = StringBuffer();
        buffer.writeln('BMI History Export - ${DateTime.now()}');
        for (var entry in history.asMap().entries) {
          buffer.writeln(
            '${entry.key + 1}. BMI: ${entry.value.bmi.toStringAsFixed(1)}, Date: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.value.date)}',
          );
        }
        await file.writeAsString(buffer.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('History exported to ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error exporting history')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmiProvider = Provider.of<BMIProvider>(context);
    final history = bmiProvider.bmiHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: history.isEmpty ? null : () => _exportHistory(history),
            tooltip: 'Export History',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: history.isEmpty
            ? Center(
                child: Text(
                  'No BMI measurements recorded yet.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Column(
                children: [
                  Text(
                    'BMI Trend Over Time',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < history.length) {
                                  final date = history[value.toInt()].date;
                                  return Text(
                                    DateFormat('MM/dd').format(date),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withOpacity(0.3)),
                        ),
                        minX: 0,
                        maxX: (history.length - 1).toDouble(),
                        minY: history.isNotEmpty
                            ? history
                                    .map((e) => e.bmi)
                                    .reduce((a, b) => a < b ? a : b) *
                                0.9
                            : 0,
                        maxY: history.isNotEmpty
                            ? history
                                    .map((e) => e.bmi)
                                    .reduce((a, b) => a > b ? a : b) *
                                1.1
                            : 40,
                        lineBarsData: [
                          LineChartBarData(
                            spots: history
                                .asMap()
                                .entries
                                .map((e) =>
                                    FlSpot(e.key.toDouble(), e.value.bmi))
                                .toList(),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 4,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 4,
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final index = spot.x.toInt();
                                final measurement = history[index];
                                return LineTooltipItem(
                                  'BMI: ${measurement.bmi.toStringAsFixed(1)}\n${DateFormat('yyyy-MM-dd').format(measurement.date)}',
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final measurement = history[index];
                        return Dismissible(
                          key: Key(measurement.date.toString()),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            bmiProvider.removeMeasurement(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Measurement deleted')),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              'BMI: ${measurement.bmi.toStringAsFixed(1)}',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            subtitle: Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(measurement.date),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(0.7)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
