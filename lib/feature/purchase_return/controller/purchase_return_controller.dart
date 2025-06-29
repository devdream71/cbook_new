import 'dart:convert';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/purchase/model/purchase_item_model.dart';
import 'package:cbook_dt/feature/sales/model/return_purchase_create_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/date_time_helper.dart';
import 'package:http/http.dart' as http;
import '../model/purchase_return_item_details.dart';
import '../model/purchase_store_model.dart';

class PurchaseReturnController extends ChangeNotifier {
  String selcetedItemId = "";

  String selectedUnitIdWithName = "";

  List<PurchaseReturnCreateItemModel> purchaseItemReturn = [];
   ///
  List<PurchaseStoreModel> purchaseReturnItemModel = [];
  List<ItemModel> demoPurchaseReturnModelList = [];

  List<TextEditingController> reductionQtyList = [];
   
  

   void clearReductionQty() {
  for (var controller in reductionQtyList) {
    controller.clear();
  }
  notifyListeners();
}

  List<ItemModel> itemsCashReuturn = [];
  List<ItemModel> itemsCreditReturn = [];

  List<ItemModel> itemsCash = [];
  List<ItemModel> itemsCredit = [];

  // List<SaleItemModel> saleReturnItem = [];

  String? selectedUnit;

  bool isCash = true;

  String? seletedItemName;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String customerName = "";
  String phone = "";
  String email = "";
  String address = "";

  bool isAmount = true;
  bool isDisocunt = true;
  bool isReciptType = true;
  bool isAmountCredit = true;
  bool isDiscountCredit = true;
  bool isSubTotalCredit = true;
  bool isPreviousAmount = true;

  String text = "Cash";
  List<String> category = ["Category1", "Category2", "Category3"];
  List<String> warehouse = ["Warehouse1", "Warehouse2", "Warehouse3"];
  List<String> subCategory = [
    "Sub Category1",
    "Sub Category2",
    "Sub Category3"
  ];
  List<String> itemName = ["Item1", "Item2", "Item3"];
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedWarehouse;

  void updateCash() {
    isCash = !isCash;
    //isReceived = isCash; // Automatically check when cash is selected, uncheck when credit is selected
    discountController.clear();
    itemsCash.clear();
    itemsCredit.clear();
    notifyListeners();
  }

   
  addCreditItem() {
    debugPrint(
        "credit Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCreditReturn.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      unit: selectedUnit ?? "DC",
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
    ));

    purchaseItemReturn.add(PurchaseReturnCreateItemModel(
        itemId: selcetedItemId,
        price: mrpController.value.text,
        qty: qtyController.value.text,
        subTotal: (double.parse(mrpController.value.text) *
                double.parse(qtyController.value.text))
            .toString(),
        unitId: selectedUnitIdWithName));

    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

    notifyListeners();
  }

  bool isCreditSale = true; // Default to credit sale, update as needed

  void setSaleType(bool isCredit) {
    isCreditSale = isCredit;
    notifyListeners(); // Notify UI to update if needed
  }

  TextEditingController discountController = TextEditingController();

  void selectedUnitIdWithNameFunction(String data) {
    selectedUnitIdWithName = data;
    notifyListeners();
  }

  void updatemoney() {
    isAmount = !isAmount;
    if (isAmount) {
      // isAmount.text = totalAmount2;
    } else {
      // isAmount.clear();
    }
    notifyListeners();
  }

  ///credit ===>
  String addAmount() {
    if (itemsCreditReturn.isNotEmpty) {
      double subtotal = 0.0;
      debugPrint("dddd $subtotal");

      for (var element in itemsCreditReturn) {
        // Ensure values are not null or empty before parsing
        double price = double.tryParse(element.mrp?.toString() ?? "0") ?? 0.0;
        double quantity =
            double.tryParse(element.quantity?.toString() ?? "0") ?? 0.0;
        debugPrint("credit price == $price credit quantity $quantity");
        subtotal += price * quantity;
      }

      notifyListeners();
      debugPrint("credit subtotal $subtotal");
      return subtotal.toStringAsFixed(2); // Format to 2 decimal places
    }
    return "0.00";
  }

  ////===>cash
  String addAmount2() {
    if (itemsCashReuturn.isNotEmpty) {
      double subtotal = 0.0;
      debugPrint("Cash Items Length: ${itemsCashReuturn.length}"); // Debugging
      debugPrint("Cash Items: $itemsCashReuturn"); // Debugging

      for (var element in itemsCashReuturn) {
        double price = double.tryParse(element.mrp?.toString() ?? "0") ?? 0.0;
        double quantity =
            double.tryParse(element.quantity?.toString() ?? "0") ?? 0.0;

        debugPrint(
            "Item: ${element.itemName}, Price: $price, Quantity: $quantity"); // Debugging

        subtotal += price * quantity;
      }

      notifyListeners();

      debugPrint("Cash Gross Total Calculated: $subtotal"); // Debugging
      return subtotal.toStringAsFixed(2);
    }
    return "0.00";
  }

  //////credit discount total
  String totalAmount2() {
    double subtotal = double.tryParse(addAmount()) ?? 0.0; // Get subtotal
    debugPrint(subtotal.toString());
    double discount =
        double.tryParse(discountController.text) ?? 0.0; // Get discount
    double total = subtotal - discount; // Calculate total

   // notifyListeners();

    debugPrint(
        "credit Subtotal: $subtotal, credit Discount: $discount, credit Total: $total"); //

    debugPrint("credit total $total");

    return total.toStringAsFixed(2);
    // Format to 2 decimal places
  }

  String totalAmount() {
    double subtotal = double.tryParse(addAmount2()) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double total = subtotal - discount;

    //notifyListeners();

    debugPrint(
        "cash amount: $subtotal, cash Discount: $discount, cash Total: $total"); // Debugging

    return total.toStringAsFixed(2);
  }

  TextEditingController controller = TextEditingController(text: "Cash");

  bool isOnlineMoneyChecked = false;
  String? selectedReceiptType;

   
   TextEditingController purchaseReturnNoteController = TextEditingController();

  TextEditingController returnAmountController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController totalReturnController = TextEditingController();
  TextEditingController salesAmountController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController amountController2 = TextEditingController();
  TextEditingController additionalCostController = TextEditingController();
  TextEditingController mergeAmountController = TextEditingController();

  TextEditingController creditAmountController = TextEditingController();
  TextEditingController creditAdditionalCostController =
      TextEditingController();
  TextEditingController creditTotalAmountController = TextEditingController();
  TextEditingController paymentTypeController = TextEditingController();
  TextEditingController paymentAmountController = TextEditingController();
  TextEditingController dueController = TextEditingController();

  TextEditingController codeController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController discountPacentageController = TextEditingController();

  void updateIsAmount() {
    isAmount = !isAmount;
    notifyListeners();
  }

  void updateIsDiscount() {
    isDisocunt = !isDisocunt;
    notifyListeners();
  }

  void updateIsReciptType() {
    isReciptType = !isReciptType;
    notifyListeners();
  }

  void updateIsAmountCredit() {
    debugPrint("asdfsd amount");
    isAmountCredit = !isAmountCredit;
    notifyListeners();
  }

  void updateIsDiscountCredit() {
    isDiscountCredit = !isDiscountCredit;
    notifyListeners();
  }

  void updateIsSubTotalCredit() {
    isSubTotalCredit = !isSubTotalCredit;
    notifyListeners();
  }

  void updateIsPreviousAmount() {
    isPreviousAmount = !isPreviousAmount;
    notifyListeners();
  }

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);
  String get formattedTime => DateTimeHelper.formatTimeOfDay(_selectedTime);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final pickedTime = await DateTimeHelper.pickTime(context, _selectedTime);
    if (pickedTime != null && pickedTime != _selectedTime) {
      _selectedTime = pickedTime;
      notifyListeners();
    }
  }

  updateCashForDefaultSet() {
    isCash = true;
    notifyListeners();
  }

  updateCreditForDefaultSet() {
    isCash = false;
    notifyListeners();
  }

  updatedCustomerInfomation(
      {required String nameFrom,
      required String phoneFrom,
      required String emailFrom,
      required String addressFrom}) {
    customerName = nameFrom;
    phone = phoneFrom;
    email = emailFrom;
    address = addressFrom;

    notifyListeners();
    debugPrint("as $customerName");
  }

 

  ////===>cash
  addCashItem() {
    debugPrint(
        "cash Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCashReuturn.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      unit: selectedUnit ?? "PC",
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
    ));

    purchaseItemReturn.add(PurchaseReturnCreateItemModel(
        itemId: selcetedItemId,
        price: mrpController.value.text,
        qty: qtyController.value.text,
        subTotal: (double.parse(mrpController.value.text) *
                double.parse(qtyController.value.text))
            .toString(),
        unitId: selectedUnitIdWithName));

    notifyListeners();

    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

    notifyListeners();
  }

  //////===> credit ===>

  void itemUpdate(String item, List<ItemsModel> items) {
    seletedItemName = item;
    if (items.isNotEmpty) {
      items.forEach((e) {
        if (item == e.name.toString()) {
          selcetedItemId = e.id.toString();
        }
      });
    }
    notifyListeners();
  }
  

 

  void updateCategory(String? newValue) {
    selectedCategory = newValue!;
    notifyListeners();
  }

  void updateWarehouse(String? newValue) {
    selectedWarehouse = newValue!;
    notifyListeners();
  }

  void updateSubCategory(String? newValue) {
    selectedSubCategory = newValue!;
    notifyListeners();
  }

  void updateItemName(String? newValue) {
    seletedItemName = newValue!;
    notifyListeners();
  }

  
  void removeCashItem(int index) {
  // Safely check before removing
  if (index >= 0 && index < itemsCashReuturn.length) {
    itemsCashReuturn.removeAt(index);
  }

  if (index >= 0 && index < purchaseItemReturn.length) {
    purchaseItemReturn.removeAt(index);
  }

  notifyListeners();
}


  void removeCreditItem(int index) {
    itemsCreditReturn.removeAt(index);
    notifyListeners();
  }

  //////====>
  void updateUnitDropdown(String selectedUnit) {}
  String selcetedUnitId = "";

 
  

  TextEditingController billNoController = TextEditingController();

  void savePrucahseReturn({
    required String itemId,
    required String qty,
    required int index,
    required String price,
    required String purchaseDetailsId,
    required String itemName,
    required String unitName,
  }) {
    purchaseReturnItemModel.add(PurchaseStoreModel(
      itemId: itemId,
      qty: reductionQtyList[index].value.text,
      unitId: selectedUnitIdWithName,
      price: price,
      subTotal: (double.parse(price) * double.parse(qty)).toString(),
      purchaseDetailsId: purchaseDetailsId,
    ));
    demoPurchaseReturnModelList.add(ItemModel(
        category: "",
        subCategory: "",
        itemCode: "",
        itemName: itemName,
        mrp: price,
        quantity: reductionQtyList[index].value.text,
        total: (double.parse(price) * double.parse(qty)).toString(),
        unit: unitName));

    notifyListeners();
  }

  savePurchaseReturnData() async {
    itemsCashReuturn = demoPurchaseReturnModelList;
    notifyListeners();
    return true;
  }

  savePurchaseReturnCreaditData() async {
    itemsCreditReturn = demoPurchaseReturnModelList;
    notifyListeners();
    return true;
  }

  void addReductionQtyController({required List<PurchaseHistoryModel> data}) {
    data.forEach((e) {
      reductionQtyList.add(TextEditingController());
    });
    notifyListeners();
  }

  getAllQty() {
    int value = 0;
    reductionQtyList.forEach((e) {
      if (e.value.text != "" && e.value.text.isNotEmpty) {
        value = value + int.parse(e.value.text);
      }
    });
    return value;
  }

  getTotalPrice(List<PurchaseHistoryModel> data) {
    double value = 0;
    for (int i = 0; i < reductionQtyList.length; i++) {
      if (reductionQtyList[i].value.text != "" &&
          reductionQtyList[i].value.text.isNotEmpty) {
        value = value + double.parse(data[i].unitPrice.toString());
      }
    }
    return value;
  }

  Future<String> storePurchaseReturn(
    {
      //required String date,
      required String amount,
      required String customerId,
      required String total,
      required String discount,
      required String billNo,
      required saleType}
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {

        print("${billNo}");

      final url =
          "https://commercebook.site/api/v1/purchase/return/store?user_id=${prefs.getString("id")}&customer_id=${customerId.isNotEmpty ? customerId : 'cash'}&bill_number=${billNoController.value.text}&return_date=$_selectedDate&details_notes=notes&gross_total=${isCash ? addAmount2() : addAmount()}&discount=$discount&payment_out=${isCash ? 1 : 0}&payment_amount=${isCash ? totalAmount() : totalAmount2()}";

      debugPrint(url);
      final requestBody = jsonEncode({
        "purchase_items": List<Map<String, dynamic>>.from(      ///purchase_items  //old ==> pruchase_items
            purchaseReturnItemModel.map((e) => e.toJson()))
      });
      debugPrint(requestBody);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: requestBody, // Use the wrapped JSON
      );
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          return data["message"];
        }

        demoPurchaseReturnModelList.clear();
        purchaseReturnItemModel.clear();
        
      } else {
        return jsonDecode(response.body)['message'];
      }
      return "";
    } catch (e) {
      return e.toString();
    }
  }
}
