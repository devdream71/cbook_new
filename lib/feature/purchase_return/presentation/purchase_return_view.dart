import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/purchase_return/controller/purchase_return_controller.dart';
import 'package:cbook_dt/feature/purchase_return/layer/bottom_portion_purchase_return.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_item_details.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../common/give_information_dialog.dart';
import '../../sales/widget/add_sales_formfield.dart';
part '../layer/purchase_return_field_portion.dart';

class PurchaseReturnView extends StatefulWidget {
  const PurchaseReturnView({super.key});

  @override
  State<PurchaseReturnView> createState() => _PurchaseReturnViewState();
}

class _PurchaseReturnViewState extends State<PurchaseReturnView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Provider.of<AddItemProvider>(context, listen: false).fetchItems();

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseReturnController>();
    return const _Layout();

    // ChangeNotifierProvider(
    //   create: (_) => PurchaseReturnController(),
    //   builder: (context, child) => const _Layout(),
    // );
  }
}

class _Layout extends StatefulWidget {
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  String? selectedItem;
  Customer? selectedCustomerObject;

  int? selectedSubCategoryId;

  String? selectedCustomer;
  String? selectedCustomerId;

  String? selectedItemNameInvoice;

  List<String> unitIdsList = [];

  List<double> amount = [];

  bool showNoteField = false;

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<PurchaseReturnController>();

    List<InvoiceItem> invoiceItems = controller.itemsCashReuturn.map((item) {
      return InvoiceItem(
        itemName: item.itemName ?? "",
        unit: item.unit ?? "Pc",
        //unit: "N/A", // You might need to update this logic
        quantity: int.tryParse(item.quantity ?? "0") ?? 0,
        amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
            (double.tryParse(item.mrp ?? "0") ?? 0.0),
      );
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light, // for Android
        statusBarBrightness: Brightness.dark, // for iOS
      ),
      child: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: colorScheme.surface,
                ),
              ),
              centerTitle: true,
              title: Text(
                "Purchase Return Invoice",
                style: GoogleFonts.lato(
                  color: Colors.yellow,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      //////=====>=====>updateCash==========<<<<<<<
                                      controller.updateCash();
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child:

                                            //PaymentToggle(isCash: true, onToggle: ,)

                                            Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller.isCash
                                                  ? "Cash"
                                                  : "Credit",
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
                                  vPad2,
                                  const Text(
                                    "Bill To",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  vPad5,
                                  const Text(
                                    "Cash",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 190,
                                        // Adjusted height for cursor visibility
                                        child: controller.isCash
                                            ? TextField(
                                                readOnly: true,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      child: ReusableForm(
                                                        nameController:
                                                            nameController,
                                                        phoneController:
                                                            phoneController,
                                                        emailController:
                                                            emailController,
                                                        addressController:
                                                            addressController,
                                                        primaryColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onCancel: _onCancel,
                                                        onSubmit: () {
                                                          setState(() {
                                                            controller
                                                                .updatedCustomerInfomation(
                                                              nameFrom:
                                                                  nameController
                                                                      .text,
                                                              phoneFrom:
                                                                  phoneController
                                                                      .text,
                                                              emailFrom:
                                                                  emailController
                                                                      .text,
                                                              addressFrom:
                                                                  addressController
                                                                      .text,
                                                            );
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },

                                                controller: controller
                                                    .controller, // Managing text field content
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                                decoration: InputDecoration(
                                                  // filled: true,
                                                  fillColor: Colors.white,
                                                  border: UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 12,
                                                    horizontal: 2,
                                                  ),
                                                ),
                                                cursorHeight:
                                                    12, // Adjusted cursor height
                                                cursorWidth:
                                                    2, // Adjusted cursor width for visibility
                                              )
                                            : Consumer<CustomerProvider>(
                                                builder: (context,
                                                    customerProvider, child) {
                                                  if (customerProvider
                                                      .isLoading) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }

                                                  if (customerProvider
                                                      .errorMessage
                                                      .isNotEmpty) {
                                                    return Center(
                                                      child: Text(
                                                        customerProvider
                                                            .errorMessage,
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 16),
                                                      ),
                                                    );
                                                  }

                                                  final customerList =
                                                      customerProvider
                                                              .customerResponse
                                                              ?.data ??
                                                          [];

                                                  if (customerList.isEmpty) {
                                                    return const Center(
                                                      child: Text(
                                                        "No Customer Found",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    );
                                                  }

                                                  // ✅ Map customer ID & Name
                                                  final dropdownItems =
                                                      customerList
                                                          .map((customer) =>
                                                              "${customer.name}") // Store both ID and Name
                                                          .toList();

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomDropdownTwo(
                                                        items: dropdownItems,
                                                        hint: "Select Customer",
                                                        width: 350,
                                                        height: 25,
                                                        selectedItem:
                                                            selectedCustomer, // Set initially selected item
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedCustomer =
                                                                value;
                                                            if (selectedCustomer !=
                                                                null) {
                                                              selectedCustomerObject =
                                                                  customerList
                                                                      .firstWhere(
                                                                (customer) =>
                                                                    customer
                                                                        .name ==
                                                                    selectedCustomer,
                                                                orElse: () =>
                                                                    Customer(
                                                                  id: -1,
                                                                  userId: 0,
                                                                  name: '',
                                                                  proprietorName:
                                                                      '',
                                                                  due: 0,
                                                                  purchases: [],
                                                                ),
                                                              );

                                                              selectedCustomerId =
                                                                  selectedCustomerObject!
                                                                      .id
                                                                      .toString();

                                                              // ✅ Update AddItemProvider with selected customer ID
                                                              Provider.of<AddItemProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .setSelectedCustomerId(
                                                                      selectedCustomerId!);

                                                              // Find the selected customer object based on the ID
                                                              selectedCustomerObject =
                                                                  customerList
                                                                      .firstWhere(
                                                                (customer) =>
                                                                    customer.id
                                                                        .toString() ==
                                                                    selectedCustomerId,
                                                                orElse: () =>
                                                                    Customer(
                                                                  id: -1,
                                                                  userId: 0,
                                                                  name: '',
                                                                  proprietorName:
                                                                      '',
                                                                  due: 0,
                                                                  purchases: [],
                                                                ),
                                                              );
                                                            }
                                                          });

                                                          debugPrint(
                                                              "Selected Customer ID: $selectedCustomerId"); // Debugging
                                                        },
                                                      ),

                                                      // Show the due amount of the selected customer
                                                      if (selectedCustomerObject !=
                                                              null &&
                                                          selectedCustomerObject!
                                                                  .id !=
                                                              -1)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: Text(
                                                            "Customer Due: ৳ ${selectedCustomerObject!.due.toStringAsFixed(2)}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      // Text(
                                                      //     "${selectedCustomerObject!.type == 'customer' ? 'Receivable' : 'Payable'}: ৳ ${selectedCustomerObject!.due.toStringAsFixed(2)}"
                                                      //     "\nName: ${selectedCustomerObject!.name}"
                                                      //     "\nPhone: ${selectedCustomerObject!.phone}"
                                                      //     "\nAddress: ${selectedCustomerObject!.address}",
                                                      //     style: TextStyle(
                                                      //       fontSize: 9,
                                                      //       color: selectedCustomerObject!
                                                      //                   .type ==
                                                      //               'customer'
                                                      //           ? Colors.green
                                                      //           : Colors.red,
                                                      //       fontWeight:
                                                      //           FontWeight
                                                      //               .bold,
                                                      //       overflow:
                                                      //           TextOverflow
                                                      //               .ellipsis,
                                                      //     ),
                                                      //   ),),
                                                    ],
                                                  );
                                                },
                                              ),
                                      ),
                                      hPad3, // Space between TextField and Icon
                                      // InkWell(
                                      //   onTap: () {
                                      //     ScaffoldMessenger.of(context)
                                      //         .showSnackBar(
                                      //       SnackBar(
                                      //         backgroundColor:
                                      //             colorScheme.primary,
                                      //         duration:
                                      //             const Duration(seconds: 1),
                                      //         content: const Text(
                                      //           'Fetch Successfully',
                                      //           style: TextStyle(
                                      //               color: Colors.white),
                                      //         ),
                                      //       ),
                                      //     );
                                      //   },
                                      //   child: const Icon(
                                      //     Icons.sync,
                                      //     size: 18,
                                      //     color: Colors.green,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  vPad5,
                                  nameController.value.text == ""
                                      ? const SizedBox.shrink()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Name: ${controller.customerName}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10)),
                                            Text("Phone: ${controller.phone}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10)),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            hPad10,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Bill No Field
                                  SizedBox(
                                    height: 30,
                                    width: 127,
                                    child: AddSalesFormfield(
                                      controller: controller.billNoController,
                                      decoration: InputDecoration(
                                        isDense:
                                            true, // Ensures the field is compact
                                        contentPadding: EdgeInsets
                                            .zero, // Removes unnecessary padding
                                        hintText: "Bill no",
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 25,
                                    width: 127,
                                    child: InkWell(
                                      onTap: () => controller.pickDate(
                                          context), // Trigger the date picker
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          suffixIconConstraints:
                                              const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ), // Adjust constraints to align icon closely
                                          hintText: "Bill Date",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 10,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400,
                                                width: 0.5),
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.green),
                                          ),
                                        ),
                                        child: Text(
                                          controller.formattedDate.isNotEmpty
                                              ? controller.formattedDate
                                              : "Select Date", // Default text when no date is selected
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  ///bill person
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Consumer<PaymentVoucherProvider>(
                                      builder: (context, provider, child) {
                                        return SizedBox(
                                          height: 30,
                                          width: double.infinity,
                                          child: provider.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : CustomDropdownTwo(
                                                  hint: '',
                                                  items:
                                                      provider.billPersonNames,
                                                  width: double.infinity,
                                                  height: 30,
                                                  labelText: 'Bill Person',
                                                  selectedItem:
                                                      selectedBillPerson,
                                                  onChanged: (value) {
                                                    debugPrint(
                                                        '=== Bill Person Selected: $value ===');
                                                    setState(() {
                                                      selectedBillPerson =
                                                          value;
                                                      selectedBillPersonData =
                                                          provider.billPersons
                                                              .firstWhere(
                                                        (person) =>
                                                            person.name ==
                                                            value,
                                                      ); // ✅ Save the whole object globally
                                                      selectedBillPersonId =
                                                          selectedBillPersonData!
                                                              .id;
                                                    });

                                                    debugPrint(
                                                        'Selected Bill Person Details:');
                                                    debugPrint(
                                                        '- ID: ${selectedBillPersonData!.id}');
                                                    debugPrint(
                                                        '- Name: ${selectedBillPersonData!.name}');
                                                    debugPrint(
                                                        '- Phone: ${selectedBillPersonData!.phone}');
                                                  }),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                        vPad10,

                        /// Item Dropdown
                        SizedBox(
                          height: 52,
                          width: 200,
                          child: Consumer<AddItemProvider>(
                            builder: (context, itemProvider, child) {
                              if (itemProvider.isLoading) {
                                return const Center(child: SizedBox());
                              }

                              if (itemProvider.items.isEmpty) {
                                return const Center(
                                  child: Text('No items available.',
                                      style: TextStyle(color: Colors.black)),
                                );
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selected an item",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: CustomDropdownTwo(
                                      hint: '', //hint: 'Choose an item',
                                      items: itemProvider.items
                                          .map((item) => item.name)
                                          .toList(),
                                      width: double.infinity,
                                      height: 30,
                                      selectedItem: controller.seletedItemName,
                                      onChanged: (selectedItemName) async {
                                        setState(() {
                                          controller.seletedItemName =
                                              selectedItemName;
                                          itemProvider.items.forEach((e) {
                                            if (selectedItemName == e.name) {
                                              controller.selcetedItemId =
                                                  e.id.toString();
                                            }
                                          });
                                        });

                                        if (controller.selcetedItemId != null) {
                                          await itemProvider
                                              .fetchPurchaseHistory(
                                                  controller.selcetedItemId);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// Purchase History (Only show after item selection)
                        Consumer<AddItemProvider>(
                          builder: (context, itemProvider, child) {
                            if (controller.seletedItemName == null) {
                              return const Center(
                                  child: Text("Please select an item"));
                            }

                            if (itemProvider.isHistoryLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (itemProvider.purchaseHistory.isEmpty) {
                              return const Center(
                                  child: Text(
                                "No Purchase History Available",
                                style: TextStyle(color: Colors.black),
                              ));
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PurchaseReturnDetailsPage(
                                              purchaseHistory:
                                                  itemProvider.purchaseHistory,
                                              itemName:
                                                  controller.seletedItemName!,
                                              // Pass data
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Rounded corners
                                        ),
                                      ),
                                      child: const Text(
                                        "Purchase Return",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                )
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        ////=====> cash product.
                        // controller.isCash
                        //     ? controller.itemsCashReuturn.isEmpty
                        //         ? Container(
                        //             decoration: BoxDecoration(
                        //               color: colorScheme.primary,
                        //               borderRadius: BorderRadius.circular(5),
                        //               boxShadow: [
                        //                 BoxShadow(
                        //                   color: Colors.black.withOpacity(0.2),
                        //                   blurRadius: 5,
                        //                   offset: const Offset(0, 3),
                        //                 ),
                        //               ],
                        //             ),
                        //             child: Padding(
                        //               padding: const EdgeInsets.all(4.0),
                        //               child: Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.spaceBetween,
                        //                 children: [
                        //                   const Text(
                        //                     "Products",
                        //                     style: TextStyle(
                        //                         color: Colors.white, fontSize: 14),
                        //                   ),
                        //                   InkWell(
                        //                     onTap: () {
                        //                       showSalesDialog(context, controller);
                        //                       setState(() {});
                        //                     },
                        //                     child: const Icon(
                        //                       Icons.add,
                        //                       color: Colors.white,
                        //                       size: 18,
                        //                     ),
                        //                   )
                        //                 ],
                        //               ),
                        //             ),
                        //           )
                        //         : const SizedBox.shrink()
                        //     : controller.itemsCreditReturn.isEmpty
                        //         ? Container(
                        //             decoration: BoxDecoration(
                        //               color: colorScheme.primary,
                        //               borderRadius: BorderRadius.circular(5),
                        //               boxShadow: [
                        //                 BoxShadow(
                        //                   color: Colors.black.withOpacity(0.2),
                        //                   blurRadius: 5,
                        //                   offset: const Offset(0, 3),
                        //                 ),
                        //               ],
                        //             ),
                        //             child: Padding(
                        //               padding: const EdgeInsets.all(4.0),
                        //               child: Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.spaceBetween,
                        //                 children: [
                        //                   const Text(
                        //                     "Products",
                        //                     style: TextStyle(
                        //                         color: Colors.white, fontSize: 14),
                        //                   ),
                        //                   InkWell(
                        //                     onTap: () {
                        //                       showSalesDialog(context, controller);
                        //                       setState(() {});
                        //                     },
                        //                     child: const Icon(
                        //                       Icons.add,
                        //                       color: Colors.white,
                        //                       size: 18,
                        //                     ),
                        //                   )
                        //                 ],
                        //               ),
                        //             ),
                        //           )
                        //         : const SizedBox.shrink(),

                        vPad20,

                        //////cash item list
                        controller.isCash
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      controller.itemsCashReuturn.isEmpty
                                          ? const SizedBox.shrink()
                                          : Column(
                                              children: List.generate(
                                                  controller.itemsCashReuturn
                                                      .length, (index) {
                                                final item = controller
                                                    .itemsCashReuturn[index];
                                                debugPrint(
                                                    "cash item list ===> $item");
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ],
                                                                color: const Color(
                                                                    0xffe1e5f8),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        // "${item.itemName!} ${item.category!}",
                                                                        item.itemName!,

                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 14),
                                                                      ),

                                                                      //${item.unit}

                                                                      Text(
                                                                        "৳ ${item.mrp!} x ${item.quantity!}   = ${(int.tryParse(item.quantity!) ?? 0) * (double.tryParse(item.mrp!) ?? 0)}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                      hPad2,
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                dialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Remove Item"),
                                                                content:
                                                                    const Text(
                                                                  "Are you sure you want to remove this item?",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          dialogContext); // Close the dialog
                                                                    },
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      controller
                                                                          .removeCashItem(
                                                                              index); // Perform the removal action
                                                                      Navigator.pop(
                                                                          dialogContext); // Close the dialog
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            colorScheme.primary),
                                                                    child:
                                                                        const Text(
                                                                      "Remove",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.cancel,
                                                          color: colorScheme
                                                              .primary,
                                                          size: 18,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),

                                      controller.itemsCashReuturn.isEmpty
                                          ? const SizedBox()
                                          : vPad10,

                                      // controller.itemsCashReuturn.isNotEmpty
                                      //     ? Container(
                                      //         decoration: BoxDecoration(
                                      //           color: colorScheme.primary,
                                      //           borderRadius:
                                      //               BorderRadius.circular(5),
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //               color:
                                      //                   Colors.black.withOpacity(0.2),
                                      //               blurRadius: 5,
                                      //               offset: const Offset(0, 3),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //         child: Padding(
                                      //           padding: const EdgeInsets.all(4.0),
                                      //           child: Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment.spaceBetween,
                                      //             children: [
                                      //               const Text(
                                      //                 "Products",
                                      //                 style: TextStyle(
                                      //                     color: Colors.white,
                                      //                     fontSize: 14),
                                      //               ),
                                      //               InkWell(
                                      //                 onTap: () {
                                      //                   showSalesDialog(
                                      //                       context, controller);
                                      //                   setState(() {});
                                      //                 },
                                      //                 child: const Icon(
                                      //                   Icons.add,
                                      //                   color: Colors.white,
                                      //                   size: 18,
                                      //                 ),
                                      //               )
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       )
                                      //     : const SizedBox.shrink()
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                        ////===> credit item list ///
                        controller.isCash == false
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      controller.itemsCreditReturn.isEmpty
                                          ? const SizedBox.shrink()
                                          : Column(
                                              children: List.generate(
                                                  controller.itemsCreditReturn
                                                      .length, (index) {
                                                final item = controller
                                                    .itemsCreditReturn[index];
                                                debugPrint(
                                                    "item list cash=====>>> $item");
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xffe1e5f8),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        // "${item.itemName!} ${item.category!}",
                                                                        item.itemName!,

                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    "৳ ${item.mrp!} x ${item.quantity!} pc  = ${(int.tryParse(item.quantity!) ?? 0) * (double.tryParse(item.mrp!) ?? 0)}",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                      hPad2,
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                dialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Remove Item"),
                                                                content:
                                                                    const Text(
                                                                  "Are you sure you want to remove this item?",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          dialogContext); // Close the dialog
                                                                    },
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      controller
                                                                          .removeCreditItem(
                                                                              index); // Perform the removal action
                                                                      Navigator.pop(
                                                                          dialogContext); // Close the dialog
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            colorScheme.primary),
                                                                    child:
                                                                        const Text(
                                                                      "Remove",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.cancel,
                                                          color: colorScheme
                                                              .primary,
                                                          size: 18,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                      controller.itemsCreditReturn.isEmpty
                                          ? const SizedBox()
                                          : vPad10,
                                      controller.itemsCreditReturn.isNotEmpty
                                          ? Container(
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
                                                        showSalesDialog(context,
                                                            controller);
                                                        setState(() {});
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
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                        const SizedBox(
                          height: 2,
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
                                              color: Colors.grey.shade400,
                                              width: 1),
                                          bottom: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1),
                                          left: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1),
                                          right: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1)),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Center(
                                      child: TextField(
                                        controller: controller
                                            .purchaseReturnNoteController,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                        onChanged: (value) {
                                          controller
                                              .purchaseReturnNoteController
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

                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FieldPortion(),
                        ),

                        BottomPortionPurchaseReturn(
                          invoiceItems: invoiceItems,
                          saleType: controller.isCash ? "Cash" : "Credit",
                          customerId: controller.isCash
                              ? "Cash"
                              : selectedCustomerId ?? "Cash",
                        )

                        //bottom button portion
                      ],
                    ),
                  ),
                ),

                //BottomPortion(saleType: controller.isCash ? "Cash" : "Credit",),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSalesDialog(
      BuildContext context, PurchaseReturnController controller) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    // Define local state variables
    String? selectedCategoryId;
    String? selectedSubCategoryId;

    //String? selectedItemNameInvoice;
    List<String> unitIdsList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // ✅ Use StatefulBuilder to update UI

          // ✅ Declare invoiceItems here before using it

          return Dialog(
              backgroundColor: Colors.grey.shade400,
              child: Container(
                height: 490,
                decoration: BoxDecoration(
                  color: const Color(0xffe7edf4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
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

                              Expanded(
                                flex: 4,
                                child: categoryProvider.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : CustomDropdownTwo(
                                        hint: 'Select Category',
                                        items: categoryProvider.categories
                                            .map((category) => category.name)
                                            .toList(),
                                        width:
                                            double.infinity, // Adjust as needed
                                        height: 30, // Adjust as needed
                                        // Set the initial value
                                        onChanged: (value) async {
                                          final selectedCategory =
                                              categoryProvider.categories
                                                  .firstWhere((cat) =>
                                                      cat.name == value);

                                          setState(() {
                                            selectedCategoryId =
                                                selectedCategory.id.toString();
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
                                        selectedItem: selectedCategoryId != null
                                            ? categoryProvider.categories
                                                .firstWhere(
                                                  (cat) =>
                                                      cat.id.toString() ==
                                                      selectedCategoryId,
                                                  orElse: () => categoryProvider
                                                      .categories.first,
                                                )
                                                .name
                                            : null,
                                      ),
                              ),
                              const SizedBox(width: 10),

                              /// Subcategory Dropdown
                              Expanded(
                                flex: 4,
                                child: categoryProvider.isSubCategoryLoading
                                    ? const SizedBox()
                                    : categoryProvider.subCategories.isNotEmpty
                                        ? CustomDropdownTwo(
                                            hint: 'Sel Sub Category',
                                            items: categoryProvider
                                                .subCategories
                                                .map((subCategory) =>
                                                    subCategory.name)
                                                .toList(),
                                            width: double
                                                .infinity, // Adjust as needed
                                            height: 30, // Adjust as needed
                                            onChanged: (value) {
                                              final selectedSubCategory =
                                                  categoryProvider.subCategories
                                                      .firstWhere((subCat) =>
                                                          subCat.name == value);

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
                                                selectedSubCategoryId != null
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
                                          )
                                        : const Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "No subcategories available",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13),
                                            ),
                                          ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          // Item Dropdown
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: CustomDropdownTwo(
                                  hint: 'Choose an item',
                                  items: itemProvider.items
                                      .map((item) => item.name)
                                      .toList(),
                                  width: double.infinity,
                                  height: 30,
                                  selectedItem: controller.seletedItemName,
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

                                      // Fetch stock quantity based on selected item
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

                                    // Update the unitIdsList population logic to handle null values properly

                                    // Safely handle the unitId and secondaryUnitId as Strings, using toString() to avoid errors
                                    if (selected.unitId != null &&
                                        selected.unitId != '') {
                                      final unit =
                                          unitProvider.units.firstWhere(
                                        (unit) {
                                          // Ensure that unit.id is treated as a String for comparison
                                          debugPrint(
                                              "Checking unit id: ${unit.id} against selected.unitId: ${selected.unitId?.toString()}");
                                          return unit.id.toString() ==
                                              selected.unitId
                                                  ?.toString(); // Convert to String
                                        },
                                        orElse: () => Unit(
                                            id: 0,
                                            name: 'Unknown Unit',
                                            symbol: '',
                                            status: 0), // Default Unit
                                      );
                                      if (unit.id != 0) {
                                        unitIdsList.add(unit
                                            .name); // Add valid primary unit to list
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
                                          // Ensure that unit.id is treated as a String for comparison
                                          debugPrint(
                                              "Checking unit id: ${unit.id} against selected.secondaryUnitId: ${selected.secondaryUnitId?.toString()}");
                                          return unit.id.toString() ==
                                              selected.secondaryUnitId
                                                  ?.toString(); // Convert to String
                                        },
                                        orElse: () => Unit(
                                            id: 0,
                                            name: 'Unknown Unit',
                                            symbol: '',
                                            status: 0), // Default Unit
                                      );
                                      if (secondaryUnit.id != 0) {
                                        unitIdsList.add(secondaryUnit
                                            .name); // Add valid secondary unit to list
                                      } else {
                                        debugPrint("Secondary unit not found.");
                                      }
                                    }

                                    if (unitIdsList.isEmpty) {
                                      debugPrint(
                                          "No valid units found for this item.");
                                    } else {
                                      debugPrint(
                                          "Units Available: $unitIdsList"); // Check both units are added
                                    }
                                  },
                                ),
                              );
                            }),
                          ),

                          Consumer<AddItemProvider>(
                            builder: (context, stockProvider, child) {
                              //controller.mrpController.text = stockProvider.stockData!.price.toString();
                              if (stockProvider.stockData != null) {
                                controller.mrpController.text =
                                    stockProvider.stockData!.price.toString();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "   Stock Available: ${stockProvider.stockData!.stocks} (${stockProvider.stockData!.unitStocks}) - ৳ ${stockProvider.stockData!.price} ",
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

                          // Unit Dropdown
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: CustomDropdownTwo(
                              hint: 'Choose a unit',
                              items: unitIdsList,
                              width: double.infinity,
                              height: 30,
                              selectedItem: unitIdsList.isNotEmpty
                                  ? unitIdsList.first
                                  : null,
                              onChanged: (selectedUnit) {
                                debugPrint("Selected Unit: $selectedUnit");

                                controller.selectedUnit = selectedUnit;

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
                                    keyboardType: TextInputType.number,
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
                                    keyboardType: TextInputType.number,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () async {
                            debugPrint("Add Item");

                            setState(() {
                              controller.isCash
                                  ? controller.addCashItem()
                                  : controller.addCreditItem();
                              controller.addAmount();
                            });

                            setState(() {});

                            Provider.of<PurchaseReturnController>(context,
                                    listen: false)
                                .notifyListeners();

                            controller.mrpController.clear();
                            controller.qtyController.clear();

                            await Future.delayed(
                                const Duration(milliseconds: 300));

                            setState(() {});

                            // debugPrint(controller.items.length.toString());
                            Navigator.pop(context);
                          },
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.primary,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 2),
                                child: Text(
                                  "Add Item",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              )),
                        ),
                      ),
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
