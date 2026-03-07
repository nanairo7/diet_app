class NotificationSlot {
  final bool enabled;
  final int hour;
  final int minute;

  const NotificationSlot({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  NotificationSlot copyWith({bool? enabled, int? hour, int? minute}) {
    return NotificationSlot(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
