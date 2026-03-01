import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/diet_provider.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  bool _addToFavorites = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addFood),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.foodName,
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.calories,
                      prefixIcon: Icon(Icons.local_fire_department),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final num = double.tryParse(value.trim());
                      if (num == null || num < 0) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.protein,
                      prefixIcon: Icon(Icons.fitness_center),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final num = double.tryParse(value.trim());
                      if (num == null || num < 0) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _addToFavorites,
                    onChanged: (value) => setState(() => _addToFavorites = value),
                    title: const Text(AppStrings.addToFavorites),
                    secondary: const Icon(Icons.star_outline),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addButton),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final calories = double.parse(_caloriesController.text.trim());
    final protein = double.parse(_proteinController.text.trim());
    final provider = context.read<DietProvider>();

    await provider.addEntry(
      name: name,
      calories: calories,
      protein: protein,
    );

    if (_addToFavorites) {
      await provider.addFavorite(
        name: name,
        calories: calories,
        protein: protein,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _addToFavorites
              ? '${AppStrings.added}・${AppStrings.favoriteAdded}'
              : AppStrings.added,
        ),
      ),
    );

    Navigator.pop(context);
  }
}
