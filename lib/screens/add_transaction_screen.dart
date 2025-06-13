import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'income';
  double _amount = 0;
  String _description = '';
  DateTime _date = DateTime.now();
  final List<String> _categories = [
    'Genel',
    'Maaş',
    'Yemek',
    'Ulaşım',
    'Eğlence',
    'Fatura',
    'Sağlık',
    'Alışveriş',
    'Diğer'
  ];
  String _category = 'Genel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni İşlem Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: [
                  DropdownMenuItem(
                      value: 'income',
                      child: Row(children: [
                        Icon(Icons.trending_up, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Gelir')
                      ])),
                  DropdownMenuItem(
                      value: 'expense',
                      child: Row(children: [
                        Icon(Icons.trending_down, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Gider')
                      ]))
                ],
                onChanged: (val) => setState(() => _type = val!),
                decoration: InputDecoration(
                    labelText: 'Tür', prefixIcon: Icon(Icons.category)),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: InputDecoration(
                    labelText: 'Kategori', prefixIcon: Icon(Icons.label)),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Tutar', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Tutar giriniz' : null,
                onSaved: (val) => _amount = double.parse(val!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Açıklama', prefixIcon: Icon(Icons.edit)),
                onSaved: (val) => _description = val ?? '',
              ),
              SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.grey[100],
                title: Text(
                  'Tarih: ${_date.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save_alt),
                  label: Text('Kaydet', style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final transaction = Transaction(
                        type: _type,
                        amount: _amount,
                        description: _description,
                        date: _date,
                        category: _category,
                      );
                      await Provider.of<TransactionProvider>(
                        context,
                        listen: false,
                      ).addTransaction(transaction);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
