// AFTER: Optional delivery channels are composable wrappers.

// 1. COMPONENT
abstract class Notifier {
  List<String> send(String message);
}

class EmailNotifier implements Notifier {
  @override
  List<String> send(String message) => ['Email: $message'];
}

// 2. DECORATORS
abstract class NotifierDecorator implements Notifier {
  final Notifier inner;
  NotifierDecorator(this.inner);
}

class SmsNotifier extends NotifierDecorator {
  SmsNotifier(super.inner);
  @override
  List<String> send(String message) => [
    ...inner.send(message),
    'SMS: $message',
  ];
}

class PushNotifier extends NotifierDecorator {
  PushNotifier(super.inner);
  @override
  List<String> send(String message) => [
    ...inner.send(message),
    'Push: $message',
  ];
}

// 3. CLIENT
List<String> notifyCustomer(Notifier notifier) => notifier.send('Order ready');

void main() {
  final emailOnly = notifyCustomer(EmailNotifier());
  final allChannels = notifyCustomer(
    PushNotifier(SmsNotifier(EmailNotifier())),
  );
  assert(emailOnly.length == 1 && allChannels.length == 3);
  print(emailOnly);
  print(allChannels);
}
