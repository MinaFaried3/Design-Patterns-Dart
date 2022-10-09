import '4-discount_factory.dart';

void main() {
  DiscountFactory discount = DiscountFactory();

  var calculator1 = discount.getDiscount("day");
  var calculator2 = discount.getDiscount("day");
  var calculator3 = discount.getDiscount("item");
  var calculator4 = discount.getDiscount("item");

  print(calculator1.hashCode);
  print(calculator2.hashCode);
  print(calculator4.hashCode);
  print(calculator3.hashCode);

  print(discount.cache);
}
