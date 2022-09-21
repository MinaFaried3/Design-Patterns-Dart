import '1-payment_interface.dart';

class MasterCard extends PaymentCardInterface {
  @override
  String getName() {
    return "Master Card";
  }

  @override
  String getProviderInfo() {
    return "MasterCard";
  }
}
