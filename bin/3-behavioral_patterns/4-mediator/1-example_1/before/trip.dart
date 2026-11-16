class RiderApp {
  void driverAccepted(String tripId) {
    print('Rider: Driver accepted trip $tripId');
  }

  void tripCompleted(String tripId) {
    print('Rider: Trip $tripId completed');
  }
}

class PaymentService {
  Future<void> capturePayment(String tripId, double amount) async {
    print('Payment: Charged $amount for $tripId');
  }
}

class NotificationService {
  void send(String message) {
    print('Notification: $message');
  }
}

class DriverApp {
  final RiderApp riderApp;
  final PaymentService paymentService;
  final NotificationService notificationService;

  DriverApp({
    required this.riderApp,
    required this.paymentService,
    required this.notificationService,
  });

  void acceptTrip(String tripId) {
    riderApp.driverAccepted(tripId);

    notificationService.send('Driver accepted trip $tripId');
  }

  Future<void> completeTrip(String tripId, double fare) async {
    await paymentService.capturePayment(tripId, fare);

    riderApp.tripCompleted(tripId);

    notificationService.send('Trip completed successfully');
  }
}

Future<void> main() async {
  final driver = DriverApp(
    riderApp: RiderApp(),
    paymentService: PaymentService(),
    notificationService: NotificationService(),
  );

  driver.acceptTrip('TRIP-1001');

  await driver.completeTrip('TRIP-1001', 150);
}
