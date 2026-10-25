// =============================
// 1. MODELS
// =============================

import 'dart:async';

import 'models.dart';

// =============================
// 3. BACKEND ABSTRACTION
// =============================

abstract class BookingGateway {
  Future<bool> verifyRider(Rider rider);

  Future<List<Driver>> getNearbyDrivers();

  Future<String> saveTrip({
    required String riderId,
    required String driverId,
    required double fare,
  });
}

class FakeBookingGateway implements BookingGateway {
  final List<Driver> drivers;
  int _tripCounter = 1000;

  bool failNextSave = false;

  FakeBookingGateway(this.drivers);

  @override
  Future<bool> verifyRider(Rider rider) async {
    return rider.isVerified;
  }

  @override
  Future<List<Driver>> getNearbyDrivers() async {
    return List.of(drivers);
  }

  @override
  Future<String> saveTrip({
    required String riderId,
    required String driverId,
    required double fare,
  }) async {
    await Future<void>.delayed(Duration.zero);

    if (failNextSave) {
      failNextSave = false;
      throw StateError('Simulated database failure');
    }

    return 'TRIP-${++_tripCounter}';
  }
}

// =============================
// 4. BASE HANDLER
// =============================

abstract class BookingHandler {
  BookingHandler? _next;

  BookingHandler setNext(BookingHandler handler) {
    if (identical(this, handler)) {
      throw ArgumentError('Handler cannot reference itself');
    }

    _next = handler;
    return handler;
  }

  Future<BookingResult> handle(BookingContext context);

  Future<BookingResult> handleNext(BookingContext context) {
    final nextHandler = _next;

    if (nextHandler == null) {
      throw StateError('Booking chain is incomplete');
    }

    return nextHandler.handle(context);
  }
}

// =============================
// 5. CONCRETE HANDLERS
// =============================

// Handler 1: Validate request
class ValidateRequestHandler extends BookingHandler {
  @override
  Future<BookingResult> handle(BookingContext context) async {
    final request = context.request;

    if (request.requestId.isEmpty ||
        request.rider.id.isEmpty ||
        !request.distanceKm.isFinite ||
        request.distanceKm <= 0 ||
        request.passengers <= 0 ||
        request.passengers > 6) {
      return const BookingResult.failure('Invalid booking request');
    }

    return handleNext(context);
  }
}

// Handler 2: Validate rider
class ValidateRiderHandler extends BookingHandler {
  final BookingGateway gateway;

  ValidateRiderHandler(this.gateway);

  @override
  Future<BookingResult> handle(BookingContext context) async {
    final rider = context.request.rider;

    final verified = await gateway.verifyRider(rider);

    if (!verified || rider.isBlocked) {
      return const BookingResult.failure('Rider is not allowed to book');
    }

    return handleNext(context);
  }
}

// Handler 3: Check active trips
class ActiveTripHandler extends BookingHandler {
  @override
  Future<BookingResult> handle(BookingContext context) async {
    if (context.request.rider.hasActiveTrip) {
      return const BookingResult.failure('Rider already has an active trip');
    }

    return handleNext(context);
  }
}

// Handler 4: Calculate fare
class FareCalculationHandler extends BookingHandler {
  @override
  Future<BookingResult> handle(BookingContext context) async {
    final request = context.request;

    double fare = request.distanceKm * 12;

    if (request.vehicleType == VehicleType.premium) {
      fare *= 1.5;
    }

    if (request.isPeakHour) {
      fare *= 1.3;
    }

    if (request.promoCode != null) {
      if (request.promoCode == 'SAVE20') {
        fare *= 0.8;
      } else {
        return const BookingResult.failure('Invalid promo code');
      }
    }

    context.fare = double.parse(fare.toStringAsFixed(2));

    return handleNext(context);
  }
}

// Handler 5: Reserve payment
class PaymentReservationHandler extends BookingHandler {
  @override
  Future<BookingResult> handle(BookingContext context) async {
    final rider = context.request.rider;
    final fare = context.fare;

    if (fare == null) {
      throw StateError('Fare has not been calculated');
    }

    if (rider.walletBalance < fare) {
      return const BookingResult.failure('Insufficient wallet balance');
    }

    // Simulated wallet reservation.
    rider.walletBalance -= fare;

    // Register compensation before continuing.
    context.registerRollback(() async {
      rider.walletBalance += fare;
    });

    return handleNext(context);
  }
}

// Handler 6: Find available driver
class DriverMatchingHandler extends BookingHandler {
  final BookingGateway gateway;

  DriverMatchingHandler(this.gateway);

  @override
  Future<BookingResult> handle(BookingContext context) async {
    final request = context.request;

    final drivers = await gateway.getNearbyDrivers();

    final eligible = drivers.where((driver) {
      return driver.isOnline &&
          !driver.isBusy &&
          driver.vehicleType == request.vehicleType &&
          driver.availableSeats >= request.passengers &&
          driver.distanceKm <= 5 &&
          driver.rating >= 4.2;
    }).toList();

    if (eligible.isEmpty) {
      return const BookingResult.failure('No available drivers');
    }

    eligible.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    context.selectedDriver = eligible.first;

    return handleNext(context);
  }
}

// Handler 7: Execute booking
class CreateTripHandler extends BookingHandler {
  final BookingGateway gateway;

  CreateTripHandler(this.gateway);

  @override
  Future<BookingResult> handle(BookingContext context) async {
    final rider = context.request.rider;
    final driver = context.selectedDriver;
    final fare = context.fare;

    if (driver == null || fare == null) {
      throw StateError('Booking context is incomplete');
    }

    final tripId = await gateway.saveTrip(
      riderId: rider.id,
      driverId: driver.id,
      fare: fare,
    );

    driver.isBusy = true;
    rider.hasActiveTrip = true;

    return BookingResult.booked(
      tripId: tripId,
      driverId: driver.id,
      fare: fare,
    );
  }
}

// =============================
// 6. BUILD THE CHAIN
// =============================

BookingHandler buildBookingChain(BookingGateway gateway) {
  final validation = ValidateRequestHandler();

  validation
      .setNext(ValidateRiderHandler(gateway))
      .setNext(ActiveTripHandler())
      .setNext(FareCalculationHandler())
      .setNext(PaymentReservationHandler())
      .setNext(DriverMatchingHandler(gateway))
      .setNext(CreateTripHandler(gateway));

  return validation;
}

// =============================
// 7. BOOKING SERVICE
// =============================

class TripBookingService {
  final BookingHandler _chain;

  final Map<String, BookingResult> _completed = {};
  final Map<String, Future<BookingResult>> _inFlight = {};

  // Demo-only serialization within this service instance.
  Future<void> _queue = Future<void>.value();

  TripBookingService(this._chain);

  Future<BookingResult> bookTrip(BookingRequest request) {
    final key = '${request.rider.id}:${request.requestId}';

    // Already completed: return the same result.
    final cached = _completed[key];
    if (cached != null) {
      return Future.value(cached);
    }

    // Already executing: reuse the same Future.
    final existing = _inFlight[key];
    if (existing != null) {
      return existing;
    }

    // Serialize bookings to protect this in-memory demo
    // from assigning the same driver concurrently.
    final job = _queue.then((_) => _execute(request, key));

    // Keep the queue alive even if a job fails.
    _queue = job.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );

    _inFlight[key] = job;

    // Cleanup when the request finishes.
    job.then<void>(
      (_) {
        if (identical(_inFlight[key], job)) {
          _inFlight.remove(key);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (identical(_inFlight[key], job)) {
          _inFlight.remove(key);
        }
      },
    );

    return job;
  }

  Future<BookingResult> _execute(BookingRequest request, String key) async {
    final context = BookingContext(request);

    try {
      final result = await _chain.handle(context);

      if (!result.success) {
        // A handler rejected the booking.
        await context.rollback();
        return result;
      }

      // Success: payment reservation is retained.
      context.commit();
      _completed[key] = result;

      return result;
    } catch (error) {
      // Failure after a payment reservation.
      try {
        await context.rollback();
      } catch (rollbackError) {
        return BookingResult.failure(
          'Booking failed and rollback requires '
          'reconciliation: $rollbackError',
        );
      }

      return BookingResult.failure('Booking failed: $error');
    }
  }
}
