import '1-bank_interface.dart';

abstract class BankFactoryInterface {
  BankInterface getBank(String code);
}
