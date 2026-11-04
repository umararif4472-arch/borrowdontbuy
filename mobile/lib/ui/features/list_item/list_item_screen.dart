import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/item.dart';
import '../../../state/app_state.dart';

class ListItemScreen extends StatefulWidget {
  const ListItemScreen({super.key});
  @override
  State<ListItemScreen> createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _condition = TextEditingController();
  final _maxDays = TextEditingController(text: '7');
  final _deposit = TextEditingController();
  final _fee = TextEditingController();
  String _category = 'Tools';

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _condition.dispose();
    _maxDays.dispose();
    _deposit.dispose();
    _fee.dispose();
    super.dispose();
  }

  int? _parseOptional(String v) =>
      v.trim().isEmpty ? null : int.tryParse(v.trim());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List an item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            const Text(
              'Share something neighbors can borrow. Be specific — brand, size, and what it is good for.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. 20V Cordless Drill + Bit Kit',
              ),
              validator: (v) => (v == null || v.trim().length < 4)
                  ? 'Give your item a clear title (at least 4 characters).'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category *'),
              items: kItemCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Tools'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _desc,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'What is it, what is included, any quirks?',
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Add a short description (at least 10 characters).'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition *',
                hintText: 'e.g. Good — works perfectly, small scuff',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Describe the condition honestly.'
                  : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxDays,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max days *'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return (n == null || n < 1 || n > 30)
                          ? 'Enter 1–30 days.'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _deposit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Deposit (\$)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = int.tryParse(v.trim());
                      return (n == null || n < 0)
                          ? 'Enter a whole dollar amount.'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fee,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fee/day (\$)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = int.tryParse(v.trim());
                      return (n == null || n < 0)
                          ? 'Enter a whole dollar amount.'
                          : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                context.read<AppState>().createItem(
                  title: _title.text,
                  category: _category,
                  description: _desc.text,
                  condition: _condition.text,
                  maxDurationDays: int.parse(_maxDays.text.trim()),
                  depositAmount: _parseOptional(_deposit.text),
                  dailyFee: _parseOptional(_fee.text),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Listed — your item is now visible in Explore.',
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('List item'),
            ),
          ],
        ),
      ),
    );
  }
}
