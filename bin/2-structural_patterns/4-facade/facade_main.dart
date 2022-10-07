import '1-basket_item.dart';
import '2-shopping_basket.dart';
import '9-purchase_order.dart';

void main() {
  ShoppingBasket basket = ShoppingBasket();

  basket.addItem(BasketItem()
    ..id = "123"
    ..quantity = 3
    ..price = 50);

  basket.addItem(BasketItem()
    ..id = "123"
    ..quantity = 3
    ..price = 50);

  PurchaseOrder order = PurchaseOrder();
  print(order.createOrder(basket, "name: mina,bank:23456,mobile:01000000 "));
}
