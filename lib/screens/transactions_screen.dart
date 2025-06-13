import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime? _selectedDate;
  String _search = '';
  String? _selectedCategory;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    var filtered = provider.transactions;

    // Arama filtresi
    if (_search.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.description.toLowerCase().contains(_search.toLowerCase()) ||
              t.category.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    // Kategori filtresi
    if (_selectedCategory != null) {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }
    // Tür filtresi
    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }
    // Tarih aralığı filtresi
    if (_startDate != null && _endDate != null) {
      filtered = filtered
          .where((t) =>
              t.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
              t.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }
    // Ay filtresi (eski)
    if (_selectedDate != null) {
      filtered = filtered
          .where((t) =>
              t.date.year == _selectedDate!.year &&
              t.date.month == _selectedDate!.month)
          .toList();
    }

    final categories =
        provider.transactions.map((t) => t.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Geçmiş İşlemler'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: 'Tarih aralığı',
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
              }
            },
          ),
          if (_startDate != null && _endDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              tooltip: 'Tarih filtresini temizle',
              onPressed: () => setState(() {
                _startDate = null;
                _endDate = null;
              }),
            ),
          IconButton(
            icon: Icon(Icons.download_rounded),
            tooltip: 'CSV Dışa Aktar',
            onPressed: () async {
              final provider =
                  Provider.of<TransactionProvider>(context, listen: false);
              final rows = <List<String>>[
                ['Tarih', 'Tür', 'Tutar', 'Açıklama', 'Kategori'],
                ...provider.transactions.map((t) => [
                      DateFormat('yyyy-MM-dd').format(t.date),
                      t.type,
                      t.amount.toString(),
                      t.description,
                      t.category,
                    ]),
              ];
              String csv = const ListToCsvConverter().convert(rows);
              String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'CSV olarak kaydet',
                fileName: 'gelir_gider_kayitlari.csv',
              );
              if (outputFile != null) {
                final file = File(outputFile);
                await file.writeAsString(csv);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('CSV dosyası kaydedildi: $outputFile')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Açıklama veya kategori ara',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedType,
                  hint: Text('Tür'),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Hepsi')),
                    DropdownMenuItem(value: 'income', child: Text('Gelir')),
                    DropdownMenuItem(value: 'expense', child: Text('Gider')),
                  ],
                  onChanged: (val) => setState(() => _selectedType = val),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('Kategori'),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Hepsi')),
                    ...categories
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('Kayıt yok.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => Dismissible(
                      key: Key(index.toString()),
                      background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.delete, color: Colors.white)),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) {
                        Provider.of<TransactionProvider>(context, listen: false)
                            .deleteTransaction(index);
                      },
                      child: TransactionCard(transaction: filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
