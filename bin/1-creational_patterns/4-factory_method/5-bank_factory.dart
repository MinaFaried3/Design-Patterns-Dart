import '1-bank_interface.dart';
import '2-bank_a.dart';
import '3-bank_b.dart';
import '4-bank_factory_interface.dart';

class BankFactory extends BankFactoryInterface {
  @override
  BankInterface getBank(String code) {
    switch (code) {
      case "111111":
        return BankA();
      case "222222":
        return BankB();
      default:
        return BankA();
    }
  }
}
