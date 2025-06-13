import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final today = DateTime.now();
    final todayTransactions = provider.transactions
        .where(
          (t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .toList();

    double income = todayTransactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
    double expense = todayTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gelir-Gider Takip'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: Icon(Icons.bar_chart_rounded),
            tooltip: 'İstatistikler',
            onPressed: () => Navigator.pushNamed(context, '/statistics'),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TransactionsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: provider.avatarUrl.isNotEmpty
                      ? NetworkImage(provider.avatarUrl)
                      : null,
                  child: provider.avatarUrl.isEmpty
                      ? Icon(Icons.person, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    provider.userName.isNotEmpty
                        ? provider.userName
                        : 'Kullanıcı',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: SummaryCard(
                        title: 'Gelir',
                        amount: income,
                        color: Colors.green,
                        icon: Icons.trending_up)),
                SizedBox(width: 8),
                Expanded(
                    child: SummaryCard(
                        title: 'Gider',
                        amount: expense,
                        color: Colors.red,
                        icon: Icons.trending_down)),
                SizedBox(width: 8),
                Expanded(
                    child: SummaryCard(
                        title: 'Net',
                        amount: income - expense,
                        color: Colors.blue,
                        icon: Icons.account_balance_wallet)),
              ],
            ),
            SizedBox(height: 16),
            if (provider.monthlyLimit > 0)
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final thisMonthExpense = provider.transactions
                      .where((t) =>
                          t.type == 'expense' &&
                          t.date.year == now.year &&
                          t.date.month == now.month)
                      .fold<double>(0, (sum, t) => sum + t.amount);
                  if (thisMonthExpense > provider.monthlyLimit) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.redAccent),
                          SizedBox(width: 12),
                          Expanded(
                              child: Text(
                                  'Uyarı: Bu ay harcama limitinizi aştınız!',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            Expanded(
              child: todayTransactions.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 80, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text('Bugün için işlem yok.',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 18)),
                      ],
                    )
                  : ListView.builder(
                      itemCount: todayTransactions.length,
                      itemBuilder: (context, index) => TransactionCard(
                        transaction: todayTransactions[index],
                        onDelete: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  'İşlemi silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Vazgeç'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Sil'),
                                ),
                              ],
                            ),
                          );
                          if (shouldDelete == true) {
                            final provider = Provider.of<TransactionProvider>(
                                context,
                                listen: false);
                            final transaction = todayTransactions[index];
                            final realIndex =
                                provider.transactions.indexOf(transaction);
                            if (realIndex != -1) {
                              await provider.deleteTransaction(realIndex);
                            }
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTransactionScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
