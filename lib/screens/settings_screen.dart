import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _limit;
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // context ile ilgili işlemleri burada YAPMA!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      setState(() {
        _limit = provider.monthlyLimit;
        _nameController.text = provider.userName;
        _avatarController.text = provider.avatarUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aylık Harcama Limiti',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _limit?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Limit (₺)',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Limit giriniz' : null,
                onSaved: (val) => _limit = double.tryParse(val ?? '0') ?? 0,
              ),
              const SizedBox(height: 24),
              const Text('Profil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
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
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Adınız'),
                      onFieldSubmitted: (val) => provider.setUserName(val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(
                    labelText: 'Avatar URL (opsiyonel)',
                    prefixIcon: Icon(Icons.image)),
                onFieldSubmitted: (val) => provider.setAvatarUrl(val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await provider.setMonthlyLimit(_limit ?? 0);
                      await provider.setUserName(_nameController.text);
                      await provider.setAvatarUrl(_avatarController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ayarlar kaydedildi!')),
                        );
                      }
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
