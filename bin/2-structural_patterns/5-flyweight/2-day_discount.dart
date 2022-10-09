import '1-i_discount_calc.dart';

class DayDiscountCalc extends IDiscountCalc {
  @override
  double getDiscount(DateTime currentDate, String? itemId) {
    return 0.15;
  }
}
