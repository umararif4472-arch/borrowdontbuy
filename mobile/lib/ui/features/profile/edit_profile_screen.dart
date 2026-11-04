import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _neighborhood;

  @override
  void initState() {
    super.initState();
    final me = context.read<AppState>().currentUser;
    _name = TextEditingController(text: me.name);
    _bio = TextEditingController(text: me.bio);
    _neighborhood = TextEditingController(text: me.neighborhood);
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _neighborhood.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Enter your name (at least 2 characters).'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bio,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'What do you lend, borrow, or just enjoy?',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _neighborhood,
              decoration: const InputDecoration(labelText: 'Neighborhood *'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter your neighborhood.'
                  : null,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                context.read<AppState>().updateProfile(
                  name: _name.text,
                  bio: _bio.text,
                  neighborhood: _neighborhood.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated.')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
