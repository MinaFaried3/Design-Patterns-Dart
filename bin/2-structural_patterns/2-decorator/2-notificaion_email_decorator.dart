import '1-abstract_decorator.dart';

class EmailNotificationDecorator extends Decorator {
  String sentSmsNotification(String customerId, String sms) {
    return "sms '$sms' sent to '$customerId' at ${DateTime.now().toString()}";
  }

  @override
  String sendSMS(String customerId, String mobile, String sms) {
    StringBuffer result = StringBuffer();
    result.writeln(super.sendSMS(customerId, mobile, sms));
    result.writeln(sentSmsNotification(customerId, sms));

    return result.toString();
  }
}
