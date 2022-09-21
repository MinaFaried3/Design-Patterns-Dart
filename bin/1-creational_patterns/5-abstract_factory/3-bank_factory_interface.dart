import '1-bank/1-bank_interface.dart';
import '2-payment/1-payment_interface.dart';

abstract class BankFactoryInterface {
  BankInterface getBank(String code);
  PaymentCardInterface getPaymentMethod(String code);
}
