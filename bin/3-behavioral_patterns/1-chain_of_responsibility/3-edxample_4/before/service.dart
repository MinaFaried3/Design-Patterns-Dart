import 'models.dart';

class TripBookingService {
  final List<Driver> drivers;

  final Map<String, BookingResult> _processedRequests = {};

  int _tripCounter = 1000;

  TripBookingService({required this.drivers});

  Future<BookingResult> bookTrip(BookingRequest request) async {
    final rider = request.rider;

    // 1. IDEMPOTENCY
    final cached = _processedRequests[request.requestId];

    if (cached != null) {
      return cached;
    }

    // 2. VALIDATE REQUEST
    if (rider.id.isEmpty ||
        request.distanceKm <= 0 ||
        request.passengers <= 0 ||
        request.passengers > 6) {
      return const BookingResult(
        success: false,
        message: 'Invalid booking request',
      );
    }

    // 3. VALIDATE RIDER
    final isVerified = await verifyRider(rider);

    if (!isVerified || rider.isBlocked) {
      return const BookingResult(
        success: false,
        message: 'Rider is not allowed to book',
      );
    }

    // 4. CHECK ACTIVE TRIP
    if (rider.hasActiveTrip) {
      return const BookingResult(
        success: false,
        message: 'Rider already has an active trip',
      );
    }

    // 5. CALCULATE FARE
    double fare = request.distanceKm * 12;

    if (request.vehicleType == VehicleType.premium) {
      fare *= 1.5;
    }

    if (request.isPeakHour) {
      fare *= 1.3;
    }

    // 6. APPLY PROMO CODE
    if (request.promoCode != null) {
      if (request.promoCode == 'SAVE20') {
        fare *= 0.8;
      } else {
        return const BookingResult(
          success: false,
          message: 'Invalid promo code',
        );
      }
    }

    fare = double.parse(fare.toStringAsFixed(2));

    // 7. CHECK WALLET BALANCE
    if (rider.walletBalance < fare) {
      return const BookingResult(
        success: false,
        message: 'Insufficient wallet balance',
      );
    }

    // 8. RESERVE PAYMENT
    rider.walletBalance -= fare;
    bool paymentReserved = true;

    try {
      // 9. FIND ELIGIBLE DRIVERS
      final nearbyDrivers = await getNearbyDrivers();

      final eligibleDrivers = nearbyDrivers.where((driver) {
        return driver.isOnline &&
            !driver.isBusy &&
            driver.vehicleType == request.vehicleType &&
            driver.availableSeats >= request.passengers &&
            driver.distanceKm <= 5 &&
            driver.rating >= 4.2;
      }).toList();

      // 10. HANDLE NO DRIVER
      if (eligibleDrivers.isEmpty) {
        rider.walletBalance += fare;
        paymentReserved = false;

        return const BookingResult(
          success: false,
          message: 'No available drivers',
        );
      }

      // 11. SELECT NEAREST DRIVER
      eligibleDrivers.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      final selectedDriver = eligibleDrivers.first;

      // 12. CREATE TRIP
      final tripId = 'TRIP-${++_tripCounter}';

      await saveTrip(
        tripId: tripId,
        riderId: rider.id,
        driverId: selectedDriver.id,
        fare: fare,
      );

      // 13. UPDATE STATE
      selectedDriver.isBusy = true;
      rider.hasActiveTrip = true;

      paymentReserved = false;

      final result = BookingResult(
        success: true,
        message: 'Trip booked successfully',
        tripId: tripId,
        driverId: selectedDriver.id,
        fare: fare,
      );

      // 14. CACHE RESULT
      _processedRequests[request.requestId] = result;

      return result;
    } catch (error) {
      // 15. PAYMENT ROLLBACK
      if (paymentReserved) {
        rider.walletBalance += fare;
      }

      return BookingResult(success: false, message: 'Booking failed: $error');
    }
  }

  Future<bool> verifyRider(Rider rider) async {
    return Future.value(rider.isVerified);
  }

  Future<List<Driver>> getNearbyDrivers() async {
    return Future.value(drivers);
  }

  Future<void> saveTrip({
    required String tripId,
    required String riderId,
    required String driverId,
    required double fare,
  }) async {
    // Simulated database operation.
    await Future<void>.value();
  }
}
