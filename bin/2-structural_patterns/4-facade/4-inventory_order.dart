import 'dart:math';

import '2-shopping_basket.dart';

class InventoryOrder {
  String createOrder(ShoppingBasket basket) {
    basket.getItems();
    return "order number is ${Random().nextInt(100)}";
  }
}
