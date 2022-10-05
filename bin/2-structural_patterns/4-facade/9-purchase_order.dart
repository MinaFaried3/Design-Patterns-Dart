import '2-shopping_basket.dart';
import '3-inventory.dart';

class PurchaseOrder {
  void createOrder(ShoppingBasket basket, String customerInfo) {
    bool isAvailable = false;
    Inventory inventory = Inventory();
    for (var item in basket.getItems()) {
      if (!inventory.checkItemQuantity(item!.id!, item.quantity!)) {
        isAvailable = false;
      }
    }
  }
}
