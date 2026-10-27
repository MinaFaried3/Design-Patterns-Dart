// AFTER: Adapters normalize different vendor calls, payloads, and failures.
// These SDKs simulate payments entirely in memory.

// 1. TARGET AND APPLICATION RESULT
class PaymentResult {
  final bool accepted;
  final String? reference;
  const PaymentResult.accepted(String this.reference) : accepted = true;
  const PaymentResult.declined() : accepted = false, reference = null;
}

abstract class PaymentGateway {
  Future<PaymentResult> charge(int cents);
}

// 2. INCOMPATIBLE VENDOR APIS
class LegacyPaymentSdk {
  Map<String, Object> makePayment(int minorUnits) => minorUnits <= 5000
      ? {'code': 0, 'reference': 'LEGACY-1'}
      : {'code': 12, 'reference': ''};
}

class VendorDecline implements Exception {}

class ModernPaymentSdk {
  Future<String> debit({required int amountInCents}) async {
    if (amountInCents > 5000) throw VendorDecline();
    return 'MODERN-1';
  }
}

// 3. ADAPTERS
class LegacyPaymentAdapter implements PaymentGateway {
  final LegacyPaymentSdk sdk;
  LegacyPaymentAdapter(this.sdk);

  @override
  Future<PaymentResult> charge(int cents) async {
    if (cents <= 0) throw ArgumentError.value(cents, 'cents');
    final response = sdk.makePayment(cents);
    if (response['code'] == 12) return const PaymentResult.declined();
    if (response['code'] != 0) throw StateError('Unexpected legacy error');
    return PaymentResult.accepted(response['reference'] as String);
  }
}

class ModernPaymentAdapter implements PaymentGateway {
  final ModernPaymentSdk sdk;
  ModernPaymentAdapter(this.sdk);

  @override
  Future<PaymentResult> charge(int cents) async {
    if (cents <= 0) throw ArgumentError.value(cents, 'cents');
    try {
      return PaymentResult.accepted(await sdk.debit(amountInCents: cents));
    } on VendorDecline {
      return const PaymentResult.declined();
    }
  }
}

// 4. CLIENT: One workflow works with either vendor.
class Checkout {
  final PaymentGateway gateway;
  Checkout(this.gateway);

  Future<String> pay(int cents) async {
    final result = await gateway.charge(cents);
    return result.accepted ? 'Paid: ${result.reference}' : 'Declined';
  }
}

Future<void> main() async {
  for (final gateway in <PaymentGateway>[
    LegacyPaymentAdapter(LegacyPaymentSdk()),
    ModernPaymentAdapter(ModernPaymentSdk()),
  ]) {
    final checkout = Checkout(gateway);
    print(await checkout.pay(2500));
    final declined = await checkout.pay(6000);
    assert(declined == 'Declined');
    print(declined);
  }
}
