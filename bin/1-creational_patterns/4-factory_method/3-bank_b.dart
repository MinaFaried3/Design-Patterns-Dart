import '1-bank_interface.dart';

class BankB extends BankInterface {
  @override
  String withdraw() {
    return "Your request is handling by BankB";
  }
}
