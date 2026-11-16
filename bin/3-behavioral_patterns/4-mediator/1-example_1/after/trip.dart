abstract interface class TripMediator {
  void onDriverAccepted(String tripId);

  Future<void> onTripCompleted(String tripId, double fare);
}

class DriverApp {
  final TripMediator mediator;

  DriverApp(this.mediator);

  void acceptTrip(String tripId) {
    mediator.onDriverAccepted(tripId);
  }

  Future<void> completeTrip(String tripId, double fare) {
    return mediator.onTripCompleted(tripId, fare);
  }
}

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

class RideSharingMediator implements TripMediator {
  final RiderApp riderApp;
  final PaymentService paymentService;
  final NotificationService notificationService;

  RideSharingMediator({
    required this.riderApp,
    required this.paymentService,
    required this.notificationService,
  });

  @override
  void onDriverAccepted(String tripId) {
    riderApp.driverAccepted(tripId);

    notificationService.send('Driver accepted trip $tripId');
  }

  @override
  Future<void> onTripCompleted(String tripId, double fare) async {
    await paymentService.capturePayment(tripId, fare);

    riderApp.tripCompleted(tripId);

    notificationService.send('Trip completed successfully');
  }
}

Future<void> main() async {
  final mediator = RideSharingMediator(
    riderApp: RiderApp(),
    paymentService: PaymentService(),
    notificationService: NotificationService(),
  );

  final driver = DriverApp(mediator);

  driver.acceptTrip('TRIP-1001');

  await driver.completeTrip('TRIP-1001', 150);
}
