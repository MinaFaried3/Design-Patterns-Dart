import '1-i_discount_calc.dart';
import '2-day_discount.dart';
import '3-item_discount.dart';

class DiscountFactory {
  Map<String, IDiscountCalc> cache = {};

  IDiscountCalc getDiscount(String calcType) {
    late IDiscountCalc calculator;

    if (cache.containsKey(calcType)) {
      return cache[calcType]!;
    }
    switch (calcType) {
      case 'day':
        calculator = DayDiscountCalc();
        break;
      case 'item':
        calculator = ItemDiscountCalc();
        break;
    }

    cache[calcType] = calculator;
    print(calcType);

    return calculator;
  }
}
