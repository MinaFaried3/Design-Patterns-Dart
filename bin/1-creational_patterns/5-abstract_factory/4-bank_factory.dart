import '1-bank/1-bank_interface.dart';
import '1-bank/2-bank_a.dart';
import '1-bank/3-bank_b.dart';
import '2-payment/1-payment_interface.dart';
import '2-payment/2-visa.dart';
import '2-payment/3-master_card.dart';
import '3-bank_factory_interface.dart';

class BankFactory extends BankFactoryInterface {
  @override
  BankInterface getBank(String code) {
    switch (code) {
      case "111111":
        return BankAA();
      case "222222":
        return BankBB();
      default:
        return BankAA();
    }
  }

  @override
  PaymentCardInterface getPaymentMethod(String code) {
    switch (code) {
      case "12":
        return Visa();
      case "34":
        return MasterCard();
      default:
        return MasterCard();
    }
  }
}
