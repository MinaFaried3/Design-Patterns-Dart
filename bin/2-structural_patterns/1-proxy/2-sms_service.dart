import '1-i_sms_service.dart';

class SMSService extends ISMSService {
  @override
  String sendSMS(String customerId, String mobile, String sms) {
    return "sms sent to $customerId form $mobile and sms : $sms";
  }
}
