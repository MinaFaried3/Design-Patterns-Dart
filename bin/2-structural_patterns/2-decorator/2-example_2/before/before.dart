// BEFORE: One notifier accumulates flags and channel branches.
class NotificationService {
  List<String> send(String message, {bool sms = false, bool push = false}) {
    final deliveries = ['Email: $message'];
    if (sms) deliveries.add('SMS: $message');
    if (push) deliveries.add('Push: $message');
    return deliveries;
  }
}

void main() {
  print(NotificationService().send('Order ready', sms: true, push: true));
}
