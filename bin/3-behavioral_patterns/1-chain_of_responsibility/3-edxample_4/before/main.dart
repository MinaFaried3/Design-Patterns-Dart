import 'models.dart';
import 'service.dart';

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

  final service = TripBookingService(drivers: drivers);

  final request = BookingRequest(
    requestId: 'REQ-1001',
    rider: rider,
    distanceKm: 10,
    passengers: 2,
    vehicleType: VehicleType.economy,
    promoCode: 'SAVE20',
    isPeakHour: true,
  );

  final result = await service.bookTrip(request);

  print('Success: ${result.success}');
  print('Message: ${result.message}');
  print('Trip ID: ${result.tripId}');
  print('Driver ID: ${result.driverId}');
  print('Fare: ${result.fare}');
  print('Remaining Wallet: ${rider.walletBalance}');
}
