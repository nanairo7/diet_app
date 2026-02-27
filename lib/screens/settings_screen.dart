import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/diet_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  double? _previewGoal;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DietProvider>();
    if (provider.targetWeight != null) {
      _weightController.text = provider.targetWeight!.toStringAsFixed(1);
      _previewGoal = provider.calorieGoal;
    }
    _weightController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _weightController.removeListener(_updatePreview);
    _weightController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final value = double.tryParse(_weightController.text.trim());
    setState(() {
      _previewGoal = value != null && value > 0 ? value * 34 : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
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
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.targetWeight,
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.required;
                      }
                      final num = double.tryParse(value.trim());
                      if (num == null || num <= 0) {
                        return AppStrings.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${AppStrings.calorieGoal}: ',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            _previewGoal != null
                                ? '${_previewGoal!.toStringAsFixed(0)} ${AppStrings.kcalUnit}'
                                : AppStrings.notSet,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _previewGoal != null
                                  ? Colors.orange.shade700
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text(AppStrings.save),
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text.trim());
    context.read<DietProvider>().setTargetWeight(weight);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saved)),
    );

    Navigator.pop(context);
  }
}
