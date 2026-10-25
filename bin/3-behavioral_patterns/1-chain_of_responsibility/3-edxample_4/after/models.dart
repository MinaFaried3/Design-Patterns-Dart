enum VehicleType { economy, premium }

class Rider {
  final String id;
  final bool isVerified;
  final bool isBlocked;
  bool hasActiveTrip;
  double walletBalance;

  Rider({
    required this.id,
    required this.isVerified,
    required this.isBlocked,
    required this.hasActiveTrip,
    required this.walletBalance,
  });
}

class Driver {
  final String id;
  final VehicleType vehicleType;
  final int availableSeats;
  final double distanceKm;
  final double rating;
  bool isOnline;
  bool isBusy;

  Driver({
    required this.id,
    required this.vehicleType,
    required this.availableSeats,
    required this.distanceKm,
    required this.rating,
    required this.isOnline,
    required this.isBusy,
  });
}

class BookingRequest {
  final String requestId;
  final Rider rider;
  final double distanceKm;
  final int passengers;
  final VehicleType vehicleType;
  final String? promoCode;
  final bool isPeakHour;

  BookingRequest({
    required this.requestId,
    required this.rider,
    required this.distanceKm,
    required this.passengers,
    required this.vehicleType,
    this.promoCode,
    this.isPeakHour = false,
  });
}

class BookingResult {
  final bool success;
  final String message;
  final String? tripId;
  final String? driverId;
  final double? fare;

  const BookingResult.failure(this.message)
    : success = false,
      tripId = null,
      driverId = null,
      fare = null;

  const BookingResult.booked({
    required this.tripId,
    required this.driverId,
    required this.fare,
  }) : success = true,
       message = 'Trip booked successfully';
}

// =============================
// 2. SHARED BOOKING CONTEXT
// =============================

typedef RollbackAction = Future<void> Function();

class BookingContext {
  final BookingRequest request;

  double? fare;
  Driver? selectedDriver;

  final List<RollbackAction> _rollbackActions = [];

  BookingContext(this.request);

  void registerRollback(RollbackAction action) {
    _rollbackActions.add(action);
  }

  Future<void> rollback() async {
    // Undo side effects in reverse order.
    final actions = _rollbackActions.reversed.toList();
    _rollbackActions.clear();

    for (final action in actions) {
      await action();
    }
  }

  void commit() {
    _rollbackActions.clear();
  }
}
