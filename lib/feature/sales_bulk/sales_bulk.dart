import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_create_form.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key? key}) : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;

  final String base_url = "https://commercebook.site/";

  String? selectedItem;

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() async {
      await Provider.of<AddItemProvider>(context, listen: false).fetchItems();
      final items = Provider.of<AddItemProvider>(context, listen: false).items;

      // Initialize quantities based on fetched items
      setState(() {
        quantities = List.generate(items.length, (index) => 0);
      });
    });
  }

  ///quantities
  List<int> quantities = List.generate(0, (index) => 0);

  ///total amount
  double get totalAmount {
    double total = 0;
    final items = Provider.of<AddItemProvider>(context, listen: false).items;
    for (int i = 0; i < quantities.length; i++) {
      total += quantities[i] * items[i].salesPrice;
    }
    return total;
  }

  ///item count
  int get totalItems {
    return quantities.where((qty) => qty > 0).length;
  }
    
    DateTime _selectedDate = DateTime.now();
    
    String get formattedDate => DateTimeHelper.formatDate(_selectedDate);


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final categoryProvider = Provider.of<ItemCategoryProvider>(context);

    final controller = context.watch<SalesController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: InkWell(
            onTap: () {
              final customerProvider =
                  Provider.of<CustomerProvider>(context, listen: false);

              // Clear selected customer
              customerProvider.clearSelectedCustomer();

              // Clear customer list
              customerProvider.clearCustomerList();

              // Clear customer name from TextField
              controller.customerNameController.clear();

              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.surface,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BillInvoiceCreateForm()));
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ))
          ],
          title:   Column(
            children: [
              const Text(
                'Item List',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sal/423',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  //Text('', style: TextStyle(fontSize: 24, color: Colors.white),)
                ],
              ),
            ],
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///cash and credit , if creadit then show customer list.
          Container(
            //color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2),
                    child: InkWell(
                      onTap: () {
                        controller.updateCash(context);

                        Provider.of<CustomerProvider>(context, listen: false)
                            .clearSelectedCustomer();

                        final customerProvider = Provider.of<CustomerProvider>(
                            context,
                            listen: false);

                        // Clear selected customer
                        customerProvider.clearSelectedCustomer();

                        // Clear customer list
                        customerProvider.clearCustomerList();

                        // Clear customer name from TextField
                        controller.customerNameController.clear();
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
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
                ),

                const SizedBox(
                  width: 6,
                ),

                //customer list.
                controller.isCash
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: SizedBox(
                          width: 320,
                          height: 53,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///show text field search ====>
                              AddSalesFormfieldTwo(
                                controller: controller.customerNameController,
                                customerorSaleslist: "Showing Customer list",
                                customerOrSupplierButtonLavel: "Add customer",
                                color: Colors.grey,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CustomerCreate()));
                                },
                                //label: "Customer",
                              ),

                              /// show bottom payable or recivedable.
                              Consumer<CustomerProvider>(
                                builder: (context, customerProvider, child) {
                                  final customerList =
                                      customerProvider.customerResponse?.data ??
                                          [];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // If the customer list is empty, show a SizedBox
                                      if (customerList.isEmpty)
                                        const SizedBox(
                                            height:
                                                2), // Adjust height as needed

                                      // Otherwise, show the dropdown with customers
                                      if (customerList.isNotEmpty)

                                        // Check if the selected customer is valid
                                        if (customerProvider.selectedCustomer !=
                                                null &&
                                            customerProvider
                                                    .selectedCustomer!.id !=
                                                -1)
                                          Row(
                                            children: [
                                              Text(
                                                "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: customerProvider
                                                              .selectedCustomer!
                                                              .type ==
                                                          'customer'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.0),
                                                child: Text(
                                                  "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),

          ///category and subcategory section.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // CATEGORY Dropdown
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Category",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: categoryProvider.isLoading
                            ? const SizedBox()
                            : CustomDropdownTwo(
                                items: categoryProvider.categories
                                    .map((category) => category.name)
                                    .toList(),
                                hint: '',
                                width: double.infinity,
                                height: 30,
                                onChanged: (value) {
                                  final selectedCategory = categoryProvider
                                      .categories
                                      .firstWhere((cat) => cat.name == value);

                                  setState(() {
                                    selectedCategoryId = selectedCategory.id;
                                    selectedSubCategoryId = null;
                                  });

                                  categoryProvider
                                      .fetchSubCategories(selectedCategory.id);

                                  Provider.of<AddItemProvider>(context,
                                          listen: false)
                                      .filterItems(selectedCategoryId, null);
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // SUBCATEGORY Dropdown
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 180,
                        child: categoryProvider.isSubCategoryLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : categoryProvider.subCategories.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Sub Category",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      CustomDropdownTwo(
                                        items: categoryProvider.subCategories
                                            .map((subCategory) =>
                                                subCategory.name)
                                            .toList(),
                                        hint: '',
                                        width: double.infinity,
                                        height: 30,
                                        onChanged: (value) {
                                          final selectedSubCategory =
                                              categoryProvider.subCategories
                                                  .firstWhere((subCat) =>
                                                      subCat.name == value);

                                          setState(() {
                                            selectedSubCategoryId =
                                                selectedSubCategory.id;
                                          });
                                          debugPrint(
                                              "Selected SubCategory: $selectedSubCategoryId");
                                          Provider.of<AddItemProvider>(context,
                                                  listen: false)
                                              .filterItems(selectedCategoryId,
                                                  selectedSubCategoryId);
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          ///all item show here
          Consumer<AddItemProvider>(
            builder: (context, itemProvider, child) {
              if (itemProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (itemProvider.filteredItems.isEmpty) {
                return const Center(
                  child: Text(
                    'No items available.',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                  itemCount: itemProvider.filteredItems.length,
                  itemBuilder: (context, index) {
                    ItemsModel item = itemProvider.filteredItems[index];

                    return InkWell(
                      onTap: () {
                        showSalesDialog(context, controller,
                            selectedItem: item);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 1),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 16, right: 2),
                          title: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey.shade200,
                                ),
                                child: Image.network(
                                  "$base_url${item.image}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/image/cbook_logo.png",
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        'pp: ${item.purchasePrice}   sp: ${item.salesPrice}   Stock: ${item.openingStock}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ),

                              /// add item and remove item.
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(
                                    //       color: Colors.green, width: 1),
                                    //   borderRadius: BorderRadius.circular(
                                    //       30), // Makes the pill shape
                                    // ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (quantities[index] > 0)
                                                quantities[index]--;
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade500,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              //color: Colors.grey,
                                              //shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.remove,
                                                color: Colors.green, size: 18),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '${quantities[index]}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              quantities[index]++;
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              //color: Colors.grey,
                                              border: Border.all(
                                                  color: Colors.grey.shade500,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              //shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.green, size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Container(
          //   decoration: BoxDecoration(
          //       color: Colors.purple,
          //       border: Border.all(),
          //       borderRadius: BorderRadius.circular(4)),
          //   child: Row(
          //     children: [
          //       const Icon(
          //         Icons.shopping_bag,
          //         size: 24,
          //         color: Colors.white,
          //       ),
          //       Text('Item: $totalItems',
          //           style: const TextStyle(
          //               fontSize: 12,
          //               color: Colors.white,
          //               fontFamily: 'Calibri')),
          //       Text(
          //         'Amount $totalAmount',
          //         style: const TextStyle(
          //             fontSize: 12, color: Colors.white, fontFamily: 'Calibri'),
          //       ),
          //       Row(
          //         children: [
          //           GestureDetector(
          //             onTap: () {},
          //             child: const Icon(
          //               Icons.document_scanner,
          //               size: 24,
          //               color: Colors.white,
          //             ),
          //           ),
          //           GestureDetector(
          //             onTap: () {},
          //             child: const Icon(
          //               Icons.save,
          //               size: 24,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.add_shopping_cart,
                  color: Colors.white, size: 24),
              Text('Item: $totalItems',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text('Amount: $totalAmount',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.receipt, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.save, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSalesDialog(BuildContext context, SalesController controller,
      {required ItemsModel selectedItem}) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    final controller = Provider.of<SalesController>(context, listen: false);

    //final TextEditingController itemController = TextEditingController();

    //final TextEditingController itemController = TextEditingController(text: selectedItem.name);

    final TextEditingController itemController =
        TextEditingController(text: selectedItem.name);

    String? selectedTaxName;
    String? selectedTaxId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // ✅ Fetch categories
    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.fetchCategories();
    }

    if (taxProvider.taxList.isEmpty) {
      await taxProvider.fetchTaxes();
    }

    Provider.of<AddItemProvider>(context, listen: false).clearStockData();
    controller.clearFields();

    // ✅ Pop the loading dialog
    Navigator.of(context).pop();

    // Define local state variables
    String? selectedCategoryId;
    String? selectedSubCategoryId;

    //String? selectedItemNameInvoice;
    List<String> unitIdsList = [];

    @override
    void dispose() {
      itemController.dispose();
      super.dispose();
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            // ✅ Use StatefulBuilder to update UI

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller =
                  Provider.of<SalesController>(context, listen: false);

              controller.addListener(() {
                setState(() {});
              });
            });

            bool isLoading =
                categoryProvider.isLoading || fetchStockQuantity.isLoading;

            return Dialog(
              backgroundColor: Colors.grey.shade400,
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  height: 380,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xffe7edf4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        color: const Color(0xff278d46),
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
                              children: [
                                Icon(
                                  Icons.add_box,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Add Item & service",
                                  style: TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.green,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),

                            ///new item search <<<<<<==========
                            Container(
                              //color: Colors.red,
                              child: ItemCustomDropDownTextField(
                                controller: itemController,
                                //label: "Select Item",

                                onItemSelected: (selectedItem) async {
                                  // This will print the id and name when item is selected
                                  debugPrint(
                                      "=======> Selected Item: ${selectedItem.name} (ID: ${selectedItem.id})");

                                  setState(() {
                                    // Save selected item name and id in controller
                                    controller.seletedItemName =
                                        selectedItem.name;
                                    controller.selcetedItemId =
                                        selectedItem.id.toString();

                                    // Fetch stock quantity
                                    if (controller.selcetedItemId != null) {
                                      fetchStockQuantity.fetchStockQuantity(
                                          controller.selcetedItemId!);
                                    }
                                  });

                                  // Ensure unitProvider is loaded
                                  if (unitProvider.units.isEmpty) {
                                    await unitProvider
                                        .fetchUnits(); // Ensure units are fetched
                                  }

                                  // Clear previous units
                                  unitIdsList.clear();

                                  print(
                                      "Selected item unitId: ${selectedItem.unitId}");
                                  print(
                                      "Selected item secondaryUnitId: ${selectedItem.secondaryUnitId}");

                                  // Base unit
                                  if (selectedItem.unitId != null &&
                                      selectedItem.unitId != '') {
                                    final unit = unitProvider.units.firstWhere(
                                      (unit) =>
                                          unit.id.toString() ==
                                          selectedItem.unitId.toString(),
                                      orElse: () => Unit(
                                          id: 0,
                                          name: 'Unknown Unit',
                                          symbol: '',
                                          status: 0),
                                    );
                                    if (unit.id != 0) {
                                      unitIdsList.add(unit.name);
                                      controller.selectedUnit = unit.name;

                                      // Create final unit string like: "24_Pces_1"
                                      String finalUnitString =
                                          "${unit.id}_${unit.name}_1";
                                      controller.selectedUnitIdWithNameFunction(
                                          finalUnitString);
                                    }
                                  }

                                  // Secondary unit
                                  if (selectedItem.secondaryUnitId != null &&
                                      selectedItem.secondaryUnitId != '') {
                                    final secondaryUnit =
                                        unitProvider.units.firstWhere(
                                      (unit) =>
                                          unit.id.toString() ==
                                          selectedItem.secondaryUnitId
                                              .toString(),
                                      orElse: () => Unit(
                                          id: 0,
                                          name: 'Unknown Unit',
                                          symbol: '',
                                          status: 0),
                                    );
                                    if (secondaryUnit.id != 0) {
                                      unitIdsList.add(secondaryUnit.name);
                                    }
                                  }

                                  if (unitIdsList.isEmpty) {
                                    print(
                                        "No valid units found for this item.");
                                  } else {
                                    print("Units Available: $unitIdsList");
                                  }
                                },
                              ),
                            ),

                            ///update stock code , for custome price input
                            SizedBox(
                              //color: Colors.blue,
                              child: Consumer<AddItemProvider>(
                                builder: (context, stockProvider, child) {
                                  final stock = stockProvider.stockData;

                                  if (stock != null &&
                                      !controller.hasCustomPrice) {
                                    controller.mrpController.text =
                                        stock.price.toString();
                                  }

                                  return stock != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "   Stock Available: ${stock.unitStocks} ৳ ${stock.price}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(); // Show nothing if stock is null
                                },
                              ),
                            ),

                            ///qty , unit
                            Container(
                              //color: Colors.yellow,
                              child: SizedBox(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        //qty
                                        Container(
                                          //color: Colors.purple,
                                          child: SizedBox(
                                            width: 150,
                                            child: AddSalesFormfield(
                                              label: "", //Qty
                                              labelText: "Item Qty",

                                              controller:
                                                  controller.qtyController,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  controller
                                                      .calculateSubtotal();
                                                });

                                                ///<<<===
                                                //controller.calculateSubtotal();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    ///===>>>unit
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),

                                        ///unit dropdown
                                        SizedBox(
                                          height: 30,
                                          width: 150,
                                          child: CustomDropdownTwo(
                                            hint: '',
                                            items:
                                                unitIdsList, // Holds unit names like ["Pces", "Packet"]
                                            width: double.infinity,
                                            height: 30,
                                            //labelText: 'Vat/Tax',
                                            labelText: 'Unit',
                                            selectedItem:
                                                controller.selectedUnit,
                                            onChanged: (selectedUnit) {
                                              print(
                                                  "Selected Unit: $selectedUnit");

                                              // Update the selected unit in controller
                                              controller.selectedUnit =
                                                  selectedUnit;

                                              final selectedUnitObj =
                                                  unitProvider.units.firstWhere(
                                                (unit) =>
                                                    unit.name == selectedUnit,
                                                orElse: () => Unit(
                                                  id: 0,
                                                  name: "Unknown Unit",
                                                  symbol: "",
                                                  status: 0,
                                                ),
                                              );

                                              //String finalUnitStringID = '';

                                              String finalUnitString = '';
                                              int qty = 1; // Default qty

                                              // Search through fetchStockQuantity items to find unit ID and qty
                                              for (var item
                                                  in fetchStockQuantity.items) {
                                                if (item.id.toString() ==
                                                    controller.selcetedItemId) {
                                                  String unitId =
                                                      selectedUnitObj.id
                                                          .toString();
                                                  String unitName =
                                                      selectedUnit;

                                                  // Check if selected unit is the primary or secondary unit and set the correct quantity
                                                  if (unitId ==
                                                      item.secondaryUnitId
                                                          .toString()) {
                                                    qty = item
                                                            .secondaryUnitQty ??
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
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),

                            // Unit Dropdown

                            //purchase
                            Container(
                              //color: Colors.blueGrey,
                              child: AddSalesFormfield(
                                height: 30,
                                label: "", //price
                                labelText: "Price",
                                controller: controller.mrpController,
                                keyboardType: TextInputType.number,
                                readOnly: false,
                                onChanged: (value) {
                                  setState(() {
                                    controller.hasCustomPrice = true;
                                    controller.calculateSubtotal();
                                  });
                                },
                              ),
                            ),

                            ////discount percentan ande amount
                            Container(
                              //color: Colors.tealAccent,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          //discount %
                                          child: SizedBox(
                                            width: 150,
                                            child: AddSalesFormfield(
                                              labelText: "Discount (%)",
                                              label: " ", //Discount (%)
                                              controller: controller
                                                  .discountPercentance,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  controller.lastChanged =
                                                      'percent';
                                                  controller
                                                      .calculateSubtotal();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          //discount amount
                                          child: SizedBox(
                                            width: 150,
                                            child: AddSalesFormfield(
                                              label: "", //Amount
                                              labelText: "Amount",
                                              controller:
                                                  controller.discountAmount,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  controller.lastChanged =
                                                      'amount';

                                                  controller
                                                      .calculateSubtotal();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),

                            // ✅ VAT/TAX Dropdown Row
                            Container(
                              //color: Colors.brown,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dropdown
                                  Expanded(
                                    child: Consumer<TaxProvider>(
                                      builder: (context, taxProvider, child) {
                                        if (taxProvider.isLoading) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
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
                                        return SizedBox(
                                          width: 150,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              //vat, tax %
                                              SizedBox(
                                                height: 30,
                                                child: CustomDropdownTwo(
                                                  labelText: 'Vat/Tax',
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
                                                      selectedTaxName =
                                                          newValue;

                                                      final nameOnly = newValue
                                                          ?.split(" - ")
                                                          .first;

                                                      final selected =
                                                          taxProvider.taxList
                                                              .firstWhere(
                                                        (tax) =>
                                                            tax.name ==
                                                            nameOnly,
                                                        orElse: () =>
                                                            taxProvider
                                                                .taxList.first,
                                                      );

                                                      selectedTaxId = selected
                                                          .id
                                                          .toString();

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

                                                      debugPrint(
                                                          'tax_percent: "${controller.taxPercentValue}"');

                                                      //controller.calculateSubtotal();

                                                      debugPrint(
                                                          "Selected Tax ID: $selectedTaxId");
                                                      debugPrint(
                                                          "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  //vat, tax amount
                                  SizedBox(
                                    width: 150,
                                    child: AddSalesFormfield(
                                      readOnly: true,
                                      label: "", //amount
                                      labelText: "Amount",
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
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            ///total sub
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      "Subtotal (with Tax):  ",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        "${controller.subtotalWithTax.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      ///add & new , add
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 4,
                          ),

                          /////====> add item
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: () async {
                                  debugPrint("Add Item");

                                  debugPrint(
                                      "selectedItem ======= $selectedItem =====|>");

                                  debugPrint(
                                      "Selected Unit: ${controller.selectedUnit}");
                                  debugPrint(
                                      "Selected Unit ID: ${controller.selectedUnitIdWithName}");

                                  if (controller.qtyController.text.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                        'Please entry the QTY',
                                      ),
                                      backgroundColor: Colors.red,
                                    ));
                                  } else {
                                    setState(() {
                                      controller.isCash
                                          ? controller.addCashItem()
                                          : controller.addCreditItem();

                                      controller.isCash
                                          ? controller.addAmount2()
                                          : controller.addAmount();

                                      //controller.addAmount();
                                    });

                                    controller.clearFields();

                                    Navigator.pop(context);
                                  }

                                  Provider.of<SalesController>(context,
                                          listen: false)
                                      .notifyListeners();

                                  setState(() {
                                    controller.seletedItemName = null;

                                    Provider.of<AddItemProvider>(context,
                                            listen: false)
                                        .clearPurchaseStockDatasale();

                                    controller.mrpController.clear();
                                    controller.qtyController.clear();
                                  });

                                  // ✅ Clear stock info

                                  // debugPrint(controller.items.length.toString());
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            );
          });
        });
  }
}
