import 'dart:convert';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/purchase/model/purchase_item_model.dart';
import 'package:cbook_dt/feature/sales_return/model/sales_return_history_model.dart';
import 'package:cbook_dt/feature/sales_return/model/sales_return_store_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../utils/date_time_helper.dart';
 

class SalesReturnController extends ChangeNotifier {
  TextEditingController billNoController = TextEditingController();

  String? seletedItemName;
  String text = "Cash";

  List<String> category = ["Category1", "Category2", "Category3"];

  List<String> warehouse = ["Warehouse1", "Warehouse2", "Warehouse3"];

  List<String> subCategory = [
    "Sub Category1",
    "Sub Category2",
    "Sub Category3"
  ];

  String customerName = "";
  String phone = "";
  String email = "";
  String address = "";

  void updateCash() {
    isCash = !isCash;
    //isReceived = isCash; // Automatically check when cash is selected, uncheck when credit is selected
    discountController.clear();
    itemsCash.clear();
    itemsCredit.clear();
    notifyListeners();
  }

  String? selectedUnit;

  List<String> itemName = ["Item1", "Item2", "Item3"];
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedWarehouse;

  List<SalesReturnStoreModel> saleItemReturn = [];
  List<ItemModel> itemsCashReuturn = [];
  List<ItemModel> itemsCreditReturn = [];

  List<ItemModel> itemsCashSales = [];
  List<ItemModel> itemsCreditSales = [];

  List<TextEditingController> reductionQtyList = [];

  List<SalesReturnStoreModel> saleReturnItemModel = [];
  List<ItemModel> demoPurchaseReturnModelList = [];

  List<ItemModel> itemsCash = [];
  List<ItemModel> itemsCredit = [];

  bool isOnlineMoneyChecked = false;
  String? selectedReceiptType;

  TextEditingController controller = TextEditingController(text: "Cash");
  TextEditingController returnAmountController = TextEditingController();

  TextEditingController saleReturnNoteController = TextEditingController();


  TextEditingController amountController = TextEditingController();
  TextEditingController roundController = TextEditingController();
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

  TextEditingController discountController = TextEditingController();

  bool isCash = true;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);
  String get formattedTime => DateTimeHelper.formatTimeOfDay(_selectedTime);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  void saveSaleReturn({
    required String itemId,
    required String qty,
    required int index,
    required String price,
    required String purchaseDetailsId,
    required String itemName,
    required String unitName,
  }) {
    saleReturnItemModel.add(SalesReturnStoreModel(
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

  saveSaleReturnData() async {
    itemsCashReuturn = demoPurchaseReturnModelList;
    notifyListeners();
    return true;
  }

  saveSaleReturnCreaditData() async {
    itemsCreditReturn = demoPurchaseReturnModelList;
    notifyListeners();
    return true;
  }

  Future<String> storeSalesReturen({
    required String amount,
    required String customerId,
    required String saleType,
    required String discount,
    required String total,
    required String billNo,
  }) async {
    try {
      debugPrint(billNo);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getInt('user_id')?.toString();

      DateTime _selectedDate = DateTime.now();

      final billNumber = billNoController.value.text;
      final discountValue = discount.isNotEmpty ? discount : "0";
      final isCash = saleType.toLowerCase() == "cash";
      final paymentAmount = isCash ? totalAmount() : totalAmount2();

      final url =
          "https://commercebook.site/api/v1/sales/return/store?user_id=$userId"
          "&customer_id=17"
          "&bill_number=$billNumber"
          "&sale_date=$_selectedDate"
          "&details_notes=notes"
          "&gross_total=$total"
          "&discount=$discountValue"
          "&payment_out=${isCash ? 1 : 0}"
          "&payment_amount=$paymentAmount";

      debugPrint("URL: $url");

      // Print all sales items
      debugPrint("Sales Items:");

      // Prepare JSON body
      final requestBody = jsonEncode({
        "sales_items": List<Map<String, dynamic>>.from(
          saleReturnItemModel.map((e) => e.toJson()),
        ),
      });

      debugPrint("Request Body: $requestBody");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: requestBody,
      );

      debugPrint("Response: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData["success"] == true) {
          return responseData["message"];
        } else {
          return responseData["message"];
        }

        //Controller Sale Return clear.

        // saleReturnItemModel.clear();
      } else {
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      debugPrint("Exception in storeSalesReturn: $e");
      return "Something went wrong: $e";
    }
  }

   

  void addReductionQtyController(
      {required List<SalesReturnHistoryModel> data}) {
    data.forEach((e) {
      reductionQtyList.add(TextEditingController());
    });
    notifyListeners();
  }

  List<ItemModel> demoSalesReturnModelList = [];

  getAllQty() {
    int value = 0;
    reductionQtyList.forEach((e) {
      if (e.value.text != "" && e.value.text.isNotEmpty) {
        value = value + int.parse(e.value.text);
      }
    });
    return value;
  }

  getTotalPrice(List<SalesReturnHistoryModel> data) {
    double value = 0;
    for (int i = 0; i < reductionQtyList.length; i++) {
      if (reductionQtyList[i].value.text != "" &&
          reductionQtyList[i].value.text.isNotEmpty) {
        value = value + double.parse(data[i].unitPrice.toString());
      }
    }
    return value;
  }

  //start of form setting

  //cash portion
  bool isReturnAmount = true;
  bool isAdditionalCost = true;
  bool isTotalReturnAmount = true;
  bool isSalesAmount = true;
  bool isDiscount = true;
  bool isAdditionalCost2 = true;
  bool isMergeAmount = true;

  bool isDisocunt = true;

  bool isDiscountCredit = true;

  bool isSubTotalCredit = true;

  void updateIsSubTotalCredit() {
    isSubTotalCredit = !isSubTotalCredit;
    notifyListeners();
  }

  void updateIsDiscountCredit() {
    isDiscountCredit = !isDiscountCredit;
    notifyListeners();
  }

  void updateIsDiscount() {
    isDisocunt = !isDisocunt;
    notifyListeners();
  }

  String selectedUnitIdWithName = "";

  void selectedUnitIdWithNameFunction(String data) {
    selectedUnitIdWithName = data;
    notifyListeners();
  }

  String selcetedItemId = "";

  void updateIsReturnAmount() {
    isReturnAmount = !isReturnAmount;
    notifyListeners();
  }

  void updateIsAdditionalCost() {
    isAdditionalCost = !isAdditionalCost;
    notifyListeners();
  }

  void updateTotalReturnAmount() {
    isTotalReturnAmount = !isTotalReturnAmount;
    notifyListeners();
  }

  void updateIsSalesAmount() {
    isSalesAmount = !isSalesAmount;
    notifyListeners();
  }

  void updateDiscount() {
    isDiscount = !isDiscount;
    notifyListeners();
  }

  void updateIsAdditionalCost2() {
    isAdditionalCost2 = !isAdditionalCost2;
    notifyListeners();
  }

  void updateIsMergeAmount() {
    isMergeAmount = !isMergeAmount;
    notifyListeners();
  }

  //credit portion
  bool isAmount = true;
  bool isAdditionalCostCredit = true;
  bool isTotalAmount = true;
  bool isPaymentType = true;
  bool isPaymentAmount = true;
  bool isDue = true;

  bool isAmountCredit = true;

  void updateIsAmountCredit() {
    debugPrint("asdfsd amount");
    isAmountCredit = !isAmountCredit;
    notifyListeners();
  }

  void updateIsAmount() {
    isAmount = !isAmount;
    notifyListeners();
  }

  void updateIsAdditionalCostCredit() {
    isAdditionalCostCredit = !isAdditionalCostCredit;
    notifyListeners();
  }

  void updateIsTotalAmount() {
    isTotalAmount = !isTotalAmount;
    notifyListeners();
  }

  void updateIsPaymentType() {
    isPaymentType = !isPaymentType;
    notifyListeners();
  }

  void updateIsPaymentAmount() {
    isPaymentAmount = !isPaymentAmount;
    notifyListeners();
  }

  void updateIsDue() {
    isDue = !isDue;
    notifyListeners();
  }

  //end form setting
  //end form setting

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

  Future<void> pickTime(BuildContext context) async {
    final pickedTime = await DateTimeHelper.pickTime(context, _selectedTime);
    if (pickedTime != null && pickedTime != _selectedTime) {
      _selectedTime = pickedTime;
      notifyListeners();
    }
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

      //notifyListeners();

      debugPrint("Cash Gross Total Calculated: $subtotal"); // Debugging
      return subtotal.toStringAsFixed(2);
    }
    return "0.00";
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

      //notifyListeners();
      debugPrint("credit subtotal $subtotal");
      return subtotal.toStringAsFixed(2); // Format to 2 decimal places
    }
    return "0.00";
  }

  String totalAmount2() {
    double subtotal = double.tryParse(addAmount()) ?? 0.0; // Get subtotal

    debugPrint(subtotal.toString());

    double discount =
        double.tryParse(discountController.text) ?? 0.0; // Get discount
    double total = subtotal - discount; // Calculate

    //notifyListeners();

    debugPrint(
        "credit Subtotal: $subtotal, credit Discount: $discount, credit Total: $total"); //

    debugPrint("credit total $total");

    return total.toStringAsFixed(2);
    // Format to 2 decimal places
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

  ////===>Add cash Item
  addCashItem() {
    debugPrint(" item cash return ==== ${itemsCashReuturn.length}");
    debugPrint(" item cash return ==== ${itemsCreditReturn.length}");

    debugPrint(
        "Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCashReuturn.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
    ));

    saleItemReturn.add(SalesReturnStoreModel(
        itemId: selcetedItemId,
        price: mrpController.value.text,
        qty: qtyController.value.text,
        subTotal: (double.parse(mrpController.value.text) *
                double.parse(qtyController.value.text))
            .toString(),
        unitId: selectedUnitIdWithName,
        purchaseDetailsId: ''));

    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

    notifyListeners();
  }

  ///===>Add Credit Item
  addCreditItem() {
    debugPrint(
        "Add Item Clicked $selectedCategory $selectedSubCategory $seletedItemName ${codeController.text} ${mrpController.text} ${qtyController.text} ${amountController.text}");

    itemsCreditReturn.add(ItemModel(
      category: selectedCategory ?? "Category1",
      subCategory: selectedSubCategory ?? "Sub Category1",
      itemName: seletedItemName ?? "Item1",
      itemCode: codeController.text,
      mrp: mrpController.text,
      quantity: qtyController.text,
      total: amountController.text,
    ));

    saleItemReturn.add(SalesReturnStoreModel(
        itemId: selcetedItemId,
        price: mrpController.value.text,
        qty: qtyController.value.text,
        subTotal: (double.parse(mrpController.value.text) *
                double.parse(qtyController.value.text))
            .toString(),
        unitId: selectedUnitIdWithName,
        purchaseDetailsId: ''));

    codeController.clear();
    mrpController.clear();
    qtyController.clear();
    amountController.clear();
    unitController.clear();
    priceController.clear();

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
    itemsCashReuturn.removeAt(index);
    notifyListeners();
  }

  void removeCreditItem(int index) {
    itemsCreditReturn.removeAt(index);
    notifyListeners();
  }

  void updatedOnlineMoney() {
    isOnlineMoneyChecked = !isOnlineMoneyChecked;
    notifyListeners();
  }

  void updateReceiptType(String? newValue) {
    selectedReceiptType = newValue!;
    notifyListeners();
  }
}
