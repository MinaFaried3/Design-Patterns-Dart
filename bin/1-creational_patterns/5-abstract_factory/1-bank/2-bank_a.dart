import '1-bank_interface.dart';

class BankAA extends BankInterface {
  @override
  String withdraw() {
    return "Your request is handling by BankA";
  }
}
