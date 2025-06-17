import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_by_id_model.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_model.dart';
import 'package:cbook_dt/feature/sales/update_sale_item_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:cbook_dt/feature/unit/model/demo_unit_model.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaleUpdateProvider extends ChangeNotifier {
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();
  TextEditingController billNumberController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController grossTotalController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  TextEditingController saleUpdateNoteController = TextEditingController();

  bool hasCustomer = false;

  bool isLoading = false;
  int? purchaseId;
  int? itemId;
  int? customerId;
  String? selectedItem;

  String? selectedItemNameInvoice;

  Map<int, String> itemMap = {}; // Store item IDs and names
  List<String> itemNames = []; // Store only item names for dropdown
  String? selectedItemName; // Selected item name for UI

  Map<int, String> unitMap = {}; // Store unit ID → unit Name
  List<String> unitNames = []; // Store only unit names for dropdown
  String? selectedUnitName; // Selected unit name for UI

  List<dynamic> purchaseDetailsList = [];

  List<DemoUnitModel> unitResponseModel = [];

  List<SaleUpdateModel> saleUpdateList = [];

  // List<SaleUpdateModel> saleUpdateList = [];

  String selctedUnitId = "";

  selectedDropdownUnitId(String value) {
    unitResponseModel.forEach((e) {
      if (e.name == value) {
        selctedUnitId = e.id.toString();
      }
    });
    notifyListeners();
  }

  Future<void> fetchUnits() async {
    const url = "https://commercebook.site/api/v1/units";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      data["data"].forEach((key, value) {
        final item = DemoUnitModel.fromJson(value);
        unitResponseModel.add(item);
      });

      if (data['success']) {
        unitMap.clear();
        unitNames.clear();

        data['data'].forEach((key, value) {
          unitMap[value['id']] = value['name']; // Store ID → Name
          unitNames.add(value['name']); // Add name to dropdown
        });

        notifyListeners();
      }
    }
  }

  Future<void> fetchItems() async {
    const url = "https://commercebook.site/api/v1/items";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success']) {
        itemMap.clear();
        itemNames.clear();

        /// ✅ Corrected `forEach` loop
        for (var item in data['data']) {
          itemMap[item['id']] = item['name'];
          itemNames.add(item['name']); // ✅ Add names to the dropdown list
        }

        notifyListeners();
      }
    }
  }

  SalesEditResponse saleEditResponse = SalesEditResponse();

  Future<void> fetchSaleData(int id) async {
    isLoading = true;
    notifyListeners();

    await fetchItems();
    await fetchUnits();

    final url = "https://commercebook.site/api/v1/sales/edit/$id";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      saleEditResponse = SalesEditResponse.fromJson(response.body);
      saleUpdateList.clear();
      saleEditResponse.data!.salesDetails!.forEach((e) {
        saleUpdateList.add(SaleUpdateModel(
          itemId: e.itemId.toString(),
          price: e.price.toString(),
          //purchaseDetailsId: e.id.toString(),
          //purchaseQty: e.qty.toString(),
          qty: e.qty.toString(),
          subTotal: e.subTotal.toString(),
          unitId: "${e.unitId.toString()}_${getUnitName(e.unitId.toString())}",
          salesUpdateDiscountPercentace: e.discountPercentage.toString(),
          salesUpdateDiscountAmount: e.discountAmount.toString(),
          salesUpdateVATTAXAmount: e.taxAmount.toString(),
          salesUpdateVATTAXPercentance: e.taxPercent.toString(),
        ));
      });

      print(saleUpdateList.length);

      // print(purchaseUpdateList.length);
      debugPrint(saleUpdateList.length.toString());

      if (data['success']) {
        final purchaseData = saleEditResponse.data!;

        purchaseDetailsList = purchaseData.salesDetails ?? [];
        billNumberController.text = purchaseData.billNumber ?? "";
        purchaseDateController.text = purchaseData.salesDate ?? "";
        grossTotalController.text = purchaseData.grossTotal?.toString() ?? "";

        customerController.text = purchaseData.customerId?.toString() ?? "";

        hasCustomer =
            purchaseData.customerId != null && purchaseData.customerId != 0;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void updateSelectedItem(String name) {
    try {
      itemId = itemMap.entries.firstWhere((entry) => entry.value == name).key;
    } catch (e) {
      // Handle the case where no match is found
      itemId = null;
      selectedItemName = null; // Optional: Reset selected item if not found
    }
    selectedItemName = name;
    notifyListeners();
  }

  void updateSelectedUnit(String name) {
    try {
      int unitId =
          unitMap.entries.firstWhere((entry) => entry.value == name).key;
      unitController.text = unitId.toString();
    } catch (e) {
      // Handle the case where no match is found
      unitController.clear();
      selectedUnitName = null; // Optional: Reset selected unit if not found
    }
    selectedUnitName = name;
    notifyListeners();
  }

  String getSubTotal() {
    double subTotal = 0.00;
    // saleUpdateList.forEach((e) {
    //   subTotal = subTotal + double.parse(e.subTotal);
    // });
    for (var e in saleUpdateList) {
      subTotal += double.tryParse(e.subTotal) ?? 0.0;
    }
    return subTotal.toString();
  }

  //List<PurchaseUpdateModel> purchaseUpdateList = [];

  addCashItemSaleUpdate(
      //String unitId,
      String selectedItemId,
      String price,
      String selectedUnitIdWithName,
      String qty,
      String discountAmount,
      String discountpercentace,
      String taxAmount,
      String taxPercentace) {
    saleUpdateList.add(SaleUpdateModel(
        itemId: selectedItemId,
        price: price,
        qty: qty,
        subTotal: (double.parse(price) * double.parse(qty)).toString(),
        unitId: selectedUnitIdWithName ?? 'pc',
        salesUpdateDiscountPercentace: discountpercentace,
        salesUpdateDiscountAmount: discountAmount,
        salesUpdateVATTAXAmount: taxAmount,
        salesUpdateVATTAXPercentance: taxPercentace));

    notifyListeners();
  }

  void updateSaleDetail(int index) {
    // Convert input values to double (assuming qty and price are double)
    int? updatedPrice = int.tryParse(priceController.text);
    int? updatedQty = int.tryParse(qtyController.text);

    // Ensure values are not null before updating
    if (updatedPrice != null && updatedQty != null) {
      saleUpdateList[index].qty = updatedQty.toString();
      saleUpdateList[index].price = updatedPrice.toString();
      saleUpdateList[index].subTotal = (updatedQty * updatedPrice).toString();

      saleUpdateList[index].unitId =
          "${saleEditResponse.data!.salesDetails![index].unitId.toString()}_${getUnitName(saleEditResponse.data!.salesDetails![index].unitId.toString())}";

      // Updating response model
      saleEditResponse.data!.salesDetails![index].price = updatedPrice;
      saleEditResponse.data!.salesDetails![index].qty = updatedQty;
      saleEditResponse.data!.salesDetails![index].subTotal =
          (updatedQty * updatedPrice);

      // Notify UI of changes
      notifyListeners();
    } else {
      print(
          "Invalid input: Please enter valid numbers for price and quantity.");
    }
  }

  String? getUnitName(String id) {
    for (var e in unitResponseModel) {
      if (e.id.toString() == id) {
        return e.name.toString();
      }
    }
    return null;
  }

  Future<void> updateSale(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final url =
          "http://commercebook.site/api/v1/sales/update?id=${saleEditResponse.data!.salesDetails![0].purchaseId}&user_id=${prefs.getInt("user_id")}&customer_id=${saleEditResponse.data!.customerId}&bill_number=${saleEditResponse.data!.billNumber}&sale_date=${saleEditResponse.data!.salesDate}&details_notes=notes&gross_total=${getSubTotal()}&payment_out=1&payment_amount=0&discount_percent=&discount=&tax_percents=3_12.0&tax=41.5";

      print("API URL: $url");

      final requestBody = {"sales_items": saleUpdateList};

      //String demo = '[{item_id: 49, qty: 2, unit_id: 24_Pces_1, price: 180, sub_total: 391.00, discount_percentage: 5.56, discount_amount: 20, tax_percent: 2_15.0, tax_amount: 51.0}]';

      ///=== demo working.

      // final salesItems = [
      //   {
      //     "item_id": 49,
      //     "qty": 2,
      //     "unit_id": "24_Pces_1",
      //     "price": 180,
      //     "sub_total": 391.00,
      //     "discount_percentage": 5.56,
      //     "discount_amount": 20,
      //     "tax_percent": "2_15.0",
      //     "tax_amount": 51.0
      //   }
      // ];

      //final requestBody = {"sales_items": salesItems};

      if (requestBody.isEmpty) return;

      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("API Response: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data["success"] == true) {
          print("Sale successful: ${data["data"]}");

          // Navigate to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sale Update successful!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Handle API returning success: false (e.g., Stock not found)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "An error occurred."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle API returning an error status code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Failed to process sale. Please try again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or JSON decoding errors
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void addItem({
    required int id,
    required int price,
    required int qty,
    required int subTotal,
    required int unitId,
    required dynamic discountPercentage,
    required dynamic discountAmount,
    required dynamic taxPercent,
    required dynamic taxAmount,
  }) {
    saleEditResponse.data!.salesDetails!.add(SaleDetail(
      itemId: id,
      price: price,
      qty: qty,
      subTotal: subTotal,
      unitId: unitId,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      taxPercent: taxPercent,
      taxAmount: taxAmount,
    ));

    saleUpdateList.add((SaleUpdateModel(
        //purchaseDetailsId: "0",
        itemId: id.toString(),
        qty: qty.toString(),
        //purchaseQty: "0",
        unitId: "${unitId.toString()}_${getUnitName(unitId.toString())}",
        price: price.toString(),
        subTotal: subTotal.toString(),
        salesUpdateDiscountPercentace: null,
        salesUpdateDiscountAmount: null,
        salesUpdateVATTAXAmount: null,
        salesUpdateVATTAXPercentance: null)));

    notifyListeners();
  }

  void saveData(
      {required String qty,
      required String price,
      required String subtotal,
      required String itemId,
      required String unitId}) {
    qtyController = TextEditingController(text: qty);
    priceController = TextEditingController(text: price);
    subTotalController = TextEditingController(text: subtotal);
    selectedItemName = itemId;
    selectedUnitName = unitId;
    notifyListeners();
  }

  TextEditingController discountAmount = TextEditingController();
  TextEditingController discountPercentance = TextEditingController();
  String lastChanged = '';
  double _subtotal = 0.0;
  double get subtotal => _subtotal;

  void calculateSubtotal() {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double total = qty * price;

    double discountPercent = double.tryParse(discountPercentance.text) ?? 0;
    double discountAmt = double.tryParse(discountAmount.text) ?? 0;
    double subtotal = double.parse(subTotalController.text.toString());

    if (lastChanged == 'percent') {
      discountAmt = (total * discountPercent) / 100;
      discountAmount.text = discountAmt.toStringAsFixed(2);
      subTotalController.text = (subtotal + taxAmount - discountAmt).toString();
    } else if (lastChanged == 'amount') {
      if (total > 0) {
        discountPercent = (discountAmt / total) * 100;
        discountPercentance.text = discountPercent.toStringAsFixed(2);
        subTotalController.text =
            (subtotal + taxAmount - discountAmt).toString();
      } else {
        discountPercentance.text = '0';
      }
    }

    _subtotal = total - discountAmt;
    if (_subtotal < 0) _subtotal = 0;

    debugPrint('--- calculateSubtotal called ---');
    debugPrint(
      'Qty: $qty, Price: $price, Discount %: $discountPercent, '
      'Discount Amount: $discountAmt, Subtotal: $_subtotal',
    );

    notifyListeners(); // No tax calculation here
  }

  void calculateTax() {
    _taxAmount = (_subtotal * _taxPercent) / 100;
    subTotalController.text =
        (_subtotal - double.parse(discountAmount.text.toString()) + _taxAmount)
            .toString();
    notifyListeners();
  }

  updateTaxPaecentId(String value) {
    taxPercentValue = value;
    notifyListeners();
  }

  double? selectedTaxPercent;
  String taxPercentValue = "";
  String totaltaxPercentValue = "";

  updateTotalTaxId(String value) {
    totaltaxPercentValue = value;
    notifyListeners();
  }

  double _taxAmount = 0.0;
  double get taxPercent => _taxPercent;
  double get taxAmount => _taxAmount;
  double _taxPercent = 0.0;
  set taxPercent(double value) {
    _taxPercent = value;
    calculateTax(); // 🔁 only recalculate tax when percent changes
    notifyListeners();
  }
}

///====>Purchase update Screen
class salesUpdateScreen extends StatefulWidget {
  final int salesId;

  const salesUpdateScreen({Key? key, required this.salesId}) : super(key: key);

  @override
  State<salesUpdateScreen> createState() => _salesUpdateScreenState();
}

class _salesUpdateScreenState extends State<salesUpdateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemCategoryProvider>(context, listen: false)
          .fetchCategories();
      Provider.of<AddItemProvider>(context, listen: false).fetchItems();
    });
  }

  String? selectedTaxName;
  String? selectedTaxId;

  String? selectedCustomer;
  String? selectedCustomerId;
  Customer? selectedCustomerObject;

  bool showNoteField = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    final colorScheme = Theme.of(context).colorScheme;

    print("purchase id");

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: true);

    return ChangeNotifierProvider(
      create: (_) => SaleUpdateProvider()..fetchSaleData(widget.salesId),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: colorScheme.primary,
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            title: const Text(
              "Update Sale",
              style: TextStyle(color: Colors.yellow, fontSize: 16),
            )),
        body: SingleChildScrollView(
          child: Consumer<SaleUpdateProvider>(
            builder: (context, provider, child) {
              print("======================");
              // print(provider.qtyController);
              return provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: InkWell(
                              onTap: () {
                                controller.updateCash(context);
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        provider.hasCustomer
                                            ? "Credit"
                                            : "Cash",
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 1),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AddSalesFormfield(
                                          label: "Bill Number",
                                          controller:
                                              provider.billNumberController),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (pickedDate != null) {
                                            String formattedDate =
                                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                            provider.purchaseDateController
                                                .text = formattedDate;
                                          }
                                        },
                                        child: AbsorbPointer(
                                          child: AddSalesFormfield(
                                            label: "Purchase Date",
                                            controller:
                                                provider.purchaseDateController,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                provider.hasCustomer
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: AddSalesFormfield(
                                                label: "Customer ID",
                                                controller: provider
                                                    .customerController),
                                          ),
                                          const Expanded(child: SizedBox()),
                                        ],
                                      )
                                    : const Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Cash",
                                          style: TextStyle(color: Colors.black),
                                        )),

                                const SizedBox(
                                  height: 3,
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                ///===>item list

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  // itemCount: provider.saleEditResponse.data!.salesDetails!.length,
                                  itemCount: provider.saleUpdateList.length,

                                  itemBuilder: (context, index) {
                                    // final detail = provider.saleEditResponse.data!.salesDetails![index];
                                    final detail =
                                        provider.saleUpdateList![index];

                                    return GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateSaleItemView(
                                              index: index,
                                              itemDetail: detail,
                                              provider: provider,
                                              // itemDetail: detail,
                                              itemMap: provider.itemMap,
                                              unitMap: provider.unitMap,
                                            ),
                                          ),
                                        );
                                        if (context.mounted) {
                                          provider.notifyListeners();
                                        }
                                        provider.notifyListeners();
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Item ${index + 1}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                "Item: ${provider.itemMap[int.tryParse(detail.itemId) ?? 0] ?? "Unknown"}  (${provider.unitMap[int.tryParse(detail.unitId.split("_")[0]) ?? 0] ?? "Unknown"})",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Qty: ${detail.qty}",
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Price: ৳ ${detail.price}",
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "Subtotal: ৳ ${detail.subTotal}",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "Discount: ${detail.salesUpdateDiscountAmount}৳ , ${detail.salesUpdateDiscountPercentace} %  ",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                "Tax: ${detail.salesUpdateVATTAXAmount}৳, ${detail.salesUpdateVATTAXPercentance} %",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                controller.isCash
                                    ? controller.itemsCash.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              showSalesDialog(context,
                                                  controller, provider);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Products",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        showSalesDialog(
                                                          //context, controller, provider,

                                                          context,
                                                          controller,
                                                          provider,
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                    : controller.itemsCredit.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              showSalesDialog(context,
                                                  controller, provider);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Products",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        showSalesDialog(
                                                            context,
                                                            controller,
                                                            provider);
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),

                                const SizedBox(
                                  height: 5,
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.note_add_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showNoteField = !showNoteField;
                                        });
                                      },
                                    ),
                                    if (showNoteField)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          child: Container(
                                            height: 40,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  top: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  bottom: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  left: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  right: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            child: Center(
                                              child: TextField(
                                                controller: controller
                                                    .saleUpdateNoteController,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                                onChanged: (value) {
                                                  controller
                                                      .saleUpdateNoteController
                                                      .text = value;
                                                },
                                                maxLines: 2,
                                                cursorHeight: 12,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  hintText: "Note",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey.shade400,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                //===>subtotal
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    //color: Colors.red,
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Subtotal",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: AddSalesFormfield(
                                            //label: "Discount (%)",
                                            controller: TextEditingController(
                                                text: provider.getSubTotal()),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              controller.lastChanged =
                                                  'percent';
                                              controller.calculateSubtotal();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                ///====>Discount
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0.0),
                                                child: SizedBox(
                                                  width: 120,
                                                  child: AddSalesFormfield(
                                                    label: "Discount (AMT)",
                                                    controller: controller
                                                        .discountAmount,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      controller
                                                          .updateDiscountAmountUpdate2(
                                                              value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: SizedBox(
                                                  width: 120,
                                                  child: AddSalesFormfield(
                                                    label: "Discount (%)",
                                                    controller: controller
                                                        .discountPercentance,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      controller
                                                          .updateDiscountPercent(
                                                              value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),
                                ////Vat, Tax
                                // ✅ VAT/TAX Dropdown Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Dropdown
                                    Consumer<TaxProvider>(
                                      builder: (context, taxProvider, child) {
                                        if (taxProvider.isLoading) {
                                          return const Center(
                                              child: SizedBox());
                                        }

                                        if (taxProvider.taxList.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              'No tax options available.',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          );
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 17.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "VAT/TAX (%)",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                              CustomDropdownTwo(
                                                hint: 'Select VAT/TAX',
                                                items: taxProvider.taxList
                                                    .map((tax) =>
                                                        "${tax.name} - (${tax.percent})")
                                                    .toList(),
                                                width: 120,
                                                height: 30,
                                                selectedItem: selectedTaxName,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedTaxName = newValue;

                                                    final nameOnly = newValue
                                                        ?.split(" - ")
                                                        .first;

                                                    final selected = taxProvider
                                                        .taxList
                                                        .firstWhere(
                                                      (tax) =>
                                                          tax.name == nameOnly,
                                                      orElse: () => taxProvider
                                                          .taxList.first,
                                                    );

                                                    selectedTaxId =
                                                        selected.id.toString();

                                                    controller
                                                            .selectedTaxPercent =
                                                        double.tryParse(
                                                            selected.percent);

                                                    // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                                    controller
                                                        .taxPercent = controller
                                                            .selectedTaxPercent ??
                                                        0.0;

                                                    controller.updateTaxPaecentId(
                                                        '${selectedTaxId}_${controller.selectedTaxPercent}');

                                                    print(
                                                        'tax_percent: "${controller.taxPercentValue}"');

                                                    //controller.calculateSubtotal();

                                                    debugPrint(
                                                        "Selected Tax ID: $selectedTaxId");
                                                    debugPrint(
                                                        "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 4),

                                    SizedBox(
                                      width: 120,
                                      child: AddSalesFormfield(
                                        label: "TAX AMT",
                                        controller: TextEditingController(
                                          text: controller.taxAmount
                                              .toStringAsFixed(
                                                  2), // 👈 show calculated tax
                                        ),
                                        keyboardType: TextInputType.number,
                                        //readOnly: true, // 👈 prevent manual editing
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                //===>Gross Total
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    //color: Colors.red,
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Gross Total",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: AddSalesFormfield(
                                            //label: "Discount (%)",
                                            controller: TextEditingController(
                                                text: provider.getSubTotal()),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              controller.lastChanged =
                                                  'percent';
                                              controller.calculateSubtotal();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                //cash Received
                                controller.isReciptType && controller.isCash
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                  height: 25,
                                                  child: Checkbox(
                                                    value:
                                                        controller.isReceived,
                                                    onChanged: (bool? value) {
                                                      if (controller.isCash) {
                                                        // Allow checking, but prevent unchecking
                                                        if (value == true) {
                                                          controller
                                                                  .isReceived =
                                                              true;
                                                          controller
                                                              .notifyListeners();
                                                        }
                                                      } else {
                                                        // Allow normal toggling when not cash
                                                        controller.isReceived =
                                                            value ?? false;
                                                        controller
                                                            .notifyListeners();
                                                      }
                                                    },
                                                  )),
                                              const Text("",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Received",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 30,
                                                width: 120,
                                                child: AddSalesFormfield(
                                                  readOnly: true,
                                                  onChanged: (value) {
                                                    Provider.of(context)<
                                                        SalesController>();
                                                  },
                                                  controller:
                                                      TextEditingController(
                                                          text: provider
                                                              .getSubTotal()),
                                                  // style: const TextStyle(
                                                  //     fontSize: 18,
                                                  //     color: Colors.black),
                                                  decoration: InputDecoration(
                                                    // filled: true,
                                                    fillColor: Colors.white,
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      vertical: 12,
                                                      horizontal: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              onPressed: () async {
                                await provider.updateSale(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Update Sale",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  void showSalesDialog(BuildContext context, SalesController controller,
      SaleUpdateProvider updateProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);

    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    // Define local state variables
    String? selectedCategoryId;
    String? selectedSubCategoryId;

    String? selectedTaxName;
    String? selectedTaxId;

    //String? selectedItemNameInvoice;

    List<String> unitIdsList = [];

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // ✅ Use StatefulBuilder to update UI
          return Dialog(
              backgroundColor: Colors.grey.shade400,
              child: Container(
                height: 550,
                decoration: BoxDecoration(
                  color: const Color(0xffe7edf4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      color: Colors.yellow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width:
                                  30), // Placeholder for left spacing (can be removed or adjusted)

                          // Centered text and icon
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_box,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Add Item",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          // Cancel icon on the right
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.cancel,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 6.0, right: 6.0, top: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: InkWell(
                          //     onTap: () {
                          //       Navigator.pop(context);
                          //     },
                          //     child: const Icon(
                          //       Icons.cancel,
                          //       size: 15,
                          //       color: Colors.red,
                          //     ),
                          //   ),
                          // ),

                          // Category and Subcategory Row

                          const SizedBox(
                            height: 8,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ///// Category Dropdown

                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Category",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    width: 150,
                                    child: categoryProvider.isLoading
                                        ? const CircularProgressIndicator()
                                        : CustomDropdownTwo(
                                            hint: '', //Select Category
                                            items: categoryProvider.categories
                                                .map(
                                                    (category) => category.name)
                                                .toList(),
                                            width: 150, // Adjust as needed
                                            height: 30, // Adjust as needed
                                            // Set the initial value
                                            onChanged: (value) async {
                                              final selectedCategory =
                                                  categoryProvider.categories
                                                      .firstWhere((cat) =>
                                                          cat.name == value);

                                              setState(() {
                                                selectedCategoryId =
                                                    selectedCategory.id
                                                        .toString();
                                                selectedSubCategoryId =
                                                    null; // Reset subcategory
                                              });

                                              // Fetch subcategories & update UI when done
                                              await categoryProvider
                                                  .fetchSubCategories(
                                                      selectedCategory.id);
                                              setState(() {});
                                            },
                                            // Set the initial item (if selectedCategoryId is not null)
                                            selectedItem: selectedCategoryId !=
                                                    null
                                                ? categoryProvider.categories
                                                    .firstWhere(
                                                      (cat) =>
                                                          cat.id.toString() ==
                                                          selectedCategoryId,
                                                      orElse: () =>
                                                          categoryProvider
                                                              .categories.first,
                                                    )
                                                    .name
                                                : null,
                                          ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 10),

                              ///subcategory
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: categoryProvider.isSubCategoryLoading
                                        ? const SizedBox()
                                        : categoryProvider
                                                .subCategories.isNotEmpty
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Sub Category",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                  ),
                                                  CustomDropdownTwo(
                                                    hint: '', //Sel Sub Category
                                                    items: categoryProvider
                                                        .subCategories
                                                        .map((subCategory) =>
                                                            subCategory.name)
                                                        .toList(),
                                                    width:
                                                        150, // Adjust as needed
                                                    height:
                                                        30, // Adjust as needed
                                                    onChanged: (value) {
                                                      final selectedSubCategory =
                                                          categoryProvider
                                                              .subCategories
                                                              .firstWhere(
                                                                  (subCat) =>
                                                                      subCat
                                                                          .name ==
                                                                      value);

                                                      setState(() {
                                                        selectedSubCategoryId =
                                                            selectedSubCategory
                                                                .id
                                                                .toString();
                                                      });

                                                      debugPrint(
                                                          "Selected Sub Category ID: ${selectedSubCategory.id}");
                                                    },
                                                    // Set the initial item (if selectedSubCategoryId is not null)
                                                    selectedItem:
                                                        selectedSubCategoryId !=
                                                                null
                                                            ? categoryProvider
                                                                .subCategories
                                                                .firstWhere(
                                                                  (sub) =>
                                                                      sub.id
                                                                          .toString() ==
                                                                      selectedSubCategoryId,
                                                                  orElse: () =>
                                                                      categoryProvider
                                                                          .subCategories
                                                                          .first,
                                                                )
                                                                .name
                                                            : null,
                                                  ),
                                                ],
                                              )
                                            : const Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "", //No subcategories available
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13),
                                                ),
                                              ),
                                  ),
                                ],
                              )

                              /// Subcategory Dropdown
                            ],
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(
                            "Item",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),

                          ///item
                          SizedBox(
                            height: 30,
                            child: Consumer<AddItemProvider>(
                              builder: (context, itemProvider, child) {
                                if (itemProvider.isLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (itemProvider.items.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No items available.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }

                                return CustomDropdownTwo(
                                  hint: '', //Choose an item
                                  items: itemProvider.items
                                      .map((item) => item.name)
                                      .toList(),
                                  width: double.infinity,
                                  height: 30,
                                  selectedItem: controller
                                      .seletedItemName, // Ensure this is correctly initialized
                                  onChanged: (selectedItemName) async {
                                    setState(() {
                                      controller.seletedItemName =
                                          selectedItemName; // Update controller's selectedItemName
                                      itemProvider.items.forEach((e) {
                                        if (selectedItemName == e.name) {
                                          controller.selcetedItemId =
                                              e.id.toString();
                                        }
                                      });

                                      if (controller.selcetedItemId != null) {
                                        fetchStockQuantity.fetchStockQuantity(
                                            controller.selcetedItemId!);
                                      }
                                    });

                                    // Find the selected item
                                    final selected =
                                        itemProvider.items.firstWhere(
                                      (item) => item.name == selectedItemName,
                                      orElse: () => itemProvider.items.first,
                                    );

                                    debugPrint(
                                        "🆔 Selected Item ID: ${selected.id}");

                                    // Ensure unitProvider is loaded
                                    if (unitProvider.units.isEmpty) {
                                      await unitProvider
                                          .fetchUnits(); // Ensure units are fetched
                                    }

                                    // Update unit dropdown list based on selected item
                                    unitIdsList.clear(); // Clear previous units

                                    // Debugging: Print unitId and secondaryUnitId for comparison
                                    debugPrint(
                                        "Selected item unitId: ${selected.unitId}");
                                    debugPrint(
                                        "Selected item secondaryUnitId: ${selected.secondaryUnitId}");

                                    // Add primary unit (unitId)
                                    if (selected.unitId != null &&
                                        selected.unitId != '') {
                                      final unit =
                                          unitProvider.units.firstWhere(
                                        (unit) {
                                          debugPrint(
                                              "Checking unit id: ${unit.id} against selected.unitId: ${selected.unitId?.toString()}");
                                          return unit.id.toString() ==
                                              selected.unitId?.toString();
                                        },
                                        orElse: () => Unit(
                                            id: 0,
                                            name: 'Unknown Unit',
                                            symbol: '',
                                            status: 0), // Default Unit
                                      );
                                      if (unit.id != 0) {
                                        unitIdsList.add(unit
                                            .symbol); //name // Add valid primary unit to list
                                      } else {
                                        debugPrint("Primary unit not found.");
                                      }
                                    }

                                    // Add secondary unit (secondaryUnitId)
                                    if (selected.secondaryUnitId != null &&
                                        selected.secondaryUnitId != '') {
                                      final secondaryUnit =
                                          unitProvider.units.firstWhere(
                                        (unit) {
                                          debugPrint(
                                              "Checking unit id: ${unit.id} against selected.secondaryUnitId: ${selected.secondaryUnitId?.toString()}");
                                          return unit.id.toString() ==
                                              selected.secondaryUnitId
                                                  ?.toString();
                                        },
                                        orElse: () => Unit(
                                            id: 0,
                                            name: 'Unknown Unit',
                                            symbol: '',
                                            status: 0), // Default Unit
                                      );
                                      if (secondaryUnit.id != 0) {
                                        unitIdsList.add(secondaryUnit
                                            .symbol); // Add valid secondary unit to list
                                      } else {
                                        debugPrint("Secondary unit not found.");
                                      }
                                    }

                                    // If unitIdsList is not empty, update the dropdown to show the units
                                    if (unitIdsList.isEmpty) {
                                      debugPrint(
                                          "No valid units found for this item.");
                                    } else {
                                      debugPrint(
                                          "Units Available: $unitIdsList");
                                    }
                                  },
                                );
                              },
                            ),
                          ),

                          ItemCustomDropDownTextField(
                            controller: TextEditingController(),
                            label: "Item",
                          ),

                          //stock
                          Consumer<AddItemProvider>(
                            builder: (context, stockProvider, child) {
                              //controller.mrpController.text = stockProvider.stockData!.price.toString();
                              if (stockProvider.stockData != null) {
                                controller.mrpController.text =
                                    stockProvider.stockData!.price.toString();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "   Stock Available:  ${stockProvider.stockData!.unitStocks} ৳ ${stockProvider.stockData!.price} ",
                                      //"   Stock Available: ${stockProvider.stockData!.stocks} (${stockProvider.stockData!.unitStocks}) ৳ ${stockProvider.stockData!.price} ",

                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "   ", // Updated message for empty stock
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),

                          vPad5,

                          ////qty and unit.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //qty
                              SizedBox(
                                width: 150,
                                child: AddSalesFormfield(
                                  label: "Qty",
                                  controller: controller.qtyController,
                                ),
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              //unit
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Unit",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: CustomDropdownTwo(
                                        hint: '',
                                        items:
                                            unitIdsList, // Holds unit names like ["Pces", "Packet"]
                                        width: 150,
                                        height: 30,
                                        selectedItem: controller.selectedUnit,
                                        onChanged: (selectedUnit) {
                                          print("Selected Unit: $selectedUnit");

                                          // Update the selected unit in controller
                                          controller.selectedUnit =
                                              selectedUnit;

                                          final selectedUnitObj =
                                              unitProvider.units.firstWhere(
                                            (unit) => unit.name == selectedUnit,
                                            orElse: () => Unit(
                                              id: 0,
                                              name: "Unknown Unit",
                                              symbol: "",
                                              status: 0,
                                            ),
                                          );

                                          String finalUnitString = '';
                                          int qty = 1; // Default qty

                                          // Search through fetchStockQuantity items to find unit ID and qty
                                          for (var item
                                              in fetchStockQuantity.items) {
                                            if (item.id.toString() ==
                                                controller.selcetedItemId) {
                                              String unitId =
                                                  selectedUnitObj.id.toString();
                                              String unitName = selectedUnit;

                                              // Check if selected unit is the primary or secondary unit and set the correct quantity
                                              if (unitId ==
                                                  item.secondaryUnitId
                                                      .toString()) {
                                                qty = item.secondaryUnitQty ??
                                                    item.unitQty ??
                                                    1; // Use secondaryUnitQty, fallback to unitQty or default to 1
                                              } else if (unitId ==
                                                  item.unitId.toString()) {
                                                qty = item.unitQty ??
                                                    1; // Use unitQty or fallback to 1
                                              }

                                              // Build the final unit string in the required format (e.g., 24_Pces_1)
                                              finalUnitString =
                                                  "${unitId}_${unitName}_$qty";
                                              controller
                                                  .selectedUnitIdWithNameFunction(
                                                      finalUnitString);
                                              break;
                                            }
                                          }

                                          // Fallback if no valid unit string was found
                                          if (finalUnitString.isEmpty) {
                                            finalUnitString =
                                                "${selectedUnitObj.id}_${selectedUnit}_1"; // Default to 1 if no match
                                            controller
                                                .selectedUnitIdWithNameFunction(
                                                    finalUnitString);
                                          }

                                          // Debug print to show final unit ID selected
                                          print(
                                              "🆔 Final Unit ID: $finalUnitString");

                                          // Notify listeners to update the UI
                                          controller.notifyListeners();
                                        },
                                      ),
                                    ),
                                  ]),
                            ],
                          ),

                          ///price
                          SizedBox(
                            width: 150,
                            child: AddSalesFormfield(
                              label: "Price",
                              controller: controller.mrpController,
                            ),
                          ),

                          hPad10,

                          ///discount amount and discount percentance

                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: AddSalesFormfield(
                                        label: "Discount (%)",
                                        controller:
                                            controller.discountPercentance,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          controller.lastChanged = 'percent';
                                          controller.calculateSubtotal();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: AddSalesFormfield(
                                        label: "Discount (Amount)",
                                        controller: controller.discountAmount,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          controller.lastChanged = 'amount';
                                          controller.calculateSubtotal();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ]),

                          // ✅ VAT/TAX Dropdown Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Consumer<TaxProvider>(
                                builder: (context, taxProvider, child) {
                                  if (taxProvider.isLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (taxProvider.taxList.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No tax options available.',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    width: 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "VAT/TAX (%)",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                        CustomDropdownTwo(
                                          hint: '',
                                          items: taxProvider.taxList
                                              .map((tax) =>
                                                  "${tax.name} - (${tax.percent})")
                                              .toList(),
                                          width: 150,
                                          height: 30,
                                          selectedItem: selectedTaxName,
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedTaxName = newValue;

                                              final nameOnly =
                                                  newValue?.split(" - ").first;

                                              final selected = taxProvider
                                                  .taxList
                                                  .firstWhere(
                                                (tax) => tax.name == nameOnly,
                                                orElse: () =>
                                                    taxProvider.taxList.first,
                                              );

                                              selectedTaxId =
                                                  selected.id.toString();

                                              controller.selectedTaxPercent =
                                                  double.tryParse(
                                                      selected.percent);

                                              // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                              controller.taxPercent = controller
                                                      .selectedTaxPercent ??
                                                  0.0;

                                              controller.updateTaxPaecentId(
                                                  '${selectedTaxId}_${controller.selectedTaxPercent}');

                                              print(
                                                  'tax_percent: "${controller.taxPercentValue}"');

                                              //controller.calculateSubtotal();

                                              debugPrint(
                                                  "Selected Tax ID: $selectedTaxId");
                                              debugPrint(
                                                  "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 150,
                                child: AddSalesFormfield(
                                  label: "TAX amount",
                                  controller: TextEditingController(
                                    text: controller.taxAmount.toStringAsFixed(
                                        2), // 👈 show calculated tax
                                  ),
                                  keyboardType: TextInputType.number,
                                  //readOnly: true, // 👈 prevent manual editing
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    //subtotal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          "Subtotal (with Tax):  ${controller.subtotalWithTax.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ///add item and new.
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                debugPrint("selectedItem ============|>");

                                //debugPrint(selectedItem);

                                controller.isCash
                                    ? updateProvider.addCashItemSaleUpdate(
                                        controller.selcetedItemId,
                                        controller.mrpController.text,
                                        controller.selectedUnitIdWithName,
                                        controller.qtyController.text,
                                        controller.discountAmount.text,
                                        controller.discountPercentance.text,
                                        controller.selectedTaxPercent
                                            .toString(),
                                        controller.taxAmount.toString(),
                                      )
                                    : controller.addCreditItem();

                                controller.addAmount();

                                Navigator.pop(context);

                                controller.clearFields();

                                setState(() {
                                  controller.seletedItemName = null;

                                  Provider.of<AddItemProvider>(context,
                                          listen: false)
                                      .clearPurchaseStockDatasale();

                                  controller.mrpController.clear();
                                  controller.qtyController.clear();
                                });
                              },
                              child: SizedBox(
                                width: 90,
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: colorScheme.primary,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 2),
                                      child: Center(
                                        child: Text(
                                          "Add & new",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ),

                        /// add item
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                debugPrint("selectedItem ============|>");

                                //debugPrint(selectedItem);

                                controller.isCash
                                    ? updateProvider.addCashItemSaleUpdate(
                                        controller.selcetedItemId,
                                        controller.mrpController.text,
                                        controller.selectedUnitIdWithName,
                                        controller.qtyController.text,
                                        controller.discountAmount.text,
                                        controller.discountPercentance.text,
                                        controller.selectedTaxPercent
                                            .toString(),
                                        controller.taxAmount.toString(),
                                      )
                                    : controller.addCreditItem();

                                controller.addAmount();

                                Navigator.pop(context);

                                controller.clearFields();

                                setState(() {
                                  controller.seletedItemName = null;

                                  Provider.of<AddItemProvider>(context,
                                          listen: false)
                                      .clearPurchaseStockDatasale();

                                  controller.mrpController.clear();
                                  controller.qtyController.clear();
                                });
                              },
                              child: SizedBox(
                                width: 90,
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: colorScheme.primary,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 2),
                                      child: Center(
                                        child: Text(
                                          "Add",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ));
        });
      },
    );
  }
}

class ItemModel {
  final String? category;
  final String? subCategory;
  final String? itemName;
  final String? itemCode;
  final String? mrp;
  final String? quantity;
  final String? total;
  final String? price;
  final String? unit;
  ItemModel({
    this.category,
    this.subCategory,
    this.itemName,
    this.itemCode,
    this.mrp,
    this.quantity,
    this.total,
    this.price,
    this.unit,
  });
}
