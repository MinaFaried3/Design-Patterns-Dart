import '1-bank_interface.dart';

class BankA extends BankInterface {
  @override
  String withdraw() {
    return "Your request is handling by BankA";
  }
}
