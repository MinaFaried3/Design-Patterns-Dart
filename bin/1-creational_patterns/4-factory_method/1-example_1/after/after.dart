// AFTER: Subclasses override a creation hook used by a common workflow.

// 1. PRODUCT CONTRACT AND PRODUCTS
abstract class MessageSender {
  String send(String message);
}

class EmailSender implements MessageSender {
  @override
  String send(String message) => 'Email: $message';
}

class SmsSender implements MessageSender {
  @override
  String send(String message) => 'SMS: $message';
}

// 2. CREATOR: notify is business logic; createSender is the factory method.
abstract class NotificationFlow {
  MessageSender createSender();

  String notify(String message) {
    final prepared = '[APP] $message';
    return createSender().send(prepared);
  }
}

// 3. CONCRETE CREATORS
class EmailFlow extends NotificationFlow {
  @override
  MessageSender createSender() => EmailSender();
}

class SmsFlow extends NotificationFlow {
  @override
  MessageSender createSender() => SmsSender();
}

// 4. USAGE
void main() {
  for (final flow in <NotificationFlow>[EmailFlow(), SmsFlow()]) {
    print(flow.notify('Welcome'));
  }
  assert(EmailFlow().notify('Welcome') == 'Email: [APP] Welcome');
}
