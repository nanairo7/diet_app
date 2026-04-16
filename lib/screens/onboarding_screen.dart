import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/diet_provider.dart';
import '../widgets/keyboard_dismissible.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double? _previewGoal;

  @override
  void initState() {
    super.initState();
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

  Future<void> _start({bool skip = false}) async {
    final provider = context.read<DietProvider>();
    if (!skip) {
      if (!_formKey.currentState!.validate()) return;
      final weight = double.parse(_weightController.text.trim());
      await provider.setTargetWeight(weight);
    }

    await provider.completeOnboarding();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: KeyboardDismissible(
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.restaurant_menu,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.onboardingTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.onboardingSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              _FeatureTile(
                icon: Icons.edit_note,
                text: AppStrings.onboardingFeature1,
              ),
              const SizedBox(height: 12),
              _FeatureTile(
                icon: Icons.local_fire_department,
                text: AppStrings.onboardingFeature2,
              ),
              const SizedBox(height: 12),
              _FeatureTile(
                icon: Icons.calendar_month,
                text: AppStrings.onboardingFeature3,
              ),
              const SizedBox(height: 40),
              Text(
                AppStrings.onboardingWeightLabel,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: AppStrings.targetWeight,
                    prefixIcon: const Icon(Icons.monitor_weight),
                    border: const OutlineInputBorder(),
                    suffixText: 'kg',
                    helperText: _previewGoal != null
                        ? '${AppStrings.calorieGoal}: ${_previewGoal!.toStringAsFixed(0)} ${AppStrings.kcalUnit}'
                        : null,
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
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _start(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text(AppStrings.onboardingStart),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _start(skip: true),
                child: const Text(AppStrings.onboardingSkip),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}
