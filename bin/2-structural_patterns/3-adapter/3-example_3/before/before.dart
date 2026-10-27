// BEFORE: Application code translates vendor payloads and error codes.
class LegacyPaymentSdk {
  Map<String, Object> makePayment(int minorUnits) => minorUnits <= 5000
      ? {'code': 0, 'reference': 'LEGACY-1'}
      : {'code': 12, 'reference': ''};
}

class Checkout {
  final LegacyPaymentSdk sdk;
  Checkout(this.sdk);

  String pay(int cents) {
    final response = sdk.makePayment(cents);
    if (response['code'] == 12) return 'Declined';
    if (response['code'] != 0) throw StateError('Vendor error');
    return 'Paid: ${response['reference']}';
  }
}

void main() {
  final checkout = Checkout(LegacyPaymentSdk());
  print(checkout.pay(2500));
  print(checkout.pay(6000));
}
