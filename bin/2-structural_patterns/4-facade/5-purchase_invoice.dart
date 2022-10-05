import '1-basket_item.dart';
import '2-shopping_basket.dart';

class PurchaseInvoice {
  double discount = 0;
  double totalAmount = 0;
  double netTotal = 0;

  PurchaseInvoice createInvoice(ShoppingBasket basket, String customerInfo) {
    var invoice = PurchaseInvoice();
    var items = basket.getItems();

    for (BasketItem? item in items) {
      invoice.totalAmount += item!.price! * item.quantity!;
    }

    if (items.length > 5) {
      invoice.discount = 20;
    }

    invoice.netTotal = invoice.totalAmount - invoice.discount;

    return invoice;
  }
}
