import '1-basket_item.dart';

class ShoppingBasket {
  List<BasketItem?> items = [];

  void addItem(BasketItem item) {
    items.add(item);
  }

  void removeOneItem(String id) {
    BasketItem item = items.firstWhere((element) => element!.id == id)!;
    if (item.quantity! > 0) {
      item.quantity = item.quantity! - 1;
    }
  }

  List<BasketItem?> getItems() => items;
}
