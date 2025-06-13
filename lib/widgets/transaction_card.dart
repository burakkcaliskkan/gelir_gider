import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final Color color = isIncome ? Colors.green : Colors.red;
    final Color categoryColor = getCategoryColor(transaction.category);
    final IconData categoryIcon = getCategoryIcon(transaction.category);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColor.withOpacity(0.2),
          child: Icon(categoryIcon, color: categoryColor, size: 28),
        ),
        title: Text(
          transaction.description.isEmpty
              ? (isIncome ? 'Gelir' : 'Gider')
              : transaction.description,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
            '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}'),
        trailing: Text(
          '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ₺',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Maaş':
        return Colors.blueAccent;
      case 'Yemek':
        return Colors.orangeAccent;
      case 'Ulaşım':
        return Colors.teal;
      case 'Eğlence':
        return Colors.purpleAccent;
      case 'Fatura':
        return Colors.redAccent;
      case 'Sağlık':
        return Colors.green;
      case 'Alışveriş':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Maaş':
        return Icons.payments;
      case 'Yemek':
        return Icons.restaurant;
      case 'Ulaşım':
        return Icons.directions_bus;
      case 'Eğlence':
        return Icons.movie;
      case 'Fatura':
        return Icons.receipt_long;
      case 'Sağlık':
        return Icons.health_and_safety;
      case 'Alışveriş':
        return Icons.shopping_bag;
      default:
        return Icons.label;
    }
  }
}
