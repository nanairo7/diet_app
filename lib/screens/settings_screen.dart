import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../models/notification_slot.dart';
import '../providers/diet_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notificationService = NotificationService();
  double? _previewGoal;
  bool _notificationEnabled = false;
  List<NotificationSlot> _slots = const [
    NotificationSlot(enabled: false, hour: 8, minute: 0),
    NotificationSlot(enabled: false, hour: 12, minute: 0),
    NotificationSlot(enabled: true, hour: 20, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<DietProvider>();
    if (provider.targetWeight != null) {
      _weightController.text = provider.targetWeight!.toStringAsFixed(1);
      _previewGoal = provider.calorieGoal;
    }
    _weightController.addListener(_updatePreview);
    _loadNotificationSettings(provider);
  }

  void _loadNotificationSettings(DietProvider provider) {
    setState(() {
      _notificationEnabled = provider.notificationEnabled;
      _slots = List.of(provider.notificationSlots);
    });
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

  Future<void> _toggleNotification(bool enabled) async {
    if (enabled) {
      await _notificationService.init();
      final granted = await _notificationService.requestPermission();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.notificationPermissionDenied),
          ),
        );
        return;
      }
      await _notificationService.scheduleSlots(_slots);
    } else {
      await _notificationService.cancelAll();
    }
    if (!mounted) return;
    await context.read<DietProvider>().saveNotificationSettings(
          enabled: enabled,
          slots: _slots,
        );
    setState(() => _notificationEnabled = enabled);
  }

  Future<void> _toggleSlot(int index, bool enabled) async {
    final updated = List.of(_slots);
    updated[index] = updated[index].copyWith(enabled: enabled);
    setState(() => _slots = updated);
    if (_notificationEnabled) {
      await _notificationService.scheduleSlots(updated);
    }
    await context.read<DietProvider>().saveNotificationSettings(
          enabled: _notificationEnabled,
          slots: updated,
        );
  }

  Future<void> _pickTime(int index) async {
    final current = _slots[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null || !mounted) return;
    final updated = List.of(_slots);
    updated[index] = updated[index].copyWith(
      hour: picked.hour,
      minute: picked.minute,
    );
    setState(() => _slots = updated);
    if (_notificationEnabled) {
      await _notificationService.scheduleSlots(updated);
    }
    await context.read<DietProvider>().saveNotificationSettings(
          enabled: _notificationEnabled,
          slots: updated,
        );
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
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.notificationSection,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications),
                          title: const Text(AppStrings.notificationEnabled),
                          value: _notificationEnabled,
                          onChanged: _toggleNotification,
                        ),
                        if (_notificationEnabled) ...[
                          const Divider(height: 1),
                          _buildSlotTile(context, theme, 0, AppStrings.notificationMorning),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildSlotTile(context, theme, 1, AppStrings.notificationNoon),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildSlotTile(context, theme, 2, AppStrings.notificationEvening),
                        ],
                      ],
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

  Widget _buildSlotTile(
      BuildContext context, ThemeData theme, int index, String label) {
    final slot = _slots[index];
    final timeLabel = TimeOfDay(hour: slot.hour, minute: slot.minute)
        .format(context);
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(
          label,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
      title: slot.enabled
          ? GestureDetector(
              onTap: () => _pickTime(index),
              child: Text(
                timeLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Text(
              timeLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: Switch(
        value: slot.enabled,
        onChanged: (v) => _toggleSlot(index, v),
      ),
      onTap: slot.enabled ? () => _pickTime(index) : null,
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
