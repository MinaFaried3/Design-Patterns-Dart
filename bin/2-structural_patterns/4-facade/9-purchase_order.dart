import '2-shopping_basket.dart';
import '3-inventory.dart';
import '4-inventory_order.dart';
import '5-purchase_invoice.dart';
import '6-payment_processor.dart';
import '7-sms_notification.dart';

class PurchaseOrder {
  String createOrder(ShoppingBasket basket, String customerInfo) {
    bool isAvailable = true;
    Inventory inventory = Inventory();

    //check if item exist in inventory
    for (var item in basket.getItems()) {
      if (!inventory.checkItemQuantity(item!.id!, item.quantity!)) {
        isAvailable = false;
      }
    }

    if (isAvailable) {
      StringBuffer result = StringBuffer("$customerInfo\n");
      //create inventory
      InventoryOrder inventoryOrder = InventoryOrder();
      result.write("${inventoryOrder.createOrder(basket, "123")}\n");

      //create invoice
      PurchaseInvoice purchaseInvoice = PurchaseInvoice();
      PurchaseInvoice invoice = purchaseInvoice.createInvoice(
          basket, "address: 123,id: 456,email: mino@gmail.com");
      result.write(invoice.toString());

      //payment
      PaymentProcessor payment = PaymentProcessor();
      payment.handlePayment(invoice.netTotal, "acc : 1234567");

      //send sms
      SmsNotification smsNotification = SmsNotification();
      smsNotification.sendSms('123', 'INVOICE CREATED');
      return result.toString();
    }
    return "not valid";
  }
}
