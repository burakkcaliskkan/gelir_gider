import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    // Kategori bazında toplamlar
    final Map<String, double> incomeByCategory = {};
    final Map<String, double> expenseByCategory = {};
    for (var t in transactions) {
      if (t.type == 'income') {
        incomeByCategory[t.category] =
            (incomeByCategory[t.category] ?? 0) + t.amount;
      } else {
        expenseByCategory[t.category] =
            (expenseByCategory[t.category] ?? 0) + t.amount;
      }
    }

    // Aylık toplamlar
    final Map<String, double> monthlyIncome = {};
    final Map<String, double> monthlyExpense = {};
    for (var t in transactions) {
      final key = DateFormat('yyyy-MM').format(t.date);
      if (t.type == 'income') {
        monthlyIncome[key] = (monthlyIncome[key] ?? 0) + t.amount;
      } else {
        monthlyExpense[key] = (monthlyExpense[key] ?? 0) + t.amount;
      }
    }
    final months = <String>{...monthlyIncome.keys, ...monthlyExpense.keys}
      ..toList().sort();

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler & Grafikler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Kategoriye Göre Gelirler',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 220,
              child: incomeByCategory.isEmpty
                  ? Center(child: Text('Gelir kaydı yok'))
                  : PieChart(
                      PieChartData(
                        sections: incomeByCategory.entries.map((e) {
                          final color = Colors.greenAccent.shade400.withOpacity(
                              0.7 -
                                  0.1 *
                                      incomeByCategory.keys
                                          .toList()
                                          .indexOf(e.key));
                          return PieChartSectionData(
                            color: color,
                            value: e.value,
                            title: e.key,
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            Text('Kategoriye Göre Giderler',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 220,
              child: expenseByCategory.isEmpty
                  ? Center(child: Text('Gider kaydı yok'))
                  : PieChart(
                      PieChartData(
                        sections: expenseByCategory.entries.map((e) {
                          final color = Colors.redAccent.shade200.withOpacity(
                              0.7 -
                                  0.1 *
                                      expenseByCategory.keys
                                          .toList()
                                          .indexOf(e.key));
                          return PieChartSectionData(
                            color: color,
                            value: e.value,
                            title: e.key,
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            Text('Aylık Gelir & Gider',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 220,
              child: months.isEmpty
                  ? Center(child: Text('Aylık veri yok'))
                  : BarChart(
                      BarChartData(
                        barGroups: months.map((m) {
                          final i = months.toList().indexOf(m);
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: monthlyIncome[m] ?? 0,
                                color: Colors.greenAccent,
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              BarChartRodData(
                                toY: monthlyExpense[m] ?? 0,
                                color: Colors.redAccent,
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 32),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= months.length)
                                  return const SizedBox();
                                return Text(months.elementAt(i).substring(5),
                                    style: const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
