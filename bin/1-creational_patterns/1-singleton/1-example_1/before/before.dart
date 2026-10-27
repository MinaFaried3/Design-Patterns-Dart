// BEFORE: Each caller creates a logger with a separate history.

// 1. MODEL
class AppLogger {
  final List<String> messages = [];

  void log(String message) => messages.add(message);
}

// 2. USAGE: The two features expect to share the application log.
void main() {
  final checkoutLogger = AppLogger();
  final paymentLogger = AppLogger();

  checkoutLogger.log('Order created');
  paymentLogger.log('Payment accepted');

  print('Same logger: ${identical(checkoutLogger, paymentLogger)}');
  print('Checkout history: ${checkoutLogger.messages}');
  print('Payment history: ${paymentLogger.messages}');
}
