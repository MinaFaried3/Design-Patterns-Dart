import '../1-proxy/1-i_sms_service.dart';
import '../1-proxy/2-sms_service.dart';
import '1-abstract_decorator.dart';
import '2-notificaion_email_decorator.dart';

void main() {
  ISMSService smsService = SMSService();
  Decorator emailNotification = EmailNotificationDecorator();
  emailNotification.setService(smsService);

  print(emailNotification.sendSMS("1234", "0120730018", "hi my name is mino"));
  print(emailNotification.sendSMS("1234", "0120730018", "hi my name is mino"));
  print(emailNotification.sendSMS("1234", "0120730018", "hi my name is mino"));
  print(emailNotification.sendSMS("1234", "0120730018", "hi my name is mino"));
}
