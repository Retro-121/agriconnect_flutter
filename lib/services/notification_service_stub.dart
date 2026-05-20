class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // No‑op for web builds – flutter_local_notifications does not support web.
  }

  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    // No‑op for web builds.
  }

  Future<void> cancelNotification(int id) async {
    // No‑op for web builds.
  }
}
