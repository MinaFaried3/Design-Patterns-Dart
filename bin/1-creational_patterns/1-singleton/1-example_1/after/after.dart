// AFTER: A private constructor controls creation of one shared instance.

// 1. SINGLETON
class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();

  factory AppLogger() => _instance;

  final List<String> _messages = [];
  List<String> get messages => List.unmodifiable(_messages);

  void log(String message) => _messages.add(message);
}

// 2. USAGE
void main() {
  final checkoutLogger = AppLogger();
  final paymentLogger = AppLogger();
  checkoutLogger.log('Order created');
  paymentLogger.log('Payment accepted');

  assert(identical(checkoutLogger, paymentLogger));
  assert(checkoutLogger.messages.length == 2);
  print('Same logger: ${identical(checkoutLogger, paymentLogger)}');
  print('Shared history: ${checkoutLogger.messages}');
}
