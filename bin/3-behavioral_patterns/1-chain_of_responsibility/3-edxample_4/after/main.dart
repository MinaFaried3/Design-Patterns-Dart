import 'chain.dart';
import 'models.dart';

// =============================
// 8. USAGE
// =============================

Future<void> main() async {
  final rider = Rider(
    id: 'RIDER-101',
    isVerified: true,
    isBlocked: false,
    hasActiveTrip: false,
    walletBalance: 500,
  );

  final drivers = [
    Driver(
      id: 'DRIVER-1',
      vehicleType: VehicleType.economy,
      availableSeats: 4,
      distanceKm: 2.5,
      rating: 4.8,
      isOnline: true,
      isBusy: false,
    ),
    Driver(
      id: 'DRIVER-2',
      vehicleType: VehicleType.economy,
      availableSeats: 4,
      distanceKm: 1.2,
      rating: 4.9,
      isOnline: true,
      isBusy: false,
    ),
    Driver(
      id: 'DRIVER-3',
      vehicleType: VehicleType.premium,
      availableSeats: 4,
      distanceKm: 0.8,
      rating: 5.0,
      isOnline: true,
      isBusy: false,
    ),
  ];

  final gateway = FakeBookingGateway(drivers);

  final service = TripBookingService(buildBookingChain(gateway));

  final request = BookingRequest(
    requestId: 'REQ-1001',
    rider: rider,
    distanceKm: 10,
    passengers: 2,
    vehicleType: VehicleType.economy,
    promoCode: 'SAVE20',
    isPeakHour: true,
  );

  // Normal booking.
  final result = await service.bookTrip(request);

  print('Success: ${result.success}');
  print('Trip ID: ${result.tripId}');
  print('Driver ID: ${result.driverId}');
  print('Fare: ${result.fare}');
  print('Wallet: ${rider.walletBalance}');

  // Duplicate request: should not charge again.
  final repeated = await service.bookTrip(request);

  print('Repeated Trip ID: ${repeated.tripId}');
  print('Wallet after retry: ${rider.walletBalance}');

  // No-driver scenario: wallet should be refunded.
  final secondRider = Rider(
    id: 'RIDER-102',
    isVerified: true,
    isBlocked: false,
    hasActiveTrip: false,
    walletBalance: 500,
  );

  final noDriverResult = await service.bookTrip(
    BookingRequest(
      requestId: 'REQ-1002',
      rider: secondRider,
      distanceKm: 10,
      passengers: 5,
      vehicleType: VehicleType.premium,
    ),
  );

  print('No-driver result: ${noDriverResult.message}');
  print('Wallet after rejection: ${secondRider.walletBalance}');

  // Simulate a database failure.
  final thirdRider = Rider(
    id: 'RIDER-103',
    isVerified: true,
    isBlocked: false,
    hasActiveTrip: false,
    walletBalance: 500,
  );

  gateway.failNextSave = true;

  final failedSave = await service.bookTrip(
    BookingRequest(
      requestId: 'REQ-1003',
      rider: thirdRider,
      distanceKm: 10,
      passengers: 2,
      vehicleType: VehicleType.premium,
    ),
  );

  print('Save result: ${failedSave.message}');
  print('Wallet after failed save: ${thirdRider.walletBalance}');
}
