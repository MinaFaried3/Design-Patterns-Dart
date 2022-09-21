import '1-payment_interface.dart';

class Visa extends PaymentCardInterface {
  @override
  String getName() {
    return "Visa Card";
  }

  @override
  String getProviderInfo() {
    return "Visa";
  }
}
