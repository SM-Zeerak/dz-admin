import 'package:dz_admin_panel/widget/fi_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Example data for detailed chart (dates + counts)
  List<DateTime> _generateDates(int count, String range) {
    final now = DateTime.now();
    List<DateTime> dates = [];
    for (int i = 0; i < count; i++) {
      switch (range) {
        case 'Daily':
          dates.add(now.subtract(Duration(hours: count - 1 - i)));
          break;
        case 'Weekly':
          dates.add(now.subtract(Duration(days: count - 1 - i)));
          break;
        case 'Monthly':
          dates.add(DateTime(now.year, now.month, i + 1));
          break;
        case 'Yearly':
          dates.add(DateTime(now.year, i + 1, 1));
          break;
        default:
          dates.add(now.subtract(Duration(days: count - 1 - i)));
      }
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = width > 800;

    int crossAxisCount = 1;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 800) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          DashboardCard(
            title: "Total Users",
            icon: Icons.people,
            count: 1245,
            color: Colors.blue,
            graphData: [10, 20, 15, 30, 40, 35, 50],
            onTap: () {
              if (!isLargeScreen) return;
              showDialog(
                context: context,
                builder:
                    (_) => DetailedChartDialog(
                      title: "Total Users",
                      color: Colors.blue,
                      dates: _generateDates(7, 'Weekly'),
                      counts:
                          [
                            10,
                            20,
                            15,
                            30,
                            40,
                            35,
                            50,
                          ].map((e) => e.toDouble()).toList(),
                    ),
              );
            },
          ),

          DashboardCard(
            title: "Active Sessions",
            icon: Icons.bar_chart,
            count: 312,
            color: Colors.green,
            graphData: [5, 15, 25, 20, 30, 25, 35],
            onTap: () {
              if (!isLargeScreen) return;
              showDialog(
                context: context,
                builder:
                    (_) => DetailedChartDialog(
                      title: "Active Sessions",
                      color: Colors.green,
                      dates: _generateDates(7, 'Weekly'),
                      counts:
                          [
                            5,
                            15,
                            25,
                            20,
                            30,
                            25,
                            35,
                          ].map((e) => e.toDouble()).toList(),
                    ),
              );
            },
          ),

          DashboardCard(
            title: "New Signups",
            icon: Icons.person_add,
            count: 87,
            color: Colors.orange,
            graphData: [2, 4, 6, 5, 8, 7, 10],
            onTap: () {
              if (!isLargeScreen) return;
              showDialog(
                context: context,
                builder:
                    (_) => DetailedChartDialog(
                      title: "New Signups",
                      color: Colors.orange,
                      dates: _generateDates(7, 'Weekly'),
                      counts:
                          [
                            2,
                            4,
                            6,
                            5,
                            8,
                            7,
                            10,
                          ].map((e) => e.toDouble()).toList(),
                    ),
              );
            },
          ),

          DashboardCard(
            title: "Revenue",
            icon: Icons.attach_money,
            count: 10234,
            color: Colors.purple,
            graphData: [1000, 2000, 1500, 3000, 4000, 3500, 5000],
            onTap: () {
              if (!isLargeScreen) return;
              showDialog(
                context: context,
                builder:
                    (_) => DetailedChartDialog(
                      title: "Revenue",
                      color: Colors.purple,
                      dates: _generateDates(7, 'Weekly'),
                      counts:
                          [
                            1000,
                            2000,
                            1500,
                            3000,
                            4000,
                            3500,
                            5000,
                          ].map((e) => e.toDouble()).toList(),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final List<double> graphData;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.graphData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    Widget cardContent = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: graphData.length.toDouble() - 1,
                  minY: 0,
                  maxY: (graphData.reduce((a, b) => a > b ? a : b)) * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        graphData.length,
                        (index) => FlSpot(index.toDouble(), graphData[index]),
                      ),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Count: $count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    if (isLargeScreen && onTap != null) {
      return InkWell(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }
}

class DetailedChartDialog extends StatefulWidget {
  final String title;
  final Color color;
  final List<DateTime> dates;
  final List<double> counts;

  const DetailedChartDialog({
    super.key,
    required this.title,
    required this.color,
    required this.dates,
    required this.counts,
  });

  @override
  State<DetailedChartDialog> createState() => _DetailedChartDialogState();
}

class _DetailedChartDialogState extends State<DetailedChartDialog> {
  String selectedRange = 'Daily';

  late List<DateTime> displayedDates;
  late List<double> displayedCounts;

  @override
  void initState() {
    super.initState();
    _updateData(selectedRange);
  }

  void _updateData(String range) {
    setState(() {
      selectedRange = range;

      // For simplicity, just showing all data for now.
      // You can filter widget.dates and widget.counts based on range.
      displayedDates = widget.dates;
      displayedCounts = widget.counts;
    });
  }

  List<FlSpot> _spots() {
    return List.generate(
      displayedCounts.length,
      (i) => FlSpot(i.toDouble(), displayedCounts[i]),
    );
  }

  String _getXAxisLabel(int index) {
    if (index < 0 || index >= displayedDates.length) return '';

    final date = displayedDates[index];
    switch (selectedRange) {
      case 'Daily':
        return DateFormat.Hm().format(date); // Hour:Minute
      case 'Weekly':
        return DateFormat.E().format(date); // Mon, Tue...
      case 'Monthly':
        return DateFormat.d().format(date); // Day of month
      case 'Yearly':
        return DateFormat.MMM().format(date); // Jan, Feb...
      case 'Lifetime':
        return DateFormat.yMd().format(date); // Date
      default:
        return DateFormat.yMd().format(date);
    }
  }

  double _maxY() {
    if (displayedCounts.isEmpty) return 10;
    return displayedCounts.reduce((a, b) => a > b ? a : b) * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 700,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: widget.color),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _maxY() / 5,
                        getTitlesWidget:
                            (val, meta) => Text(val.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (val, meta) {
                          final index = val.toInt();
                          if (index < 0 || index >= displayedDates.length) {
                            return const Text('');
                          }
                          return Text(
                            _getXAxisLabel(index),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  minX: 0,
                  maxX:
                      displayedDates.isNotEmpty
                          ? (displayedDates.length - 1).toDouble()
                          : 0,
                  minY: 0,
                  maxY: _maxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots(),
                      isCurved: true,
                      color: widget.color,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: widget.color.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Daily', 'Weekly', 'Monthly', 'Yearly', 'Lifetime']
                      .map(
                        (range) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(range),
                            selected: selectedRange == range,
                            onSelected: (_) => _updateData(range),
                            selectedColor: widget.color.withOpacity(0.7),
                            labelStyle: TextStyle(
                              color:
                                  selectedRange == range
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
