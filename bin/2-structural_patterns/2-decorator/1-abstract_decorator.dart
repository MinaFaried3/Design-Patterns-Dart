import '../1-proxy/1-i_sms_service.dart';

class Decorator extends ISMSService {
  ISMSService? _notificationService;

  void setService(ISMSService value) {
    _notificationService = value;
  }

  @override
  String sendSMS(String customerId, String mobile, String sms) {
    if (_notificationService != null) {
      return _notificationService!.sendSMS(customerId, mobile, sms);
    } else {
      return "NotificationService has not been initialized! ";
    }
  }
}
