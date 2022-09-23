import '2-sms_service.dart';

class ProxySMS {
  SMSService? _smsService;
  final Map<String, int> _sentCount = {};
  String sendSMS(String customerId, String mobile, String sms) {
    _smsService ??= SMSService();

    //first call
    if (!_sentCount.containsKey(customerId)) {
      _sentCount[customerId] = 1;
      return _smsService!.sendSMS(customerId, mobile, sms);
    } else {
      if (_sentCount[customerId]! >= 3) {
        return "Not Send it is ended";
      } else {
        _sentCount[customerId] = _sentCount[customerId]! + 1;
        return _smsService!.sendSMS(customerId, mobile, sms);
      }
    }
  }
}
