enum TripStatus {
  requested,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelled,
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

class TripCancellationService {
  void cancelTrip({required Trip trip, required String currentUserId}) {
    // 1. Validate trip status
    if (trip.status == .completed ||
        trip.status == .cancelled ||
        trip.status == .inProgress) {
      print('Trip cannot be cancelled');
      return;
    }

    // 2. Validate rider ownership
    if (trip.riderId != currentUserId) {
      print('Unauthorized cancellation');
      return;
    }

    // 3. Calculate cancellation fee
    if (trip.status == .driverArrived) {
      trip.cancellationFee = 25.0;
      print('Cancellation fee applied: 25 EGP');
    }

    // 4. Execute cancellation
    trip.status = .cancelled;
    print('Trip ${trip.id} cancelled successfully');
  }
}

void main() {
  final trip = Trip(
    id: 'TRIP-1001',
    riderId: 'USER-101',
    status: TripStatus.driverArrived,
  );

  final service = TripCancellationService();

  service.cancelTrip(trip: trip, currentUserId: 'USER-101');
}
