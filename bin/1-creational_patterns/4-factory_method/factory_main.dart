import 'dart:io';

import '1-bank_interface.dart';
import '5-bank_factory.dart';

void main() {
  BankFactory bankFactory = BankFactory();
  String code = (stdin.readLineSync()!).substring(0, 6);
  BankInterface bank1 = bankFactory.getBank(code);
  print(bank1.withdraw());
  BankInterface bank2 = bankFactory.getBank(code);
  print(bank2.withdraw());
}
