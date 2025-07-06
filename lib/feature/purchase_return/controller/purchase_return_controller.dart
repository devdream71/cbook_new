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
  Map<int, String> selectedUnitsMap = {}; // key = index or purchaseDetailsId

  void setSelectedUnit(int index, String unit) {
    selectedUnitsMap[index] = unit;
    notifyListeners();
  }

  String? getSelectedUnit(int index) {
    return selectedUnitsMap[index];
  }

  bool isOnlineMoneyChecked = false;
  String? selectedReceiptType;

  TextEditingController controller = TextEditingController(text: "Cash");
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
  TextEditingController codeController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController discountPacentageController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  String selcetedItemId = "";

  String selectedUnitIdWithName = "";

  String? selectedUnit;

  bool isCash = true;

  String? seletedItemName;

  DateTime _selectedDate = DateTime.now();

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

  bool isCreditSale = true; // Default to credit sale, update as needed

  String text = "Cash";

  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedWarehouse;

  List<PurchaseReturnCreateItemModel> purchaseItemReturn = [];

  ///
  List<PurchaseStoreModel> purchaseReturnItemModel = [];
  List<ItemModel> demoPurchaseReturnModelList = [];

  List<TextEditingController> reductionQtyList = [];

  List<ItemModel> itemsCashReuturn = [];
  List<ItemModel> itemsCreditReturn = [];

  List<ItemModel> itemsCash = [];
  List<ItemModel> itemsCredit = [];

  void clearReductionQty() {
    for (var controller in reductionQtyList) {
      controller.clear();
    }
    notifyListeners();
  }

  void updateCash() {
    isCash = !isCash;
    //isReceived = isCash; // Automatically check when cash is selected, uncheck when credit is selected
    discountController.clear();
    itemsCash.clear();
    itemsCredit.clear();
    notifyListeners();
  }

  void setSaleType(bool isCredit) {
    isCreditSale = isCredit;
    notifyListeners(); // Notify UI to update if needed
  }

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

  void updateIsAmount() {
    isAmount = !isAmount;
    notifyListeners();
  }

  void clearTextControloler() {
    purchaseReturnNoteController.clear();
    amountController.clear();
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

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
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

  // Solution 3: Alternative - modify the addCashItem method
  addCashItem() {
    debugPrint(
        "cash Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    // Extract unit name from selectedUnitIdWithName
    String unitName = extractUnitName(selectedUnitIdWithName);

    itemsCashReuturn.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      unit: unitName, // ✅ Use extracted unit name
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
  ///add item credit.
  addCreditItem() {
    debugPrint(
        "credit Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCreditReturn.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      unit: selectedUnitIdWithName ?? "pc",
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

  // Solution 1: Extract unit name from selectedUnitIdWithName
  String extractUnitName(String selectedUnitIdWithName) {
    if (selectedUnitIdWithName.isEmpty) return "PC";

    // Split by underscore and get the unit name part
    List<String> parts = selectedUnitIdWithName.split('_');
    if (parts.length >= 2) {
      return parts[1]; // Second part is the unit name
    }
    return "PC"; // Default fallback
  }

  ///====>purchase return save.

  //Solution 2: In your PurchaseReturnController, modify the savePrucahseReturn method
  void savePrucahseReturn({
    required String itemId,
    required String qty,
    required int index,
    required String price,
    required String purchaseDetailsId,
    required String itemName,
    required String unitName, // Use this parameter directly
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
      unit:
          selectedUnitIdWithName, // ✅ Use the unitName parameter instead of selectedUnitIdWithName
    ));

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
    //notifyListeners();
  }

  int getAllQty() {
    int value = 0;
    for (final controller in reductionQtyList) {
      final qty = int.tryParse(controller.text.trim()) ?? 0;
      value += qty;
    }
    return value;
  }

  double getTotalPrice(List<PurchaseHistoryModel> data) {
    double total = 0.0;

    for (int i = 0; i < reductionQtyList.length; i++) {
      final qtyText = reductionQtyList[i].text.trim();
      double qty = double.tryParse(qtyText) ?? 0;

      double unitPrice = double.tryParse(data[i].unitPrice.toString()) ?? 0;

      total += qty * unitPrice; // ✅ Multiply qty × price and add to total
    }

    return total;
  }

  ///purchase return store.
  Future<String> storePurchaseReturn(
      {
      //required String date,
      required String amount,
      required String customerId,
      required String total,
      required String discount,
      required String billNo,
      required saleType}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      print("${billNo}");

      final discount = discountController.text;

      final url =
          "https://commercebook.site/api/v1/purchase/return/store?user_id=${prefs.getString("id")}&customer_id=${customerId.isNotEmpty ? customerId : 'cash'}&bill_number=${billNoController.value.text}&return_date=$_selectedDate&details_notes=notes&gross_total=${isCash ? addAmount2() : addAmount()}&discount=$discount&payment_out=${isCash ? 1 : 0}&payment_amount=${isCash ? totalAmount() : totalAmount2()}";

      debugPrint(url);
      final requestBody = jsonEncode({
        "purchase_items": List<Map<String, dynamic>>.from(

            ///purchase_items  //old ==> pruchase_items
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
