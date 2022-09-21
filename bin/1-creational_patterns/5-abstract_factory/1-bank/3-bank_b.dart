import '1-bank_interface.dart';

class BankBB extends BankInterface {
  @override
  String withdraw() {
    return "Your request is handling by BankB";
  }
}
