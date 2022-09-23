import '3-proxy_sms.dart';

void main() {
  /**
   *  proxy types :
   *    1- remote proxy   (like creating object that calls a web service and hide it's implementation from the client )
   *    2- virtual proxy  (like dealing with data bases )
   *    3- protection proxy (like api get way)
   *
   * */
  ProxySMS sms = ProxySMS();
  print(sms.sendSMS("1234", "0120730018", "hi my name is mino"));
  print(sms.sendSMS("1234", "0120730018", "hi my name is mino"));
  print(sms.sendSMS("1234", "0120730018", "hi my name is mino"));
  print(sms.sendSMS("1234", "0120730018", "hi my name is mino"));
}
