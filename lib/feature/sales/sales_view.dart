import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/item_dropdown_custom.dart';
import 'package:cbook_dt/feature/customer_create/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/invoice/invoice_model.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/item_category.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/settings/ui/bill_invoice_create_form.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../common/give_information_dialog.dart';
import '../../common/input_field.dart';
import '../../utils/custom_padding.dart';
import 'controller/sales_controller.dart';
import 'widget/add_sales_formfield.dart';
import 'layer/bttom_portion.dart';
part 'layer/field_portion.dart';
part 'layer/give_information.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  SalesViewState createState() => SalesViewState();
}

class SalesViewState extends State<SalesView> {
  // TextEditingController for managing the text field content

  late TextEditingController customerController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<ItemCategoryProvider>(context, listen: false)
            .fetchCategories());

    Provider.of<AddItemProvider>(context, listen: false).fetchItems();

    customerController = TextEditingController();
  }

  @override
  void dispose() {
    customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesController(),
      builder: (context, child) => const _Layout(),
    );
  }
}

class _Layout extends StatefulWidget {
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> {
  TextEditingController customerNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  TextEditingController searchController = TextEditingController();
  TextEditingController billController = TextEditingController();

  String? selectedItem;

  Customer? selectedCustomerObject;

  // String? selectedCustomer;
  // int? selectedCategoryId;
  int? selectedSubCategoryId;

  String? selectedCustomer;
  String? selectedCustomerId;

  // String? selectedCustomerId;

  String? selectedItemNameInvoice;

  // dynamic? qty;
  // dynamic? unit;
  // dynamic? price;

  List<String> unitIdsList = [];

  List<double> amount = [];

  bool showNoteField = false;

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<SalesController>();

    // ✅ Define invoiceItems before using it in BottomPortion
    List<InvoiceItem> invoiceItems = controller.itemsCash.map((item) {
      return InvoiceItem(
        itemName: item.itemName ?? "",
        unit: "N/A", // You might need to update this logic
        quantity: int.tryParse(item.quantity ?? "0") ?? 0,
        amount: (int.tryParse(item.quantity ?? "0") ?? 0) *
            (double.tryParse(item.mrp ?? "0") ?? 0.0),
      );
    }).toList();

    ///XY
    ///
    ///

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
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              leading: InkWell(
                onTap: () {
                  Provider.of<CustomerProvider>(context, listen: false)
                      .clearSelectedCustomer();
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: colorScheme.surface,
                ),
              ),
              centerTitle: true,
              title: Text(
                "Sales Invoiced",
                style: GoogleFonts.lato(
                  color: Colors
                      .yellow, //style: TextStyle(color: Colors.yellow, fontSize: 16)
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BillInvoiceCreateForm()));
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ))
              ],
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                controller.updateCash(context);

                                                // Clear customer selection
                                                // Provider.of<CustomerProvider>(
                                                //         context,
                                                //         listen: false)
                                                //     .clearSelectedCustomer();

                                                Provider.of<CustomerProvider>(
                                                        context,
                                                        listen: false)
                                                    .clearSelectedCustomer();
                                              },
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        controller.isCash
                                                            ? "Cash"
                                                            : "Credit",
                                                        style: GoogleFonts.lato(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
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

                                            ///bill to
                                            const Text(
                                              "Bill To",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  //fontWeight: FontWeight.bold,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),

                                        ////customer or supplier name, phone, address show
                                        // controller.isCash
                                        //     ? const SizedBox.shrink()
                                        //     : Consumer<CustomerProvider>(
                                        //         builder: (context,
                                        //             customerProvider, child) {
                                        //           final selectedCustomer =
                                        //               customerProvider
                                        //                   .selectedCustomer;

                                        //           if (selectedCustomer == null ||
                                        //               selectedCustomer.id == -1) {
                                        //             return const SizedBox(); // return nothing if no customer selected
                                        //           }

                                        //           return Padding(
                                        //             padding:
                                        //                 const EdgeInsets.only(
                                        //                     bottom: 8.0),
                                        //             child: Column(
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment
                                        //                       .start,
                                        //               mainAxisAlignment:
                                        //                   MainAxisAlignment
                                        //                       .center,
                                        //               children: [
                                        //                 Text(
                                        //                   selectedCustomer.name,
                                        //                   style: const TextStyle(
                                        //                     fontSize: 10,
                                        //                     color: Colors.black,
                                        //                     fontWeight:
                                        //                         FontWeight.bold,
                                        //                     overflow: TextOverflow
                                        //                         .ellipsis,
                                        //                   ),
                                        //                 ),
                                        //                 Text(
                                        //                   selectedCustomer
                                        //                           .phone ??
                                        //                       '',
                                        //                   style: const TextStyle(
                                        //                     fontSize: 10,
                                        //                     color: Colors.black,
                                        //                     fontWeight:
                                        //                         FontWeight.bold,
                                        //                     overflow: TextOverflow
                                        //                         .ellipsis,
                                        //                   ),
                                        //                 ),
                                        //                 SizedBox(
                                        //                   width: 180,
                                        //                   child: Text(
                                        //                     selectedCustomer
                                        //                             .address ??
                                        //                         '',
                                        //                     maxLines: 1,
                                        //                     overflow: TextOverflow
                                        //                         .ellipsis,
                                        //                     style:
                                        //                         const TextStyle(
                                        //                       fontSize: 10,
                                        //                       color: Colors.black,
                                        //                       fontWeight:
                                        //                           FontWeight.bold,
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ],
                                        //             ),
                                        //           );
                                        //         },
                                        //       ),
                                      ],
                                    ),

                                    // const Text(
                                    //   "Bill To",
                                    //   style: TextStyle(
                                    //       color: Colors.black,
                                    //       //fontWeight: FontWeight.bold,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontSize: 12),
                                    // ),

                                    // controller.isCash
                                    //     ? const SizedBox.shrink()
                                    //     :
                                    const Text(
                                      "Customer",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 53,
                                          width: 180,
                                          // Adjusted height for cursor visibility
                                          child: controller.isCash
                                              ? InkWell(
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
                                                  child: const Text(
                                                    "Cash",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ))

                                              // TextField(
                                              //     readOnly: true,
                                              //     enableInteractiveSelection:
                                              //         true,
                                              //     onTap: () {
                                              //       showDialog(
                                              //         context: context,
                                              //         builder: (context) =>
                                              //             Dialog(
                                              //           child: ReusableForm(
                                              //             nameController:
                                              //                 nameController,
                                              //             phoneController:
                                              //                 phoneController,
                                              //             emailController:
                                              //                 emailController,
                                              //             addressController:
                                              //                 addressController,
                                              //             primaryColor:
                                              //                 Theme.of(context)
                                              //                     .primaryColor,
                                              //             onCancel: _onCancel,
                                              //             onSubmit: () {
                                              //               setState(() {
                                              //                 controller
                                              //                     .updatedCustomerInfomation(
                                              //                   nameFrom:
                                              //                       nameController
                                              //                           .text,
                                              //                   phoneFrom:
                                              //                       phoneController
                                              //                           .text,
                                              //                   emailFrom:
                                              //                       emailController
                                              //                           .text,
                                              //                   addressFrom:
                                              //                       addressController
                                              //                           .text,
                                              //                 );
                                              //               });
                                              //               Navigator.pop(
                                              //                   context);
                                              //             },
                                              //           ),
                                              //         ),
                                              //       );
                                              //     },

                                              //     ////cash blue .

                                              //     controller: controller
                                              //         .controller, // Managing text field content
                                              //     //enabled: false,
                                              //     style: const TextStyle(
                                              //         color: Colors.blue,
                                              //         fontWeight:
                                              //             FontWeight.w600,
                                              //         fontSize: 12),
                                              //     decoration: InputDecoration(
                                              //       //filled: true,
                                              //       fillColor: Colors.white,
                                              //       border:
                                              //           UnderlineInputBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 0),
                                              //         borderSide: BorderSide(
                                              //           color: Colors.white
                                              //               .withOpacity(0.2),
                                              //           width: 1,
                                              //         ),
                                              //       ),
                                              //       enabledBorder:
                                              //           UnderlineInputBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 0),
                                              //         borderSide: BorderSide(
                                              //           color: Colors.white
                                              //               .withOpacity(0.2),
                                              //           width: 1,
                                              //         ),
                                              //       ),
                                              //       focusedBorder:
                                              //           UnderlineInputBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 0),
                                              //         borderSide: BorderSide(
                                              //           color: Colors.white
                                              //               .withOpacity(0.2),
                                              //           width: 1,
                                              //         ),
                                              //       ),
                                              //       contentPadding:
                                              //           const EdgeInsets
                                              //               .symmetric(
                                              //         vertical: 12,
                                              //         horizontal: 2,
                                              //       ),
                                              //     ),
                                              //     cursorHeight:
                                              //         12, // Adjusted cursor height
                                              //     cursorWidth:
                                              //         2, // Adjusted cursor width for visibility
                                              //   )
                                              :

                                              /////this is working.
                                              // Consumer<CustomerProvider>(
                                              //     builder: (context,
                                              //         customerProvider, child) {
                                              //       if (customerProvider
                                              //           .isLoading) {
                                              //         return const Center(
                                              //             child:
                                              //                 CircularProgressIndicator());
                                              //       }

                                              //       if (customerProvider
                                              //           .errorMessage
                                              //           .isNotEmpty) {
                                              //         return Center(
                                              //           child: Text(
                                              //             customerProvider
                                              //                 .errorMessage,
                                              //             style: const TextStyle(
                                              //                 color: Colors.red,
                                              //                 fontSize: 16),
                                              //           ),
                                              //         );
                                              //       }

                                              //       final customerList =
                                              //           customerProvider
                                              //                   .customerResponse
                                              //                   ?.data ??
                                              //               [];

                                              //       if (customerList.isEmpty) {
                                              //         return const Center(
                                              //           child: Text(
                                              //             "No Customer Found",
                                              //             style: TextStyle(
                                              //                 fontSize: 10,
                                              //                 fontWeight:
                                              //                     FontWeight
                                              //                         .w500),
                                              //           ),
                                              //         );
                                              //       }

                                              //       // ✅ Map customer ID & Name
                                              //       final dropdownItems = customerList
                                              //           .map(
                                              //             (customer) =>
                                              //                 "${customer.name}",
                                              //           ) //${customer.id}// Store both ID and Name //${customer.id}
                                              //           .toList();

                                              //       return Column(
                                              //         crossAxisAlignment:
                                              //             CrossAxisAlignment
                                              //                 .start,
                                              //         children: [
                                              //           ////===> customer dropdown theree
                                              //           CustomDropdownThree(
                                              //             addCustomerOrSupplier:
                                              //                 "Add New Customer",
                                              //             onTap: () {
                                              //               {
                                              //                 Navigator.push(
                                              //                   context,
                                              //                   MaterialPageRoute(
                                              //                     builder:
                                              //                         (context) =>
                                              //                             const CustomerCreate(),
                                              //                   ),
                                              //                 );
                                              //               }
                                              //             },
                                              //             items: dropdownItems,
                                              //             hint: "Select Customer",
                                              //             width: 350,
                                              //             height: 25,

                                              //             selectedItem:
                                              //                 selectedCustomer, // Set initially selected item
                                              //             onChanged: (value) {
                                              //               setState(() {
                                              //                 selectedCustomer =
                                              //                     value;
                                              //                 if (selectedCustomer !=
                                              //                     null) {
                                              //                   selectedCustomerObject =
                                              //                       customerList
                                              //                           .firstWhere(
                                              //                     (customer) =>
                                              //                         customer
                                              //                             .name ==
                                              //                         selectedCustomer,
                                              //                     orElse: () =>
                                              //                         Customer(
                                              //                       id: -1,
                                              //                       userId: 0,
                                              //                       name: '',
                                              //                       proprietorName:
                                              //                           '',
                                              //                       due: 0,
                                              //                       purchases: [],
                                              //                     ),
                                              //                   );

                                              //                   selectedCustomerId =
                                              //                       selectedCustomerObject!
                                              //                           .id
                                              //                           .toString();

                                              //                   // ✅ Update AddItemProvider with selected customer ID
                                              //                   Provider.of<AddItemProvider>(
                                              //                           context,
                                              //                           listen:
                                              //                               false)
                                              //                       .setSelectedCustomerId(
                                              //                           selectedCustomerId!);

                                              //                   final selected =
                                              //                       customerList
                                              //                           .firstWhere(
                                              //                     (customer) =>
                                              //                         customer
                                              //                             .name ==
                                              //                         selectedCustomer,
                                              //                     orElse: () => Customer(
                                              //                         id: -1,
                                              //                         userId: 0,
                                              //                         name: '',
                                              //                         proprietorName:
                                              //                             '',
                                              //                         due: 0,
                                              //                         purchases: []),
                                              //                   );

                                              //                   selectedCustomerObject =
                                              //                       selected;
                                              //                   selectedCustomerId =
                                              //                       selected.id
                                              //                           .toString();

                                              //                   Provider.of<CustomerProvider>(
                                              //                           context,
                                              //                           listen:
                                              //                               false)
                                              //                       .setSelectedCustomer(
                                              //                           selected);
                                              //                 }
                                              //               });

                                              //               debugPrint(
                                              //                   "Selected Customer ID: $selectedCustomerId"); // Debugging
                                              //             },
                                              //           ),

                                              //           // Show the due amount of the selected customer
                                              //           if (selectedCustomerObject !=
                                              //                   null &&
                                              //               selectedCustomerObject!
                                              //                       .id !=
                                              //                   -1)
                                              //             Column(
                                              //               mainAxisAlignment:
                                              //                   MainAxisAlignment
                                              //                       .start,
                                              //               crossAxisAlignment:
                                              //                   CrossAxisAlignment
                                              //                       .start,
                                              //               children: [
                                              //                 Row(
                                              //                   mainAxisAlignment:
                                              //                       MainAxisAlignment
                                              //                           .start,
                                              //                   crossAxisAlignment:
                                              //                       CrossAxisAlignment
                                              //                           .start,
                                              //                   children: [
                                              //                     Text(
                                              //                       "${selectedCustomerObject!.type == 'customer' ? 'Receivable' : 'Payable'}:",
                                              //                       style:
                                              //                           TextStyle(
                                              //                         fontSize:
                                              //                             10,
                                              //                         color: selectedCustomerObject!.type ==
                                              //                                 'customer'
                                              //                             ? Colors
                                              //                                 .green
                                              //                             : Colors
                                              //                                 .red,
                                              //                         fontWeight:
                                              //                             FontWeight
                                              //                                 .bold,
                                              //                         overflow:
                                              //                             TextOverflow
                                              //                                 .ellipsis,
                                              //                       ),
                                              //                     ),
                                              //                     const SizedBox(
                                              //                       width: 2,
                                              //                     ),
                                              //                     Text(
                                              //                       "৳ ${selectedCustomerObject!.due.toStringAsFixed(2)}",
                                              //                       style:
                                              //                           const TextStyle(
                                              //                         fontSize:
                                              //                             10,
                                              //                         color: Colors
                                              //                             .black,
                                              //                         fontWeight:
                                              //                             FontWeight
                                              //                                 .bold,
                                              //                         overflow:
                                              //                             TextOverflow
                                              //                                 .ellipsis,
                                              //                       ),
                                              //                     ),
                                              //                   ],
                                              //                 ),
                                              //               ],
                                              //             ),
                                              //         ],
                                              //       );
                                              //     },
                                              //   ),

                                              // AddSalesFormfield(
                                              //     controller:
                                              //         TextEditingController(),
                                              //     label: "Customer",
                                              //     onChanged: (value) {},
                                              //   ),

                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ///show text field search ====>
                                                    AddSalesFormfieldTwo(
                                                      controller: controller
                                                          .customerNameController,
                                                      customerorSaleslist:
                                                          "Showing Customer list",
                                                      customerOrSupplierButtonLavel:
                                                          "Add customer",
                                                      color: Colors.grey,
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const CustomerCreate()));
                                                      },
                                                      //label: "Customer",
                                                    ),

                                                    /// show bottom payable or recivedable.
                                                    Consumer<CustomerProvider>(
                                                      builder: (context,
                                                          customerProvider,
                                                          child) {
                                                        final customerList =
                                                            customerProvider
                                                                    .customerResponse
                                                                    ?.data ??
                                                                [];

                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // If the customer list is empty, show a SizedBox
                                                            if (customerList
                                                                .isEmpty)
                                                              const SizedBox(
                                                                  height:
                                                                      2), // Adjust height as needed

                                                            // Otherwise, show the dropdown with customers
                                                            if (customerList
                                                                .isNotEmpty)

                                                              // Check if the selected customer is valid
                                                              if (customerProvider
                                                                          .selectedCustomer !=
                                                                      null &&
                                                                  customerProvider
                                                                          .selectedCustomer!
                                                                          .id !=
                                                                      -1)
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: customerProvider.selectedCustomer!.type ==
                                                                                'customer'
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              2.0),
                                                                      child:
                                                                          Text(
                                                                        "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
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

                                          /////its wotking with customdropdown 4
                                          // Consumer<CustomerProvider>(
                                          //     builder: (context,
                                          //         customerProvider, child) {
                                          //       final customerList =
                                          //           customerProvider
                                          //                   .customerResponse
                                          //                   ?.data ??
                                          //               [];

                                          //       return Column(
                                          //         crossAxisAlignment:
                                          //             CrossAxisAlignment
                                          //                 .start,
                                          //         children: [
                                          //           // If the customer list is empty, show a SizedBox
                                          //           if (customerList
                                          //               .isEmpty)
                                          //             const SizedBox(
                                          //                 height:
                                          //                     2), // Adjust height as needed

                                          //           // Otherwise, show the dropdown with customers
                                          //           if (customerList
                                          //               .isNotEmpty)
                                          //             CustomDropdownFour(
                                          //               items: customerList,
                                          //               hint:
                                          //                   "Select Customer",
                                          //               width: 350,
                                          //               height: 25,
                                          //               selectedItem:
                                          //                   customerProvider
                                          //                       .selectedCustomer,
                                          //               addCustomerOrSupplier:
                                          //                   "Add New Customer",
                                          //               onTap: () {
                                          //                 Navigator.push(
                                          //                     context,
                                          //                     MaterialPageRoute(
                                          //                       builder:
                                          //                           (context) =>
                                          //                               const CustomerCreate(),
                                          //                     ));
                                          //               },
                                          //               onChanged: (Customer
                                          //                   selected) {
                                          //                 customerProvider
                                          //                     .setSelectedCustomer(
                                          //                         selected);
                                          //               },
                                          //             ),

                                          //           // Check if the selected customer is valid
                                          //           if (customerProvider
                                          //                       .selectedCustomer !=
                                          //                   null &&
                                          //               customerProvider
                                          //                       .selectedCustomer!
                                          //                       .id !=
                                          //                   -1)
                                          //             Column(
                                          //               crossAxisAlignment:
                                          //                   CrossAxisAlignment
                                          //                       .start,
                                          //               children: [
                                          //                 Text(
                                          //                   "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
                                          //                   style:
                                          //                       TextStyle(
                                          //                     fontSize: 10,
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .bold,
                                          //                     color: customerProvider
                                          //                                 .selectedCustomer!.type ==
                                          //                             'customer'
                                          //                         ? Colors
                                          //                             .green
                                          //                         : Colors
                                          //                             .red,
                                          //                   ),
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //         ],
                                          //       );
                                          //     },
                                          //   ),
                                        ),
                                      ],
                                    ),

                                    // const SizedBox(
                                    //   height: 5,
                                    // ),
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
                                                      fontSize: 12)),
                                              Text("Phone: ${controller.phone}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                              Text("Email: ${controller.email}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                              Text(
                                                  "Address: ${controller.address}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //bill person
                                    SizedBox(
                                      height: 30,
                                      width: 90,
                                      child: TextField(
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                        controller: controller.billPerson,
                                        cursorHeight:
                                            12, // Match cursor height to text size
                                        decoration: InputDecoration(
                                          isDense:
                                              true, // Ensures the field is compact
                                          contentPadding: EdgeInsets
                                              .zero, // Removes unnecessary padding
                                          hintText: "Bill Person",
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
                                    // Bill No Field

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    ///bill no, bill person
                                    SizedBox(
                                      height: 30,
                                      width: 90,
                                      child: TextField(
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                        controller: controller.billController,
                                        cursorHeight:
                                            12, // Match cursor height to text size
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

                                    //person

                                    ///bill date
                                    SizedBox(
                                      height: 30,
                                      width: 90,
                                      child: InkWell(
                                        onTap: () => controller.pickDate(
                                            context), // Trigger the date picker
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            isDense: true,
                                            suffixIcon: Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            suffixIconConstraints:
                                                const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ), // Adjust constraints to align icon closely
                                            hintText: "Bill Date",
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 9,
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 0.5),
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.green),
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

                                    // Bill Time Field
                                    // SizedBox(
                                    //   height: 30,
                                    //   width: 90,
                                    //   child: InkWell(
                                    //     onTap: () =>
                                    //         controller.pickTime(context),
                                    //     child: InputDecorator(
                                    //       decoration: InputDecoration(
                                    //         suffixIconConstraints:
                                    //             const BoxConstraints(
                                    //           minWidth: 16,
                                    //           minHeight: 16,
                                    //         ),
                                    //         isDense: true,
                                    //         suffixIcon: Icon(
                                    //           Icons.timer,
                                    //           size: 16,
                                    //           color: Theme.of(context)
                                    //               .primaryColor,
                                    //         ),
                                    //         hintText: "Bill Time",
                                    //         hintStyle: TextStyle(
                                    //             color: Colors.grey.shade400,
                                    //             fontSize: 10),
                                    //         enabledBorder: UnderlineInputBorder(
                                    //           borderSide: BorderSide(
                                    //               color: Colors.grey.shade400,
                                    //               width: 0.5),
                                    //         ),
                                    //         focusedBorder:
                                    //             const UnderlineInputBorder(
                                    //           borderSide: BorderSide(
                                    //               color: Colors.green),
                                    //         ),
                                    //       ),
                                    //       child: Text(
                                    //         controller.formattedTime,
                                    //         style: const TextStyle(
                                    //             color: Colors.black,
                                    //             fontSize: 12),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          vPad10,
                          controller.isCash
                              ? controller.itemsCash.isEmpty
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {});
                                        showSalesDialog(context, controller);
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Add item & service",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
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
                                      ),
                                    )
                                  : const SizedBox.shrink()
                              : controller.itemsCredit.isEmpty
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {});
                                        showSalesDialog(context, controller);
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Add item & service",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  // setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  // setState(() {});
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

                          vPad20,

                          ///// cash product =====
                          controller.isCash
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        controller.itemsCash.isEmpty
                                            ? const SizedBox.shrink()
                                            : Column(
                                               
                                                children: List.generate(
                                                    controller.itemsCash.length,
                                                    (index) {
                                                  final item = controller
                                                      .itemsCash[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    child: Row(
                                                    
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            ///cash item list edit.
                                                            onTap: () {
                                                              setState(() {});

                                                              showCashItemDetailsDialog(
                                                                  context,
                                                                  item);

                                                              //showSalesDialog(context, controller);
                                                              setState(() {});
                                                            },
                                                            child:
                                                                //cash item list show, index, itam name, unit, qty, and total price
                                                                SizedBox(
                                                              height: 42,
                                                              child:
                                                                  DecoratedBox(
                                                                decoration: BoxDecoration(
                                                                    //border: Border.all(color: Colors.grey),
                                                                    //   boxShadow: [
                                                                    // BoxShadow(
                                                                    //   color: Colors
                                                                    //       .black
                                                                    //       .withOpacity(
                                                                    //           0.1),
                                                                    //   blurRadius:
                                                                    //       1,
                                                                    //   offset:
                                                                    //       const Offset(
                                                                    //           0,
                                                                    //           1),
                                                                    // ),
                                                                    //],
                                                                    color: const Color(0xfff4f6ff), //f4f6ff

                                                                    ///f4f6ff, dddefa
                                                                    borderRadius: BorderRadius.circular(5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          2,
                                                                      vertical:
                                                                          2),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center, // <--- Center vertically
                                                                      children: [
                                                                        /// Left Side: Index + Item Info
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                                 
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center, // <--- Center vertically
                                                                            children: [
                                                                              
                                                                               
                                                                              Text(
                                                                                "${index + 1}.",
                                                                                style: const TextStyle(
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 10,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 5),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    const SizedBox(height: 4,
                                                                                    ),
                                                                                    Text(
                                                                                      item.itemName!,
                                                                                      style: const TextStyle(
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        color: Colors.black,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontSize: 10,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ${item.total}",
                                                                                      style: const TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 9,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),

                                                                        /// Right Side: Close Button
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext dialogContext) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Remove Item"),
                                                                                  content: const Text(
                                                                                    "Are you sure you want to remove this item?",
                                                                                    style: TextStyle(color: Colors.black),
                                                                                  ),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(dialogContext);
                                                                                      },
                                                                                      child: const Text("Cancel"),
                                                                                    ),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        controller.removeCashItem(index);
                                                                                        Navigator.pop(dialogContext);
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: colorScheme.primary,
                                                                                      ),
                                                                                      child: const Text(
                                                                                        "Remove",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                            setState(() {});
                                                                          },
                                                                          child:
                                                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade500,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                             
                                            ),
                                            child: const Icon(Icons.remove,
                                                color: Colors.green, size: 18),
                                          ),
                                                                          //     const CircleAvatar(
                                                                          //   radius:
                                                                          //       12,
                                                                          //   backgroundColor:
                                                                          //       Colors.grey,
                                                                          //   child:
                                                                          //       Icon(
                                                                          //     Icons.close,
                                                                          //     color: Colors.white,
                                                                          //     size: 20,
                                                                          //   ),
                                                                          // ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                        controller.itemsCash.isEmpty
                                            ? const SizedBox()
                                            : vPad10,
                                        controller.itemsCash.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 5,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          "Add item & service",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {});
                                                            showSalesDialog(
                                                                context,
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
                                                ),
                                              )
                                            : const SizedBox.shrink()
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),

                          //// credit ====>
                          controller.isCash == false
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        controller.itemsCredit.isEmpty
                                            ? const SizedBox.shrink()
                                            : Column(
                                                children: List.generate(
                                                    controller.itemsCredit
                                                        .length, (index) {
                                                  final item = controller
                                                      .itemsCredit[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 3),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              setState(() {});
                                                              showSalesDialog(
                                                                  context,
                                                                  controller);
                                                              setState(() {});
                                                            },
                                                            child: DecoratedBox(
                                                              decoration: BoxDecoration(
                                                                  //border: Border.all(color: Colors.grey),
                                                                  //     boxShadow: [
                                                                  //   BoxShadow(
                                                                  //     color: Colors
                                                                  //         .black
                                                                  //         .withOpacity(
                                                                  //             0.1),
                                                                  //     blurRadius:
                                                                  //         1,
                                                                  //     offset:
                                                                  //         const Offset(
                                                                  //             0,
                                                                  //             1),
                                                                  //   ),
                                                                  // ],
                                                                  color: const Color(0xfff4f6ff), //f4f6ff

                                                                  ///f4f6ff, dddefa
                                                                  borderRadius: BorderRadius.circular(5)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2,
                                                                    vertical:
                                                                        2),
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center, // <--- Center vertically
                                                                    children: [
                                                                      /// Left Side: Index + Item Info
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center, // <--- Center vertically
                                                                          children: [
                                                                            Text(
                                                                              "${index + 1}. ",
                                                                              style: const TextStyle(
                                                                                overflow: TextOverflow.ellipsis,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    item.itemName!,
                                                                                    style: const TextStyle(
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 11,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    "৳ ${item.mrp!} x ${item.quantity!} ${item.unit} = ${item.total}",
                                                                                    style: const TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: 9,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),

                                                                      /// Right Side: Close Button
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext dialogContext) {
                                                                              return AlertDialog(
                                                                                title: const Text("Remove Item"),
                                                                                content: const Text(
                                                                                  "Are you sure you want to remove this item?",
                                                                                  style: TextStyle(color: Colors.black),
                                                                                ),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(dialogContext);
                                                                                    },
                                                                                    child: const Text("Cancel"),
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      //controller.removeCashItem(index);
                                                                                      controller.removeCreditItem(index);
                                                                                      Navigator.pop(dialogContext);
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: colorScheme.primary,
                                                                                    ),
                                                                                    child: const Text(
                                                                                      "Remove",
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        child:
                                                                            const CircleAvatar(
                                                                          radius:
                                                                              12,
                                                                          backgroundColor:
                                                                              Colors.grey,
                                                                          child:
                                                                              Icon(
                                                                            Icons.close,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          // DecoratedBox(
                                                          //   decoration: BoxDecoration(
                                                          //       color: const Color(
                                                          //           0xffe1e5f8),
                                                          //       borderRadius:
                                                          //           BorderRadius
                                                          //               .circular(
                                                          //                   5)),
                                                          //   child: Padding(
                                                          //     padding:
                                                          //         const EdgeInsets
                                                          //             .all(3),
                                                          //     child: Row(
                                                          //       crossAxisAlignment:
                                                          //           CrossAxisAlignment
                                                          //               .start,
                                                          //       mainAxisAlignment:
                                                          //           MainAxisAlignment
                                                          //               .spaceBetween,
                                                          //       children: [
                                                          //         Column(
                                                          //           crossAxisAlignment:
                                                          //               CrossAxisAlignment
                                                          //                   .start,
                                                          //           children: [
                                                          //             SizedBox(
                                                          //               width:
                                                          //                   180,
                                                          //               child:
                                                          //                   Column(
                                                          //                 mainAxisAlignment:
                                                          //                     MainAxisAlignment.start,
                                                          //                 crossAxisAlignment:
                                                          //                     CrossAxisAlignment.start,
                                                          //                 children: [
                                                          //                   Text(
                                                          //                     // "${item.itemName!} ${item.category!}",
                                                          //                     //item.itemName!,
                                                          //                     "${index + 1}. ${item.itemName!}",

                                                          //                     style: const TextStyle(overflow: TextOverflow.ellipsis, color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                                          //                   ),
                                                          //                 ],
                                                          //               ),
                                                          //             ),
                                                          //           ],
                                                          //         ),
                                                          //         Text(
                                                          //           //"৳ ${item.mrp!} x ${item.quantity!} ${item.unit}  = ${(int.tryParse(item.quantity!) ?? 0) * (double.tryParse(item.mrp!) ?? 0)}",
                                                          //           "৳ ${item.mrp!} x ${item.quantity!} ${item.unit}  =  ${item.total}",
                                                          //           style:
                                                          //               const TextStyle(
                                                          //             color: Colors
                                                          //                 .black,
                                                          //             fontSize:
                                                          //                 14,
                                                          //             fontWeight:
                                                          //                 FontWeight.bold,
                                                          //           ),
                                                          //         ),
                                                          //       ],
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          //   ),
                                                          // ),
                                                          // hPad2,
                                                          // InkWell(
                                                          //   onTap: () {
                                                          //     showDialog(
                                                          //       context: context,
                                                          //       builder: (BuildContext
                                                          //           dialogContext) {
                                                          //         return AlertDialog(
                                                          //           title: const Text(
                                                          //               "Remove Item"),
                                                          //           content:
                                                          //               const Text(
                                                          //             "Are you sure you want to remove this item?",
                                                          //             style: TextStyle(
                                                          //                 color: Colors
                                                          //                     .black),
                                                          //           ),
                                                          //           actions: [
                                                          //             TextButton(
                                                          //               onPressed:
                                                          //                   () {
                                                          //                 Navigator.pop(
                                                          //                     dialogContext); // Close the dialog
                                                          //               },
                                                          //               child: const Text(
                                                          //                   "Cancel"),
                                                          //             ),
                                                          //             ElevatedButton(
                                                          //               onPressed:
                                                          //                   () {
                                                          //                 controller
                                                          //                     .removeCreditItem(index); // Perform the removal action
                                                          //                 Navigator.pop(
                                                          //                     dialogContext); // Close the dialog
                                                          //               },
                                                          //               style: ElevatedButton.styleFrom(
                                                          //                   backgroundColor:
                                                          //                       colorScheme.primary),
                                                          //               child:
                                                          //                   const Text(
                                                          //                 "Remove",
                                                          //                 style: TextStyle(
                                                          //                     color:
                                                          //                         Colors.white),
                                                          //               ),
                                                          //             ),
                                                          //           ],
                                                          //         );
                                                          //       },
                                                          //     );
                                                          //     setState(() {});
                                                          //   },
                                                          //   child: Icon(
                                                          //     Icons.cancel,
                                                          //     color: colorScheme
                                                          //         .primary,
                                                          //     size: 18,
                                                          //   ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                        controller.itemsCredit.isEmpty
                                            ? const SizedBox()
                                            : vPad10,
                                        controller.itemsCredit.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {});
                                                  showSalesDialog(
                                                      context, controller);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 5,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          "Add items & service",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {});
                                                            showSalesDialog(
                                                                context,
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
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),

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
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Center(
                                        child: TextField(
                                          controller:
                                              controller.saleNoteController,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
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

                          //bottom button portion

                          const FieldPortion(),
                        ],
                      ),
                    ),
                  ),
                  vPad20,
                  BottomPortion(
                    invoiceItems: invoiceItems,
                    saleType: controller.isCash ? "Cash" : "Credit",
                    customerId: controller.isCash
                        ? "Cash"
                        : selectedCustomerId ?? "Cash",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///===>>>sales item picked.

  void showSalesDialog(BuildContext context, SalesController controller) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);

    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    final controller = Provider.of<SalesController>(context, listen: false);

    final TextEditingController itemController = TextEditingController();

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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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

                              ///===>>> Category and Subcategory Row

                              // Row(
                              //   //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     ///===>>> Category Dropdown

                              //     Column(
                              //       mainAxisAlignment: MainAxisAlignment.start,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [
                              //         const Text(
                              //           "Category",
                              //           style: TextStyle(
                              //               color: Colors.black, fontSize: 14),
                              //         ),
                              //         SizedBox(
                              //           height: 30,
                              //           //width: 150,
                              //           child: categoryProvider.isLoading
                              //               ? const Center(
                              //                   child:
                              //                       CircularProgressIndicator())
                              //               : CustomDropdownTwo(
                              //                   hint: '', //Select Category
                              //                   items: categoryProvider
                              //                       .categories
                              //                       .map((category) =>
                              //                           category.name)
                              //                       .toList(),
                              //                   width: 150, // Adjust as needed
                              //                   height: 30, // Adjust as needed
                              //                   // Set the initial value
                              //                   onChanged: (value) async {
                              //                     final selectedCategory =
                              //                         categoryProvider
                              //                             .categories
                              //                             .firstWhere((cat) =>
                              //                                 cat.name ==
                              //                                 value);

                              //                     setState(() {
                              //                       selectedCategoryId =
                              //                           selectedCategory.id
                              //                               .toString();
                              //                       selectedSubCategoryId =
                              //                           null; // Reset subcategory
                              //                     });

                              //                     // Fetch subcategories & update UI when done
                              //                     await categoryProvider
                              //                         .fetchSubCategories(
                              //                             selectedCategory.id);
                              //                     setState(() {});
                              //                   },
                              //                   // Set the initial item (if selectedCategoryId is not null)
                              //                   selectedItem:
                              //                       selectedCategoryId != null
                              //                           ? categoryProvider
                              //                               .categories
                              //                               .firstWhere(
                              //                                 (cat) =>
                              //                                     cat.id
                              //                                         .toString() ==
                              //                                     selectedCategoryId,
                              //                                 orElse: () =>
                              //                                     categoryProvider
                              //                                         .categories
                              //                                         .first,
                              //                               )
                              //                               .name
                              //                           : null,
                              //                 ),
                              //         ),
                              //       ],
                              //     ),
                              //     //const SizedBox(width: 10),

                              //     ///===>sub category dropdown
                              //     Column(
                              //       mainAxisAlignment: MainAxisAlignment.start,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [
                              //         /// Subcategory Dropdown
                              //         categoryProvider.isSubCategoryLoading
                              //             ? const SizedBox()
                              //             : categoryProvider
                              //                     .subCategories.isNotEmpty
                              //                 ? Column(
                              //                     mainAxisAlignment:
                              //                         MainAxisAlignment.start,
                              //                     crossAxisAlignment:
                              //                         CrossAxisAlignment.start,
                              //                     children: [
                              //                       const Text(
                              //                         "Sub category",
                              //                         style: TextStyle(
                              //                             color: Colors.black,
                              //                             fontSize: 14),
                              //                       ),
                              //                       CustomDropdownTwo(
                              //                         hint:
                              //                             '', //Sel Sub Category
                              //                         items: categoryProvider
                              //                             .subCategories
                              //                             .map((subCategory) =>
                              //                                 subCategory.name)
                              //                             .toList(),
                              //                         width:
                              //                             150, // Adjust as needed
                              //                         height:
                              //                             30, // Adjust as needed
                              //                         onChanged: (value) {
                              //                           final selectedSubCategory =
                              //                               categoryProvider
                              //                                   .subCategories
                              //                                   .firstWhere(
                              //                                       (subCat) =>
                              //                                           subCat
                              //                                               .name ==
                              //                                           value);

                              //                           setState(() {
                              //                             selectedSubCategoryId =
                              //                                 selectedSubCategory
                              //                                     .id
                              //                                     .toString();
                              //                           });

                              //                           debugPrint(
                              //                               "Selected Sub Category ID: ${selectedSubCategory.id}");
                              //                         },
                              //                         // Set the initial item (if selectedSubCategoryId is not null)
                              //                         selectedItem:
                              //                             selectedSubCategoryId !=
                              //                                     null
                              //                                 ? categoryProvider
                              //                                     .subCategories
                              //                                     .firstWhere(
                              //                                       (sub) =>
                              //                                           sub.id
                              //                                               .toString() ==
                              //                                           selectedSubCategoryId,
                              //                                       orElse: () =>
                              //                                           categoryProvider
                              //                                               .subCategories
                              //                                               .first,
                              //                                     )
                              //                                     .name
                              //                                 : null,
                              //                       ),
                              //                     ],
                              //                   )
                              //                 : const Align(
                              //                     alignment: Alignment.topLeft,
                              //                     child: Text(
                              //                       "", //No subcategories
                              //                       style: TextStyle(
                              //                           color: Colors.black,
                              //                           fontSize: 12),
                              //                     ),
                              //                   ),
                              //       ],
                              //     ),
                              //   ],
                              // ),

                              // const SizedBox(
                              //   height: 5,
                              // ),

                              // Item Dropdown old

                              // const Align(
                              //   alignment: Alignment.centerLeft,
                              //   child: Text(
                              //     "Item",
                              //     style: TextStyle(
                              //         color: Colors.black, fontSize: 14),
                              //   ),
                              // ),

                              ///===>>>old item dropdown
                              // SizedBox(
                              //   height: 30,
                              //   child: Consumer<AddItemProvider>(
                              //     builder: (context, itemProvider, child) {
                              //       if (itemProvider.isLoading) {
                              //         return const Center(
                              //             child: CircularProgressIndicator());
                              //       }

                              //       if (itemProvider.items.isEmpty) {
                              //         return const Center(
                              //           child: Text(
                              //             'No items available.',
                              //             style: TextStyle(color: Colors.black),
                              //           ),
                              //         );
                              //       }

                              //       return CustomDropdownTwo(
                              //         hint: '', // Choose an item
                              //         items: itemProvider.items
                              //             .map((item) => item.name)
                              //             .toList(),
                              //         width: double.infinity,
                              //         height: 30,
                              //         selectedItem: controller.seletedItemName,
                              //         onChanged: (selectedItemName) async {
                              //           setState(() {
                              //             controller.seletedItemName =
                              //                 selectedItemName; // Update controller's selectedItemName
                              //             itemProvider.items.forEach((e) {
                              //               if (selectedItemName == e.name) {
                              //                 controller.selcetedItemId =
                              //                     e.id.toString();
                              //               }
                              //             });

                              //             // Fetch stock quantity based on selected item
                              //             if (controller.selcetedItemId !=
                              //                 null) {
                              //               fetchStockQuantity
                              //                   .fetchStockQuantity(
                              //                       controller.selcetedItemId!);
                              //             }
                              //           });

                              //           // Find the selected item
                              //           final selected =
                              //               itemProvider.items.firstWhere(
                              //             (item) =>
                              //                 item.name == selectedItemName,
                              //             orElse: () =>
                              //                 itemProvider.items.first,
                              //           );

                              //           // Ensure unitProvider is loaded
                              //           if (unitProvider.units.isEmpty) {
                              //             await unitProvider
                              //                 .fetchUnits(); // Ensure units are fetched
                              //           }

                              //           // Update unit dropdown list based on selected item
                              //           unitIdsList.clear();

                              //           // Debugging: Print unitId and secondaryUnitId for comparison
                              //           print(
                              //               "Selected item unitId: ${selected.unitId}");
                              //           print(
                              //               "Selected item secondaryUnitId: ${selected.secondaryUnitId}");

                              //           // Update the unitIdsList population logic to handle null values properly

                              //           // Clear previous units
                              //           unitIdsList.clear();

                              //           // Base unit
                              //           if (selected.unitId != null &&
                              //               selected.unitId != '') {
                              //             final unit =
                              //                 unitProvider.units.firstWhere(
                              //               (unit) =>
                              //                   unit.id.toString() ==
                              //                   selected.unitId.toString(),
                              //               orElse: () => Unit(
                              //                   id: 0,
                              //                   name: 'Unknown Unit',
                              //                   symbol: '',
                              //                   status: 0),
                              //             );
                              //             if (unit.id != 0) {
                              //               unitIdsList.add(unit
                              //                   .name); // ✅ Use full name (e.g., Pces)
                              //               controller.selectedUnit = unit.name;

                              //               // Create the final unit string for the selected unit
                              //               String finalUnitString =
                              //                   "${unit.id}_${unit.name}_1"; // Default to qty=1
                              //               controller
                              //                   .selectedUnitIdWithNameFunction(
                              //                       finalUnitString);
                              //             }
                              //           }

                              //           // Secondary unit
                              //           if (selected.secondaryUnitId != null &&
                              //               selected.secondaryUnitId != '') {
                              //             final secondaryUnit =
                              //                 unitProvider.units.firstWhere(
                              //               (unit) =>
                              //                   unit.id.toString() ==
                              //                   selected.secondaryUnitId
                              //                       .toString(),
                              //               orElse: () => Unit(
                              //                   id: 0,
                              //                   name: 'Unknown Unit',
                              //                   symbol: '',
                              //                   status: 0),
                              //             );
                              //             if (secondaryUnit.id != 0) {
                              //               unitIdsList.add(secondaryUnit
                              //                   .name); // ✅ Use full name
                              //             }
                              //           }

                              //           if (unitIdsList.isEmpty) {
                              //             print(
                              //                 "No valid units found for this item.");
                              //           } else {
                              //             print(
                              //                 "Units Available: $unitIdsList"); // Check both units are added
                              //           }

                              //           // ✅ Now trigger UI update
                              //         },
                              //       );
                              //     },
                              //   ),
                              // ),

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

                                    debugPrint(
                                        "Selected item unitId: ${selectedItem.unitId}");
                                    debugPrint(
                                        "Selected item secondaryUnitId: ${selectedItem.secondaryUnitId}");

                                    // Base unit
                                    if (selectedItem.unitId != null &&
                                        selectedItem.unitId != '') {
                                      final unit =
                                          unitProvider.units.firstWhere(
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
                                        controller
                                            .selectedUnitIdWithNameFunction(
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
                                      debugPrint(
                                          "No valid units found for this item.");
                                    } else {
                                      debugPrint("Units Available: $unitIdsList");
                                    }
                                  },
                                ),
                              ),

                              ///===>Stock
                              // Consumer<AddItemProvider>(
                              //   builder: (context, stockProvider, child) {
                              //     //controller.mrpController.text = stockProvider.stockData!.price.toString();
                              //     if (stockProvider.stockData != null) {
                              //       controller.mrpController.text =
                              //           stockProvider.stockData!.price
                              //               .toString();
                              //       return Padding(
                              //         padding: const EdgeInsets.only(top: 8.0),
                              //         child: Align(
                              //           alignment: Alignment.centerLeft,
                              //           child: Text(
                              //             "   Stock Available:  ${stockProvider.stockData!.unitStocks} ৳ ${stockProvider.stockData!.price} ",
                              //             //"   Stock Available: ${stockProvider.stockData!.stocks} (${stockProvider.stockData!.unitStocks}) ৳ ${stockProvider.stockData!.price} ",

                              //             style: const TextStyle(
                              //               fontSize: 10,
                              //               fontWeight: FontWeight.bold,
                              //               color: Colors.black,
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     }
                              //     return const Padding(
                              //       padding: EdgeInsets.only(top: 8.0),
                              //       child: Text(
                              //         "   ", // Updated message for empty stock
                              //         style: TextStyle(
                              //           fontSize: 10,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // ),

                              ///update stock code , for custome price input
                              Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          // const Text(
                                          //   "Unit",
                                          //   style: TextStyle(
                                          //       fontSize: 14, color: Colors.black),
                                          // ),
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
                                                    unitProvider.units
                                                        .firstWhere(
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
                                                    in fetchStockQuantity
                                                        .items) {
                                                  if (item.id.toString() ==
                                                      controller
                                                          .selcetedItemId) {
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
                                                        item.unitId
                                                            .toString()) {
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

                                          // Padding(
                                          //   padding: const EdgeInsets.symmetric(
                                          //       horizontal: 2.0),
                                          //   child: SizedBox(
                                          //     width: 150,
                                          //     child: CustomDropdownTwo(
                                          //       hint: '', // Choose a unit
                                          //       items:
                                          //           unitIdsList, // Now holds unit names, e.g. ["Pces", "Packet"]
                                          //       width: double.infinity,
                                          //       height: 30,
                                          //       selectedItem: controller.selectedUnit,
                                          //       onChanged: (selectedUnit) {
                                          //         print(
                                          //             "Selected Unit: $selectedUnit");

                                          //         controller.selectedUnit =
                                          //             selectedUnit;

                                          //         final selectedUnitObj =
                                          //             unitProvider.units.firstWhere(
                                          //           (unit) =>
                                          //               unit.name == selectedUnit,
                                          //           orElse: () => Unit(
                                          //             id: 0,
                                          //             name: "Unknown Unit",
                                          //             symbol: "",
                                          //             status: 0,
                                          //           ),
                                          //         );

                                          //         debugPrint(
                                          //             "🆔 Selected Unit ID: ${selectedUnitObj.id}_${selectedUnit}");

                                          //         // Handle base and secondary unit selection logic
                                          //         for (var f
                                          //             in fetchStockQuantity.items) {
                                          //           if (f.id.toString() ==
                                          //               controller.selcetedItemId) {
                                          //             for (var e
                                          //                 in unitProvider.units) {
                                          //               if (e.name == selectedUnit) {
                                          //                 String selectedUnitId =
                                          //                     e.id.toString();

                                          //                 if (selectedUnitId ==
                                          //                     f.secondaryUnitId
                                          //                         .toString()) {
                                          //                   controller
                                          //                       .selectedUnitIdWithNameFunction(
                                          //                           "${selectedUnitId}_${selectedUnit}_${f.unitQty}");
                                          //                 } else if (selectedUnitId ==
                                          //                     f.unitId.toString()) {
                                          //                   controller
                                          //                       .selectedUnitIdWithNameFunction(
                                          //                           "${selectedUnitId}_${selectedUnit}_1");
                                          //                 }
                                          //               }
                                          //             }
                                          //           }
                                          //         }

                                          //         // Final fallback update
                                          //         controller
                                          //             .selectedUnitIdWithNameFunction(
                                          //                 "${selectedUnitObj.id}_${selectedUnit}");

                                          //         print(
                                          //             "🆔 Final Unit ID: ${selectedUnitObj.id}_${selectedUnit}");

                                          //         controller.notifyListeners();
                                          //       },
                                          //     ),
                                          //   ),
                                          // ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                // const Text(
                                                //   "Vat/Tax (%)",
                                                //   style: TextStyle(
                                                //       color: Colors.black,
                                                //       fontSize: 13.5),
                                                // ),
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
                                                    selectedItem:
                                                        selectedTaxName,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        selectedTaxName =
                                                            newValue;

                                                        final nameOnly =
                                                            newValue
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
                                                                  .taxList
                                                                  .first,
                                                        );

                                                        selectedTaxId = selected
                                                            .id
                                                            .toString();

                                                        controller
                                                                .selectedTaxPercent =
                                                            double.tryParse(
                                                                selected
                                                                    .percent);

                                                        // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                                        controller.taxPercent =
                                                            controller
                                                                    .selectedTaxPercent ??
                                                                0.0;

                                                        controller
                                                            .updateTaxPaecentId(
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
                                          controller.subtotalWithTax.toStringAsFixed(2),
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
                        // SizedBox(
                        //   height: 10,
                        // ),

                        //const Spacer(),

                        ///add & new , add
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ////add & new
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: () async {
                                    debugPrint("Add & New");

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

                                      Navigator.pop(context);
                                    }

                                    Provider.of<SalesController>(context,
                                            listen: false)
                                        .notifyListeners();

                                    controller.clearFields();

                                    setState(() {
                                      controller.seletedItemName = null;

                                      Provider.of<AddItemProvider>(context,
                                              listen: false)
                                          .clearPurchaseStockDatasale();
                                      controller.mrpController.clear();
                                      controller.qtyController.clear();
                                    });

                                    Provider.of<SalesController>(context,
                                            listen: false)
                                        .notifyListeners();

                                    setState(() {
                                      showSalesDialog(context, controller);
                                    });

                                    // ✅ Clear stock info

                                    // debugPrint(controller.items.length.toString());
                                  },
                                  child: SizedBox(
                                    width: 90,
                                    child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: colorScheme.primary,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 2),
                                          child: Center(
                                            child: Text(
                                              "Add & New",
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
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                      ],
                    ),
                  );
                }));
          });
        });
  }

  ////item edit list ===>
  Future<void> showCashItemDetailsDialog(
    BuildContext context,
    ItemModel selectedItem,
  ) async {
    String? selectedTaxName;
    String? selectedTaxId;

    final priceController = TextEditingController(text: "${selectedItem.mrp}");
    final qtyController =
        TextEditingController(text: "${selectedItem.quantity}");
    final discountController =
        TextEditingController(text: "${selectedItem.discountAmount}");
    final vatController =
        TextEditingController(text: "${selectedItem.vatAmount}");
    final totalController =
        TextEditingController(text: "${selectedItem.total}");

    final addItemProvider =
        Provider.of<AddItemProvider>(context, listen: false);

    final categoryProvider =
        Provider.of<ItemCategoryProvider>(context, listen: false);
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    final fetchStockQuantity =
        Provider.of<AddItemProvider>(context, listen: false);

    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    final controller = Provider.of<SalesController>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          void updateTotal() {
            final price = double.tryParse(priceController.text) ?? 0.0;
            final qty = double.tryParse(qtyController.text) ?? 0.0;
            final total = price * qty;
            totalController.text = total.toStringAsFixed(2);
          }

          void updateTotalDiscount() {
            final price = double.tryParse(priceController.text) ?? 0.0;
            final qty = double.tryParse(qtyController.text) ?? 0.0;

            final discount = double.tryParse(discountController.text) ?? 0.0;

            final totalAfterDiscount = (price * qty) - discount;
            totalController.text = totalAfterDiscount.toStringAsFixed(2);
          }

          final price = double.tryParse(priceController.text) ?? 0.0;
          final qty = double.tryParse(qtyController.text) ?? 0.0;
          final purchaseTotal = price * qty;
          totalController.text = purchaseTotal.toStringAsFixed(2);

          return AlertDialog(
            title: const Text("Item List Edit"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔽 Item Dropdown

                  Row(
                    children: [
                      //item ===
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Item",
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            height: 30,
                            width: 135,
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
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: CustomDropdownTwo(
                                    hint: '', // Choose an item
                                    items: itemProvider.items
                                        .map((item) => item.name)
                                        .toList(),
                                    width: 135,
                                    height: 30,

                                    selectedItem: selectedItem.itemName,
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
                                      unitIdsList.clear();

                                      // Debugging: Print unitId and secondaryUnitId for comparison
                                      debugPrint(
                                          "Selected item unitId: ${selected.unitId}");
                                      debugPrint(
                                          "Selected item secondaryUnitId: ${selected.secondaryUnitId}");

                                      // Update the unitIdsList population logic to handle null values properly

                                      // Clear previous units
                                      unitIdsList.clear();

                                      // Base unit
                                      if (selected.unitId != null &&
                                          selected.unitId != '') {
                                        final unit =
                                            unitProvider.units.firstWhere(
                                          (unit) =>
                                              unit.id.toString() ==
                                              selected.unitId.toString(),
                                          orElse: () => Unit(
                                              id: 0,
                                              name: 'Unknown Unit',
                                              symbol: '',
                                              status: 0),
                                        );
                                        if (unit.id != 0) {
                                          unitIdsList.add(unit
                                              .name); // ✅ Use full name (e.g., Pces)
                                          controller.selectedUnit = unit.name;

                                          // Create the final unit string for the selected unit
                                          String finalUnitString =
                                              "${unit.id}_${unit.name}_1"; // Default to qty=1
                                          controller
                                              .selectedUnitIdWithNameFunction(
                                                  finalUnitString);
                                        }
                                      }

                                      // Secondary unit
                                      if (selected.secondaryUnitId != null &&
                                          selected.secondaryUnitId != '') {
                                        final secondaryUnit =
                                            unitProvider.units.firstWhere(
                                          (unit) =>
                                              unit.id.toString() ==
                                              selected.secondaryUnitId
                                                  .toString(),
                                          orElse: () => Unit(
                                              id: 0,
                                              name: 'Unknown Unit',
                                              symbol: '',
                                              status: 0),
                                        );
                                        if (secondaryUnit.id != 0) {
                                          unitIdsList.add(secondaryUnit
                                              .name); // ✅ Use full name
                                        }
                                      }

                                      if (unitIdsList.isEmpty) {
                                        debugPrint(
                                            "No valid units found for this item.");
                                      } else {
                                        debugPrint(
                                            "Units Available: $unitIdsList"); // Check both units are added
                                      }

                                      // ✅ Now trigger UI update
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      ////===UNit
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Unit:",
                              style: TextStyle(color: Colors.black)),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: SizedBox(
                              width: 135,
                              child: CustomDropdownTwo(
                                hint: '',
                                items:
                                    unitIdsList, // Holds unit names like ["Pces", "Packet"]
                                width: 135,
                                height: 30,
                                selectedItem: selectedItem.unit,
                                onChanged: (selectedUnit) {
                                  print("Selected Unit: $selectedUnit");

                                  // Update the selected unit in controller
                                  controller.selectedUnit = selectedUnit;

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
                                  for (var item in fetchStockQuantity.items) {
                                    if (item.id.toString() ==
                                        controller.selcetedItemId) {
                                      String unitId =
                                          selectedUnitObj.id.toString();
                                      String unitName = selectedUnit;

                                      // Check if selected unit is the primary or secondary unit and set the correct quantity
                                      if (unitId ==
                                          item.secondaryUnitId.toString()) {
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
                                      controller.selectedUnitIdWithNameFunction(
                                          finalUnitString);
                                      break;
                                    }
                                  }

                                  // Fallback if no valid unit string was found
                                  if (finalUnitString.isEmpty) {
                                    finalUnitString =
                                        "${selectedUnitObj.id}_${selectedUnit}_1"; // Default to 1 if no match
                                    controller.selectedUnitIdWithNameFunction(
                                        finalUnitString);
                                  }

                                  // Debug print to show final unit ID selected
                                  debugPrint("🆔 Final Unit ID: $finalUnitString");

                                  // Notify listeners to update the UI
                                  controller.notifyListeners();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  ///stock available
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

                  const SizedBox(height: 10),

                  ///price
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: SizedBox(
                          // width: 100,
                          child: AddSalesFormfield(
                            label: "Price",
                            controller: priceController,
                            onChanged: (value) {
                              selectedItem.mrp = value;

                              // Optionally recalculate total
                              final price = double.tryParse(value) ?? 0.0;
                              //final qty = double.tryParse(selectedItem.quantity) ?? 0.0;

                              selectedItem.mrp = value;
                              updateTotal(); // 🔁 Calculate and update total
                              setState(() {});

                              addItemProvider.notifyListeners();

                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),

                      //qty
                      Expanded(
                        child: SizedBox(
                          //width: 100,
                          child: AddSalesFormfield(
                            label: 'QTY',
                            controller: qtyController,
                            onChanged: (value) {
                              selectedItem.quantity = value;
                              updateTotal();
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: SizedBox(
                              width: 135,
                              child: AddSalesFormfield(
                                label: "Discount (%)",
                                controller: controller.discountPercentance,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  controller.lastChanged = 'percent';
                                  controller.calculateSubtotal();

                                  selectedItem.discountPercentance = value;
                                  updateTotalDiscount(); // Calculate and update total
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      SizedBox(
                        width: 135,
                        child: AddSalesFormfield(
                            label: "Discount AMT",
                            controller: discountController),
                      ),
                    ],
                  ),

                  Row(
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
                                'No tax',
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }
                          return SizedBox(
                            width: 135,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "VAT/TAX (%)",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                CustomDropdownTwo(
                                  hint: 'VAT/TAX',
                                  items: taxProvider.taxList
                                      .map((tax) =>
                                          "${tax.name} - (${tax.percent})")
                                      .toList(),
                                  width: 135,
                                  height: 30,
                                  selectedItem: selectedTaxName,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedTaxName = newValue;

                                      final nameOnly =
                                          newValue?.split(" - ").first;

                                      final selected =
                                          taxProvider.taxList.firstWhere(
                                        (tax) => tax.name == nameOnly,
                                        orElse: () => taxProvider.taxList.first,
                                      );

                                      selectedTaxId = selected.id.toString();

                                      controller.selectedTaxPercent =
                                          double.tryParse(selected.percent);

                                      // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                      controller.taxPercent =
                                          controller.selectedTaxPercent ?? 0.0;

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
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 135,
                        child: AddSalesFormfield(
                            label: "VAT/TAX AMT", controller: vatController),
                      ),
                    ],
                  ),

                  AddSalesFormfield(
                    label: "Total",
                    controller: totalController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  final updatedPrice =
                      double.tryParse(priceController.text) ?? 0.0;
                  final updatedQty = double.tryParse(qtyController.text) ?? 0.0;

                  final updatedDiscount =
                      double.tryParse(discountController.text) ?? 0.0;
                  final updatedVat = double.tryParse(vatController.text) ?? 0.0;

                  final updatedTotal =
                      ((updatedPrice * updatedQty) - updatedDiscount) +
                          updatedVat;

                  final updatedItem = ItemModel(
                    category: selectedItem.category,
                    subCategory: selectedItem.subCategory,
                    itemName: selectedItem.itemName,
                    itemCode: selectedItem.itemCode,
                    mrp: priceController.text,
                    quantity: qtyController.text,
                    total: updatedTotal.toStringAsFixed(2),
                    price: priceController.text,
                    unit: selectedItem.unit,
                    discountAmount: discountController.text,
                    discountPercentance: controller.discountPercentance.text,
                    vatAmount: vatController.text,
                    vatPerentace: controller.taxPercentValue,
                  );

                  setState(() {
                    // 🛠 Replace the existing item in itemsCash
                    final index = controller.itemsCash.indexOf(selectedItem);

                    if (index != -1) {
                      controller.itemsCash[index] = updatedItem;
                    }
                  });

                  debugPrint(
                      '===========>>qty & price=====> ${qtyController.text}, ${priceController.text}');

                  // Update amount calculations

                  ////add new item.
                  // setState(() {
                  //   controller.isCash
                  //       ? controller.addAmount2()
                  //       : controller.addAmount();
                  // });

                  //addItemProvider.notifyListeners();

                  setState(() {});

                  Navigator.pop(context);
                },
                child: const Text("Update"),
              )
            ],
          );
        });
      },
    );
  }
}

class ItemModel {
  String? category;
  String? subCategory;
  String? itemName;
  String? itemCode;
  String? mrp;
  String? quantity;
  String? total;
  String? price;
  String? unit;
  dynamic discountAmount;
  dynamic discountPercentance;
  dynamic vatAmount;
  dynamic vatPerentace;

  ItemModel(
      {this.category,
      this.subCategory,
      this.itemName,
      this.itemCode,
      this.mrp,
      this.quantity,
      this.total,
      this.price,
      this.unit,
      this.discountAmount,
      this.discountPercentance,
      this.vatAmount,
      this.vatPerentace});
}
