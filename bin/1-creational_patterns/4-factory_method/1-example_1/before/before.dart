// BEFORE: The notification workflow chooses concrete senders itself.

// 1. PRODUCTS
class EmailSender {
  String send(String message) => 'Email: $message';
}

class SmsSender {
  String send(String message) => 'SMS: $message';
}

// 2. WORKFLOW
class NotificationFlow {
  String notify(String channel, String message) {
    final prepared = '[APP] $message';
    if (channel == 'email') return EmailSender().send(prepared);
    if (channel == 'sms') return SmsSender().send(prepared);
    throw ArgumentError('Unknown channel');
  }
}

// 3. USAGE
void main() {
  final flow = NotificationFlow();
  print(flow.notify('email', 'Welcome'));
  print(flow.notify('sms', 'Welcome'));
}
