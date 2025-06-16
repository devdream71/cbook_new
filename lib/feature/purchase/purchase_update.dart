import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/purchase/controller/purchase_controller.dart';
import 'package:cbook_dt/feature/purchase/purchase_update_item.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/unit/model/demo_unit_model.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'model/purchase_update_by_id.dart';
import 'model/purchase_update_model.dart';

class PurchaseUpdateProvider extends ChangeNotifier {
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();
  TextEditingController billNumberController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();

  TextEditingController customerController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  List<PurchaseUpdateModel> purchaseUpdateList = [];

  TextEditingController grossTotalController = TextEditingController();
  TextEditingController discountTotalController = TextEditingController();

  String getSubTotal() {
    double subTotal = 0.00;
    for (var e in purchaseUpdateList) {
      subTotal += double.tryParse(e.subTotal) ?? 0.0;
    }
    return subTotal.toStringAsFixed(2);
  }

  /// Calculate Gross Total (Sub Total - Discount)
  String getGrossTotal() {
    double subTotal = double.tryParse(getSubTotal()) ?? 0.0;
    double discount = double.tryParse(discountTotalController.text) ?? 0.0;
    double grossTotal = subTotal - discount;
    return grossTotal.toStringAsFixed(2);
  }

  /// Update Gross Total whenever discount changes
  void updateGrossTotal() {
    grossTotalController.text = getGrossTotal(); // Update field
    notifyListeners();
  }

  bool isLoading = false;
  int? purchaseId;
  int? itemId;
  int? customerId;

  String? selectedItem;

  String? selectedItemNameInvoice;

  Map<int, String> itemMap = {};
  List<String> itemNames = [];
  String? selectedItemName;

  Map<int, String> unitMap = {};
  List<String> unitNames = [];
  String? selectedUnitName;

  List<dynamic> purchaseDetailsList = [];

  List<DemoUnitModel> unitResponseModel = [];

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
          unitMap[value['id']] =
              value['symbol']; // ✅ Use symbol instead of name
          unitNames.add(value['symbol']); // ✅ Use symbol in dropdown
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

  PurchaseEditResponse purchaseEditResponse = PurchaseEditResponse();

  Future<void> fetchPurchaseData(int id) async {
    isLoading = true;
    notifyListeners();

    await fetchItems();
    await fetchUnits();

    final url = "https://commercebook.site/api/v1/purchase/edit/$id";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      purchaseEditResponse = PurchaseEditResponse.fromJson(response.body);
      purchaseUpdateList.clear();
      purchaseEditResponse.data!.purchaseDetails!.forEach((e) {
        purchaseUpdateList.add(PurchaseUpdateModel(
          itemId: e.itemId.toString(),
          price: e.price.toString(),
          qty: e.qty.toString(),
          subTotal: e.subTotal.toString(),
          unitId: "${e.unitId.toString()}_${getUnitName(e.unitId.toString())}",
        ));
      });

      // print(purchaseUpdateList.length);
      debugPrint(purchaseUpdateList.length.toString());

      if (data['success']) {
        final purchaseData = purchaseEditResponse.data!;

        purchaseDetailsList = purchaseData.purchaseDetails ?? [];
        billNumberController.text = purchaseData.billNumber ?? "";
        purchaseDateController.text = purchaseData.purchaseDate ?? "";
        grossTotalController.text = purchaseData.grossTotal?.toString() ?? "";
        customerController.text = purchaseData.customerId?.toString() ?? "";
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
      selectedUnitName = null;
    }
    selectedUnitName = name;
    notifyListeners();
  }

  ///add cash item
  addCashItemPurchaseUpdate(String selectedItemId, String price,
      String selectedUnitIdWithName, String qty) {
    purchaseUpdateList.add(PurchaseUpdateModel(
        itemId: selectedItemId,
        price: price,
        qty: qty,
        subTotal: (double.parse(price) * double.parse(qty)).toString(),
        unitId: selectedUnitIdWithName));

    notifyListeners();
  }

  void updatePurchaseDetail(int index) {
    // Convert input values to double (assuming qty and price are double)
    int? updatedPrice = int.tryParse(priceController.text);
    int? updatedQty = int.tryParse(qtyController.text);

    // Ensure values are not null before updating
    if (updatedPrice != null && updatedQty != null) {
      purchaseUpdateList[index].qty = updatedQty.toString();
      purchaseUpdateList[index].price = updatedPrice.toString();
      purchaseUpdateList[index].subTotal =
          (updatedQty * updatedPrice).toString();

      purchaseUpdateList[index].unitId =
          "${purchaseEditResponse.data!.purchaseDetails![index].unitId.toString()}_${getUnitName(purchaseEditResponse.data!.purchaseDetails![index].unitId.toString())}";

      // Updating response model
      purchaseEditResponse.data!.purchaseDetails![index].price = updatedPrice;
      purchaseEditResponse.data!.purchaseDetails![index].qty = updatedQty;
      purchaseEditResponse.data!.purchaseDetails![index].subTotal =
          (updatedQty * updatedPrice);

      debugPrint(
          "Updated Price: ${purchaseEditResponse.data!.purchaseDetails![index].price}");
      debugPrint(
          "Updated Qty: ${purchaseEditResponse.data!.purchaseDetails![index].qty}");

      // Notify UI of changes
      notifyListeners();
    } else {
      debugPrint(
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

  Future<void> updatePurchase(context) async {
    // if (purchaseId == null) return;

    debugPrint(jsonEncode(purchaseUpdateList));

    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('_selectedDate ${_selectedDate}');

    final url =
        "http://commercebook.site/api/v1/purchase/update?id=${purchaseEditResponse.data!.purchaseDetails![0].purchaseId}&user_id=${prefs.getInt("user_id")}&customer_id=${purchaseEditResponse.data!.customerId}&bill_number=${purchaseEditResponse.data!.billNumber}&purchase_date=$_selectedDate&details_notes=notes&gross_total=${getSubTotal()}&discount=0&payment_out=0&payment_amount=${getGrossTotal()}";
    debugPrint(url);
    // Prepare request body
    final requestBody = {"purchase_items": purchaseUpdateList};

    print('_selectedDate ${_selectedDate}');

    if (requestBody.isNotEmpty) {
      debugPrint(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("API response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          debugPrint("Purchase successful: ${data["data"]}");

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeView()));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Purchase Update successful!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating, // Optional: Floating style
              duration:
                  Duration(seconds: 2), // Optional: Duration of visibility
            ),
          );
        } else {
          debugPrint("Error: ${data["message"]}");
        }
      } else {
        // print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } else {}
  }

  void addItem(
      {required int id,
      required int price,
      required int qty,
      required int subTotal,
      required int unitId}) {
    purchaseEditResponse.data!.purchaseDetails!.add(PurchaseDetail(
      itemId: id,
      price: price,
      qty: qty,
      subTotal: subTotal,
      unitId: unitId,
    ));
    purchaseUpdateList.add((PurchaseUpdateModel(
        //purchaseDetailsId: "0",
        itemId: id.toString(),
        qty: qty.toString(),
        //purchaseQty: "0",
        unitId: "${unitId.toString()}_${getUnitName(unitId.toString())}}",
        price: price.toString(),
        subTotal: subTotal.toString())));
    notifyListeners();
  }
}

///====>Purchase update Screen
class PurchaseUpdateScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseUpdateScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseUpdateScreen> createState() => _PurchaseUpdateScreenState();
}

class _PurchaseUpdateScreenState extends State<PurchaseUpdateScreen> {
  late PurchaseUpdateProvider provider;

  bool showNoteField = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemCategoryProvider>(context, listen: false)
          .fetchCategories();
      Provider.of<AddItemProvider>(context, listen: false).fetchItems();

      provider = Provider.of<PurchaseUpdateProvider>(context, listen: false);

      // Set today's date as default in the text controller
      provider.purchaseDateController.text =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseController>();
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint("purchase id");
    debugPrint(widget.purchaseId.toString());

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: true);

    return ChangeNotifierProvider(
      create: (_) =>
          PurchaseUpdateProvider()..fetchPurchaseData(widget.purchaseId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Update Purchase")),
        body: SingleChildScrollView(
          child: Consumer<PurchaseUpdateProvider>(
            builder: (context, provider, child) {
              debugPrint("======================");
              debugPrint(provider.qtyController.toString());
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
                                controller.updateCash();
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        //context.watch<PurchaseController>().isCash ? "Cash" : "Credit",
                                        controller.isCash ? "Cash" : "Credit",
                                        style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Bill Date",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            width: 150,
                                            child: InkWell(
                                              onTap: () =>
                                                  controller.pickDate(context),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  //color: Colors.white,
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        controller.formattedDate
                                                                .isNotEmpty
                                                            ? controller
                                                                .formattedDate
                                                            : "Select Date",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors
                                                          .blue, // Use your desired color
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                controller.isCash
                                    ? const Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Cash",
                                          style: TextStyle(color: Colors.black),
                                        ))
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: AddSalesFormfield(
                                                label: "Customer ID",
                                                controller: provider
                                                    .customerController),
                                          ),
                                          const Expanded(child: SizedBox()),
                                        ],
                                      ),

                                const SizedBox(
                                  height: 5,
                                ),

                                ////=====>item list
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.purchaseUpdateList.length,
                                  itemBuilder: (context, index) {
                                    final detail =
                                        provider.purchaseUpdateList![index];

                                    return GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdatePurchaseItemView(
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
                                                      Text("Qty: ${detail.qty}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      12)),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                          "Price: ৳ ${detail.price}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      12)),
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
                                              showSalesDialog(
                                                context,
                                                controller,
                                                provider,
                                              );
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
                                              showSalesDialog(
                                                context,
                                                controller,
                                                provider,
                                              );
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
                                              horizontal: 8.0),
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
                                                horizontal: 8),
                                            child: Center(
                                              child: TextField(
                                                controller: controller
                                                    .purchaseNoteController,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                                onChanged: (value) {
                                                  controller
                                                      .purchaseNoteController
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
                                  height: 2,
                                ),
                                //===>subtotal
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    //color: Colors.red,
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Subtotal",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          //color: Colors.amber,
                                          width: 150,
                                          height: 25,
                                          child: TextField(
                                            enabled: false,
                                            controller: TextEditingController(
                                                text: provider.getSubTotal()),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // //===>Discount
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Discount",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 150,
                                          height: 25,
                                          child: TextField(
                                            controller: provider
                                                .discountTotalController,
                                            onChanged: (value) {
                                              provider
                                                  .updateGrossTotal(); // Trigger the update for Gross Total
                                            },
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // //===>Gross Total

                                // ////===>gross total
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text("Gross Total",
                                            style:
                                                TextStyle(color: Colors.black)),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 150,
                                          height: 25,
                                          child:
                                              Consumer<PurchaseUpdateProvider>(
                                            builder:
                                                (context, provider, child) {
                                              return TextField(
                                                //  controller: TextEditingController(
                                                // text: provider.getSubTotal()),
                                                controller:
                                                    TextEditingController(
                                                        text: provider
                                                            .getGrossTotal()),

                                                readOnly: true,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ////payment
                                controller.isCash == false &&
                                        controller.isReturn == true
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                child: Checkbox(
                                                  value: controller
                                                      .isOnlineMoneyChecked,
                                                  onChanged: (bool? value) {
                                                    controller
                                                        .updateOnlineMoney();
                                                  },
                                                ),
                                              ),
                                              // const Text("Online Payment",
                                              //     style: TextStyle(color: Colors.green, fontSize: 12)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("Payment",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                height: 25,
                                                width: 150,
                                                child: TextField(
                                                  controller: controller
                                                      .receivedAmountController,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black),
                                                  readOnly: controller
                                                      .isOnlineMoneyChecked, // ✅ Read-only when checked
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
                                                    if (!controller
                                                        .isOnlineMoneyChecked) {
                                                      controller
                                                              .receivedAmountController
                                                              .text =
                                                          value; // ✅ Allow manual input
                                                    }
                                                  },
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
                                await provider.updatePurchase(context);
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
                                "Update Purchase",
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

  void showSalesDialog(BuildContext context, PurchaseController controller,
      PurchaseUpdateProvider updateProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);

    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    // Define local state variables
    String? selectedCategoryId;
    String? selectedSubCategoryId;

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                size: 15,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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

                          const SizedBox(
                            height: 3,
                          ),

                          // Category and Subcategory Row

                          const SizedBox(
                            height: 5,
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
                                            width: double
                                                .infinity, // Adjust as needed
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

                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  categoryProvider.isSubCategoryLoading
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
                                                          selectedSubCategory.id
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

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: CustomDropdownTwo(
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
                                      unitIdsList
                                          .clear(); // Clear previous units

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
                                              .symbol); // Add valid primary unit to list
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
                                          debugPrint(
                                              "Secondary unit not found.");
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
                                  ),
                                );
                              },
                            ),
                          ),

                          ItemCustomDropDownTextField(
                            controller: TextEditingController(),
                            label: "Item",
                          ),

                          vPad5,

                          const Text(
                            "Unit",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),

                          // Unit Dropdown
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: CustomDropdownTwo(
                              hint: '', //Choose a unit
                              items: unitIdsList,
                              width: double.infinity,
                              height: 30,
                              selectedItem: unitIdsList.isNotEmpty
                                  ? unitIdsList.first
                                  : null, // Default to first unit if available
                              onChanged: (selectedUnit) {
                                debugPrint("Selected Unit: $selectedUnit");
                                final selectedUnitObj =
                                    unitProvider.units.firstWhere(
                                  (unit) => unit.name == selectedUnit,
                                  orElse: () => Unit(
                                      id: 0,
                                      name: "Unknown Unit",
                                      symbol: "",
                                      status: 0),
                                );

                                controller.selectedUnitIdWithNameFunction(
                                    "${selectedUnitObj.id}_$selectedUnit");

                                debugPrint(
                                    "🆔 Selected Unit ID: ${selectedUnitObj.id}_$selectedUnit");
                              },
                            ),
                          ),

                          vPad5,
                          Row(
                            children: [
                              ///qty
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: AddSalesFormfield(
                                    label: "Qty",
                                    controller: controller.qtyController,
                                  ),
                                ),
                              ),
                              hPad10,

                              ///unit //===> its will be dropdown, base unit and second unit.
                            ],
                          ),

                          vPad5,
                          Row(
                            children: [
                              ///mrp
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: AddSalesFormfield(
                                    label: "Price",
                                    controller: controller.mrpController,
                                  ),
                                ),
                              ),

                              hPad10,
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                debugPrint("selectedItem ============|>");

                                //debugPrint(selectedItem);

                                controller.isCash
                                    ? updateProvider.addCashItemPurchaseUpdate(
                                        controller.selcetedItemId,
                                        controller.mrpController.text,
                                        controller.selectedUnitIdWithName,
                                        controller.qtyController.text)
                                    : controller.addCreditItem();
                                controller.addAmount();

                                Navigator.pop(context);

                                controller.mrpController.clear();
                                controller.qtyController.clear();
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

                        ///add item
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                debugPrint("selectedItem ============|>");

                                //debugPrint(selectedItem);

                                controller.isCash
                                    ? updateProvider.addCashItemPurchaseUpdate(
                                        controller.selcetedItemId,
                                        controller.mrpController.text,
                                        controller.selectedUnitIdWithName,
                                        controller.qtyController.text)
                                    : controller.addCreditItem();
                                controller.addAmount();

                                Navigator.pop(context);

                                controller.mrpController.clear();
                                controller.qtyController.clear();
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

///===>purchase ItemModel , to add data in model.

class ItemModel {
  final String? category;
  final String? subCategory;
  final String? itemName;
  final String? itemCode;
  final String? mrp;
  final String? quantity;
  final String? total;
  final String? price;
  ItemModel({
    this.category,
    this.subCategory,
    this.itemName,
    this.itemCode,
    this.mrp,
    this.quantity,
    this.total,
    this.price,
  });
}
