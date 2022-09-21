import 'dart:io';

import '1-bank/1-bank_interface.dart';
import '2-payment/1-payment_interface.dart';
import '4-bank_factory.dart';

void main() {
  BankFactory bankFactory = BankFactory();
  String code = (stdin.readLineSync()!).substring(0, 6);
  BankInterface bank1 = bankFactory.getBank(code);
  print(bank1.withdraw());
  String code2 = (stdin.readLineSync()!).substring(0, 2);
  PaymentCardInterface paymentCard = bankFactory.getPaymentMethod(code2);
  print(paymentCard.getName());
}
