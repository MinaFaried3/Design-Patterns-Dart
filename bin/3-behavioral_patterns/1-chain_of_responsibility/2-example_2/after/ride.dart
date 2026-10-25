enum TripStatus {
  requested,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelled;

  bool get notValidToCancel =>
      this == .completed || this == .cancelled || this == .inProgress;

  bool get isDriverArrived => this == .driverArrived;
}

class Trip {
  final String id;
  final String riderId;
  TripStatus status;
  double cancellationFee;

  Trip({
    required this.id,
    required this.riderId,
    required this.status,
    this.cancellationFee = 0,
  });
}

abstract class TripCancellationHandler {
  TripCancellationHandler? next;

  TripCancellationHandler setNext(TripCancellationHandler handler) {
    next = handler;
    return next!;
  }

  void cancelTrip({required Trip trip, required String currentUserId}) {
    if (next != null) {
      next!.cancelTrip(trip: trip, currentUserId: currentUserId);
    }
  }
}

class ValidTripStatusHandler extends TripCancellationHandler {
  @override
  void cancelTrip({required Trip trip, required String currentUserId}) {
    print("cancelTrip from ValidTripStatusHandler");
    if (trip.status.notValidToCancel) {
      print('Trip cannot be cancelled');
      return;
    }
    return super.cancelTrip(trip: trip, currentUserId: currentUserId);
  }
}

class ValidRiderOwnershipHandler extends TripCancellationHandler {
  @override
  void cancelTrip({required Trip trip, required String currentUserId}) {
    print("cancelTrip from ValidRiderOwnershipHandler");
    if (trip.riderId != currentUserId) {
      print('Unauthorized cancellation');
      return;
    }

    return super.cancelTrip(trip: trip, currentUserId: currentUserId);
  }
}

class CalculateCancellationFeeHandler extends TripCancellationHandler {
  @override
  void cancelTrip({required Trip trip, required String currentUserId}) {
    print("cancelTrip from CalculateCancellationFeeHandler");
    if (trip.status.isDriverArrived) {
      trip.cancellationFee = 25.0;
      print('Cancellation fee applied: 25 EGP');
    }

    return super.cancelTrip(trip: trip, currentUserId: currentUserId);
  }
}

class ExecuteCancellationHandler extends TripCancellationHandler {
  @override
  void cancelTrip({required Trip trip, required String currentUserId}) {
    print("cancelTrip from ExecuteCancellationHandler");
    trip.status = .cancelled;
    print('Trip ${trip.id} cancelled successfully');
  }
}

class TripCancellationService {
  late final TripCancellationHandler chain;

  TripCancellationService() {
    chain = ValidTripStatusHandler()
        .setNext(ValidRiderOwnershipHandler())
        .setNext(CalculateCancellationFeeHandler())
        .setNext(ExecuteCancellationHandler());
  }

  void cancelTrip({required Trip trip, required String currentUserId}) {
    chain.cancelTrip(trip: trip, currentUserId: currentUserId);
  }
}

void main() {
  final trip = Trip(
    id: 'TRIP-1001',
    riderId: 'USER-101',
    status: .driverArrived,
  );

  final service = TripCancellationService();

  service.cancelTrip(trip: trip, currentUserId: 'USER-101');
}
