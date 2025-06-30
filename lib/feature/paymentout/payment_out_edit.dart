import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/customer_create/model/received_voucher_model.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/model/create_payment_out.dart';
import 'package:cbook_dt/feature/paymentout/payment_out_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymenyOutEdit extends StatefulWidget {
  final String paymentOutId;
  const PaymenyOutEdit({super.key, required this.paymentOutId});

  @override
  State<PaymenyOutEdit> createState() => _PaymenyOutEditState();
}

class _PaymenyOutEditState extends State<PaymenyOutEdit> {
  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  TextEditingController billNoController = TextEditingController();
  String billNo = '';
  String billDate = '';
  TextEditingController discountAmount = TextEditingController();
  TextEditingController paymentAmount = TextEditingController();
  TextEditingController totalAmount = TextEditingController();
  String selectedDiscountType = '%';
  Map<int, TextEditingController> receiptControllers = {};
  BillPersonModel? selectedBillPersonData;
  String? selectedBillPerson;
  int? selectedBillPersonId;
  String? selectedReceivedTo;
  String? selectedAccount;
  int? selectedAccountId;
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String? selectedDropdownValue;
  late TextEditingController voucherNumberController;
  Set<int> expandedIndexes = {};

  final Map<String, String> receivedToMap = {
    'cash': 'Cash in Hand',
    'bank': 'Bank',
  };

  final Map<String, String> reverseReceivedToMap = {
    'Cash in Hand': 'cash',
    'Bank': 'bank',
  };

  /// Calculate sum of all receipts input
  double get totalReceiptAmount {
    double total = 0;
    for (final c in receiptControllers.values) {
      total += double.tryParse(c.text) ?? 0;
    }
    return total;
  }

  /// Called when discount or receipt amounts change
  void _recalculatePayment() {
    double due = totalReceiptAmount; // total receipt entered by user

    final discountText = discountAmount.text.trim();
    double discountValue = double.tryParse(discountText) ?? 0;

    if (due <= 0) {
      paymentAmount.text = "0.00";
      totalAmount.text = "0.00";
      return;
    }

    // Clamp discount value
    if (selectedDiscountType == '%') {
      if (discountValue > 100) discountValue = 100;
    } else {
      if (discountValue > due) discountValue = due;
    }

    double discountAmountCalculated = selectedDiscountType == '%'
        ? (discountValue / 100) * due
        : discountValue;

    double finalPayment = due - discountAmountCalculated;

    if (finalPayment < 0) finalPayment = 0;

    setState(() {
      totalAmount.text = due.toStringAsFixed(2); // show total before discount
      paymentAmount.text = finalPayment.toStringAsFixed(2);
    });

    debugPrint(
      'Total Receipt: $due, Discount: $discountValue $selectedDiscountType, '
      'Discount Amt: $discountAmountCalculated, Final Payment: $finalPayment',
    );
  }

  @override
  void initState() {
    super.initState();

    voucherNumberController = TextEditingController();

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());

    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    Future.microtask(() async {
      final provider =
          Provider.of<PaymentVoucherProvider>(context, listen: false);
      final data = await provider.fetchReceiveVoucherById(widget.paymentOutId);

      if (data != null) {
        setState(() {
          // ✅ Correct field mappings based on API response
          voucherNumberController.text = data['voucher_number'] ?? '';

          // ✅ Map received_to correctly using the existing mapping
          selectedReceivedTo = receivedToMap[data['received_to']] ?? '';

          // ✅ bill_person_id mapping
          selectedBillPersonId = data['bill_person_id'];

          // ✅ account_type mapping
          selectedAccountId = data['account_type'];

          // ✅ Handle null discount_type from API
          selectedDiscountType = data['discount_type'] ?? '%';

          // ✅ Use discount_amount from API
          discountAmount.text = (data['discount_amount'] ?? 0).toString();

          // ✅ Use total_amount from API
          totalAmount.text = (data['total_amount'] ?? 0).toString();

          // ✅ Date mapping
          selectedStartDate =
              DateTime.tryParse(data['voucher_date']) ?? DateTime.now();
          selectedEndDate =
              DateTime.tryParse(data['voucher_date']) ?? DateTime.now();

          // ✅ Set customer_id if available
          if (data['customer_id'] != null) {
            _setSelectedCustomer(data['customer_id']);
          }

          // ✅ Fill voucher details list - CORRECTED spelling
          if (data['voucher_detaiuls'] is List) {
            final List details = data['voucher_detaiuls'];
            receiptControllers.clear(); // Clear existing controllers

            for (int i = 0; i < details.length; i++) {
              final item = details[i];
              final controller =
                  TextEditingController(text: (item['amount'] ?? 0).toString());
              receiptControllers[i] = controller;

              // Add listener to recalculate when amount changes
              controller.addListener(() {
                _recalculatePayment();
              });
            }
          }

          debugPrint('Received To: $selectedReceivedTo');
          debugPrint('Bill Person ID: $selectedBillPersonId');
          debugPrint('Account ID: $selectedAccountId');
          debugPrint('Customer ID: ${data['customer_id']}');
        });

        // ✅ MOVED THESE OUTSIDE setState - Load account dropdown AFTER state is set
        await _loadAccountDropdown();

        // ✅ Set bill person if ID is available
        _setBillPerson();

        // ✅ Recalculate after everything is loaded
        _recalculatePayment();
      }
    });
  }

// Helper method to load account dropdown based on received_to
  Future<void> _loadAccountDropdown() async {
    final provider = Provider.of<IncomeProvider>(context, listen: false);

    debugPrint('Loading accounts for: $selectedReceivedTo');

    if (selectedReceivedTo == 'Cash in Hand') {
      await provider.fetchAccounts('cash');
    } else if (selectedReceivedTo == 'Bank') {
      await provider.fetchAccounts('bank');
    }

    // Wait a bit for the provider to update
    await Future.delayed(Duration(milliseconds: 100));

    // Set selected account after loading
    if (selectedAccountId != null && provider.accountModel != null) {
      try {
        final account = provider.accountModel!.data.firstWhere(
          (acc) => acc.id == selectedAccountId,
        );

        setState(() {
          selectedAccount = account.accountName;
        });

        debugPrint('Successfully set account: ${account.accountName}');
      } catch (e) {
        debugPrint('Account not found with ID: $selectedAccountId');
        // If account not found, set to first available account
        if (provider.accountModel!.data.isNotEmpty) {
          setState(() {
            selectedAccount = provider.accountModel!.data.first.accountName;
          });
        }
      }
    }
  }

// Helper method to set bill person
  void _setBillPerson() {
    if (selectedBillPersonId != null) {
      final provider =
          Provider.of<PaymentVoucherProvider>(context, listen: false);

      // You might need to wait for bill persons to load first
      Future.delayed(Duration(milliseconds: 500), () {
        if (provider.billPersons.isNotEmpty) {
          try {
            final billPerson = provider.billPersons.firstWhere(
              (person) => person.id == selectedBillPersonId,
            );
            setState(() {
              selectedBillPerson = billPerson.name;
              selectedBillPersonData = billPerson;
            });
            debugPrint('Successfully set bill person: ${billPerson.name}');
          } catch (e) {
            debugPrint('Bill person not found with ID: $selectedBillPersonId');
          }
        }
      });
    }
  }

// Helper method to set selected customer
  void _setSelectedCustomer(int customerId) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    // Wait for customers to load then set the selected one
    Future.delayed(Duration(milliseconds: 500), () {
      if (customerProvider.customerResponse?.data != null) {
        final customer = customerProvider.findCustomerById(customerId);

        if (customer != null) {
          // Set the customer in the provider
          customerProvider.setSelectedCustomer(
              customer); // Note: different method for payment

          // Update the controller text
          final controller =
              Provider.of<SalesController>(context, listen: false);
          controller.customerNameController.text = customer.name;

          debugPrint('Successfully set customer: ${customer.name}');
        } else {
          debugPrint('Customer not found with ID: $customerId');
        }
      }
    });
  }

// Updated dispose method to dispose all controllers
  @override
  void dispose() {
    voucherNumberController.dispose();
    discountAmount.dispose();
    paymentAmount.dispose();
    totalAmount.dispose();

    // Dispose all receipt controllers
    for (final controller in receiptControllers.values) {
      controller.dispose();
    }
    receiptControllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    //final provider = Provider.of<IncomeProvider>(context);
    final provider = context.watch<IncomeProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    final providerExpense = Provider.of<ExpenseProvider>(context, listen: true);

    TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

    // List of forms with metadata

    // ✅ Show loading indicator while data is fetching

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Column(
          children: [
            SizedBox(
              width: 5,
            ),
            Text(
              'Payment out Update',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 5,
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ///1 section

          const SizedBox(
            height: 6,
          ),

          ///1 section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: CustomDropdownTwo(
                      hint: '',
                      items: const ['Cash in Hand', 'Bank'],
                      width: double.infinity,
                      height: 30,
                      labelText: 'Receipt To',
                      selectedItem: selectedReceivedTo,
                      onChanged: (value) async {
                        debugPrint('=== Received To Selected: $value ===');

                        setState(() {
                          selectedReceivedTo = value;
                          selectedAccount = null;
                        });

                        final type = reverseReceivedToMap[value ?? ''] ?? '';

                        if (type == 'cash') {
                          await provider.fetchAccounts('cash');
                        } else if (type == 'bank') {
                          await provider.fetchAccounts('bank');
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Account Dropdown
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: provider.isAccountLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomDropdownTwo(
                            hint: '',
                            items: provider.accountNames,
                            width: double.infinity,
                            height: 30,
                            labelText: 'A/C',
                            selectedItem: selectedAccount,
                            onChanged: (value) {
                              debugPrint('=== Account Selected: $value ===');
                              setState(() {
                                selectedAccount = value;
                              });

                              if (provider.accountModel != null) {
                                final selectedAccountData = provider
                                    .accountModel!.data
                                    .firstWhere((account) =>
                                        account.accountName == value);

                                selectedAccountId = selectedAccountData.id;

                                debugPrint('=== Account Selected: $value ===');
                                if (selectedAccountId != null) {
                                  debugPrint(
                                      'Selected Account ID: $selectedAccountId');
                                }

                                debugPrint('Selected Account Details:');
                                debugPrint('- ID: ${selectedAccountData.id}');
                                debugPrint(
                                    '- Name: ${selectedAccountData.accountName}');
                                debugPrint('- Type: $selectedReceivedTo');
                              }
                            },
                          ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Consumer<PaymentVoucherProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 30,
                          width: 130,
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomDropdownTwo(
                                  hint: '',
                                  items: provider.billPersonNames,
                                  width: double.infinity,
                                  height: 30,
                                  labelText: 'Bill Person',
                                  selectedItem: selectedBillPerson,
                                  onChanged: (value) {
                                    debugPrint(
                                        '=== Bill Person Selected: $value ===');
                                    setState(() {
                                      selectedBillPerson = value;
                                      selectedBillPersonData =
                                          provider.billPersons.firstWhere(
                                        (person) => person.name == value,
                                      ); // ✅ Save the whole object globally
                                      selectedBillPersonId =
                                          selectedBillPersonData!.id;
                                    });

                                    debugPrint('Selected Bill Person Details:');
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

                  // Bill No Field

                  const SizedBox(
                    height: 8,
                  ),

                  ///bill no, bill person
                  SizedBox(
                    height: 30,
                    width: 130,
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      controller: voucherNumberController, //billNoController,
                      cursorHeight: 12,
                      onChanged: (value) {
                        billNo = value;
                      }, // Match cursor height to text size
                      decoration: InputDecoration(
                        isDense: true, // Ensures the field is compact
                        contentPadding:
                            EdgeInsets.zero, // Removes unnecessary padding
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
                        focusedBorder: const UnderlineInputBorder(
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
                    width: 130,
                    child: InkWell(
                      // onTap: () => controller.pickDate(
                      //     context), // Trigger the date picker
                      child: InputDecorator(
                        decoration: InputDecoration(
                          isDense: true,
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          suffixIconConstraints: const BoxConstraints(
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
                                color: Colors.grey.shade400, width: 0.5),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
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
                ],
              )
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          ///2 section
          InkWell(
            onTap: () async {},
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Received From",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// Customer input field for payment vouchers
          AddSalesFormfieldTwo(
            controller: controller.customerNameController,
            customerorSaleslist: "Showing Customer list",
            customerOrSupplierButtonLavel: "",
            color: Colors.grey,
            isForReceivedVoucher: false, // ❗ Set to false for payment
            onTap: () async {
              // Call customerProvider.setSelectedCustomerPayment(customer)
            },
          ),

          Consumer<CustomerProvider>(
            builder: (context, customerProvider, child) {
              final paymentList = customerProvider.paymentVouchers;

              return SizedBox(
                height: 300,
                child: paymentList.isEmpty
                    ? const Center(
                        child: Text(
                          "No payment voucher found.",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: paymentList.length,
                        itemBuilder: (context, index) {
                          final invoice = paymentList[index];
                          final bool isExpanded =
                              expandedIndexes.contains(index);
                          final due =
                              double.tryParse(invoice.due.toString()) ?? 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 2),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      expandedIndexes.remove(index);
                                    } else {
                                      expandedIndexes.add(index);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Top Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(invoice.billNumber ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          Text(invoice.purchaseDate ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          Text(
                                              'Bill ৳${invoice.grossTotal ?? 0}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          Text('Due ৳${invoice.due ?? 0}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          Icon(
                                            isExpanded
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            size: 28,
                                          ),
                                        ],
                                      ),

                                      if (isExpanded) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text('Payment',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              height: 30,
                                              width: 150,
                                              child: TextFormField(
                                                controller: receiptControllers[
                                                        index] ??=
                                                    TextEditingController(),
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  final input =
                                                      double.tryParse(value) ??
                                                          0;

                                                  if (input > due) {
                                                    receiptControllers[index]!
                                                            .text =
                                                        due.toStringAsFixed(2);
                                                    receiptControllers[index]!
                                                            .selection =
                                                        TextSelection.fromPosition(
                                                            TextPosition(
                                                                offset: receiptControllers[
                                                                        index]!
                                                                    .text
                                                                    .length));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Amount can’t exceed due: ৳${due.toStringAsFixed(2)}'),
                                                        backgroundColor:
                                                            Colors.red,
                                                        duration:
                                                            const Duration(
                                                                seconds: 2),
                                                      ),
                                                    );
                                                  }

                                                  _recalculatePayment();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),

          /// Show customer payable/receivable for payment
          // Consumer<CustomerProvider>(
          //   builder: (context, customerProvider, child) {
          //     final customerList =
          //         customerProvider.customerResponse?.data ?? [];
          //     final selectedCustomerPayment =
          //         customerProvider.selectedCustomerPayment;

          //     return Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         if (customerList.isEmpty) const SizedBox(height: 2),
          //         if (customerList.isNotEmpty &&
          //             selectedCustomerPayment != null &&
          //             selectedCustomerPayment.id != -1) ...[
          //           Row(
          //             children: [
          //               Text(
          //                 "${selectedCustomerPayment.type == 'customer' ? 'Payable' : 'Receivable'}: ",
          //                 style: TextStyle(
          //                   fontSize: 10,
          //                   fontWeight: FontWeight.bold,
          //                   color: selectedCustomerPayment.type == 'customer'
          //                       ? Colors.red
          //                       : Colors.green,
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 2.0),
          //                 child: Text(
          //                   "৳ ${selectedCustomerPayment.due.toStringAsFixed(2)}",
          //                   style: const TextStyle(
          //                     fontSize: 10,
          //                     fontWeight: FontWeight.bold,
          //                     color: Colors.black,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           const SizedBox(height: 8),
          //           SizedBox(
          //             height: 300,
          //             child: customerProvider.paymentVouchers.isEmpty
          //                 ? const Center(
          //                     child: Text(
          //                       "No payment voucher found.",
          //                       style: TextStyle(
          //                           fontSize: 15,
          //                           color: Colors.black,
          //                           fontWeight: FontWeight.bold),
          //                     ),
          //                   )
          //                 : ListView.builder(
          //                     itemCount:
          //                         customerProvider.paymentVouchers.length,
          //                     itemBuilder: (context, index) {
          //                       final invoice =
          //                           customerProvider.paymentVouchers[index];
          //                       final bool isExpanded =
          //                           expandedIndexes.contains(index);

          //                       print(
          //                           "Tapped Payment Voucher ID: ${invoice.id}");

          //                       return Padding(
          //                         padding: const EdgeInsets.symmetric(
          //                             horizontal: 2, vertical: 1),
          //                         child: Card(
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(3),
          //                           ),
          //                           elevation: 1,
          //                           margin: const EdgeInsets.only(bottom: 2),
          //                           child: InkWell(
          //                             onTap: () {
          //                               setState(() {
          //                                 if (isExpanded) {
          //                                   expandedIndexes.remove(index);
          //                                 } else {
          //                                   expandedIndexes.add(index);
          //                                 }
          //                               });
          //                             },
          //                             child: Padding(
          //                               padding: const EdgeInsets.symmetric(
          //                                   horizontal: 6.0, vertical: 6.0),
          //                               child: Column(
          //                                 crossAxisAlignment:
          //                                     CrossAxisAlignment.start,
          //                                 children: [
          //                                   /// Top Row
          //                                   Row(
          //                                     mainAxisAlignment:
          //                                         MainAxisAlignment
          //                                             .spaceBetween,
          //                                     children: [
          //                                       Text(invoice.billNumber ?? '',
          //                                           style: const TextStyle(
          //                                               fontSize: 14,
          //                                               color: Colors.black)),
          //                                       Text(invoice.voucherDate ?? '',
          //                                           style: const TextStyle(
          //                                               fontSize: 14,
          //                                               color: Colors.black)),
          //                                       Text(
          //                                           'Total ৳${invoice.grossTotal ?? "0"}',
          //                                           style: const TextStyle(
          //                                               fontSize: 14,
          //                                               color: Colors.black)),
          //                                       Text(
          //                                           'Due ৳${invoice.due ?? "0"}',
          //                                           style: const TextStyle(
          //                                               fontSize: 14,
          //                                               color: Colors.black)),
          //                                       Icon(
          //                                         isExpanded
          //                                             ? Icons.arrow_drop_up
          //                                             : Icons.arrow_drop_down,
          //                                         size: 28,
          //                                       ),
          //                                     ],
          //                                   ),

          //                                   if (isExpanded) ...[
          //                                     const SizedBox(height: 8),
          //                                     Row(
          //                                       mainAxisAlignment:
          //                                           MainAxisAlignment.end,
          //                                       children: [
          //                                         const Text('Payment',
          //                                             style: TextStyle(
          //                                                 fontSize: 14,
          //                                                 color: Colors.black)),
          //                                         const SizedBox(width: 10),
          //                                         SizedBox(
          //                                           height: 30,
          //                                           width: 150,
          //                                           child: TextFormField(
          //                                             controller:
          //                                                 receiptControllers[
          //                                                         index] ??=
          //                                                     TextEditingController(),
          //                                             keyboardType:
          //                                                 const TextInputType
          //                                                     .numberWithOptions(
          //                                                     decimal: true),
          //                                             style: const TextStyle(
          //                                               fontSize: 14,
          //                                               color: Colors.black,
          //                                             ),
          //                                             decoration:
          //                                                 InputDecoration(
          //                                               contentPadding:
          //                                                   const EdgeInsets
          //                                                       .symmetric(
          //                                                       horizontal: 10),
          //                                               border:
          //                                                   OutlineInputBorder(
          //                                                 borderRadius:
          //                                                     BorderRadius
          //                                                         .circular(4),
          //                                               ),
          //                                             ),
          //                                             onChanged: (value) {
          //                                               final input =
          //                                                   double.tryParse(
          //                                                           value) ??
          //                                                       0;
          //                                               // final due =
          //                                               //     double.tryParse(invoice.due ??
          //                                               //         "0") ??
          //                                               //         0;

          //                                               final due = double
          //                                                       .tryParse(invoice
          //                                                           .due
          //                                                           .toString()) ??
          //                                                   0;

          //                                               if (input > due) {
          //                                                 receiptControllers[
          //                                                             index]!
          //                                                         .text =
          //                                                     due.toStringAsFixed(
          //                                                         2);
          //                                                 receiptControllers[
          //                                                             index]!
          //                                                         .selection =
          //                                                     TextSelection
          //                                                         .fromPosition(
          //                                                   TextPosition(
          //                                                     offset:
          //                                                         receiptControllers[
          //                                                                 index]!
          //                                                             .text
          //                                                             .length,
          //                                                   ),
          //                                                 );
          //                                                 ScaffoldMessenger.of(
          //                                                         context)
          //                                                     .showSnackBar(
          //                                                   SnackBar(
          //                                                     content: Text(
          //                                                         'Amount can’t exceed due: ৳${due.toStringAsFixed(2)}'),
          //                                                     backgroundColor:
          //                                                         Colors.red,
          //                                                     duration:
          //                                                         const Duration(
          //                                                             seconds:
          //                                                                 2),
          //                                                   ),
          //                                                 );
          //                                               }

          //                                               /// Recalculate total
          //                                               double total = 0;
          //                                               for (final controller
          //                                                   in receiptControllers
          //                                                       .values) {
          //                                                 total += double.tryParse(
          //                                                         controller
          //                                                             .text) ??
          //                                                     0;
          //                                               }
          //                                               totalAmount.text = total
          //                                                   .toStringAsFixed(2);

          //                                               _recalculatePayment();
          //                                             },
          //                                           ),
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ]
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                       );
          //                     },
          //                   ),
          //           ),
          //         ],
          //       ],
          //     );
          //   },
          // ),

          const Spacer(),

          ///total amount
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // 🔥 Right align labels + fields
              children: [
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Total Amount", style: ts),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        readOnly: true,
                        controller: totalAmount,
                        onChanged: (value) {
                          debugPrint('Payment Value: ${totalAmount.text}');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Discount row with % dropdown and text field
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Discount", style: ts),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: CustomDropdownTwo(
                        hint: '',
                        items: const ['%', '৳'],
                        width: double.infinity,
                        height: 30,
                        labelText: selectedDiscountType,
                        selectedItem: selectedDiscountType,
                        onChanged: (value) {
                          setState(() {
                            selectedDiscountType = value ?? '%';
                            _recalculatePayment();
                          });
                          debugPrint(
                              'Discount type selected: $selectedDiscountType');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    ///discount amount
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: AddSalesFormfield(
                        keyboardType: TextInputType.number,
                        controller: discountAmount,
                        onChanged: (value) {
                          _recalculatePayment();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Payment", style: ts),
                    const SizedBox(width: 24),
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        controller: paymentAmount,
                        readOnly:
                            true, // user should not edit final payment manually
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userIdStr = prefs.getInt('user_id')?.toString();

                    if (userIdStr == null) {
                      debugPrint("User ID is null");
                      return;
                    }

                    final selectedCustomer =
                        Provider.of<CustomerProvider>(context, listen: false)
                            .selectedCustomer;
                    if (selectedCustomer == null) {
                      debugPrint('No customer selected.');
                      return;
                    }

                    String voucherId = widget.paymentOutId;
                    int userId = int.parse(userIdStr);
                    int customerId = selectedCustomer.id;
                    int voucherPerson = selectedBillPersonData?.id ?? 0;
                    String voucherNumber = voucherNumberController.text.trim();
                    String voucherDate =
                        DateFormat('yyyy-MM-dd').format(selectedStartDate);
                    String voucherTime =
                        DateFormat('HH:mm:ss').format(DateTime.now());

                    String paymentForm =
                        reverseReceivedToMap[selectedReceivedTo] ?? "cash";
                    int accountId = selectedAccountId ?? 0;
                    int paymentTo = customerId;
                    String percent = selectedDiscountType ?? "%";
                    double totalAmt = double.tryParse(totalAmount.text) ?? 0;
                    double paymentAmt =
                        double.tryParse(paymentAmount.text) ?? 0;
                    double discountAmt =
                        double.tryParse(discountAmount.text) ?? 0;
                    String notes = 'Updated payment voucher';

                    List<VoucherItem> voucherItems = [];

                    // ✅ Create the request object using the correct model
                    final request = PaymentVoucherRequest(
                      userId: userId,
                      customerId: customerId,
                      voucherPerson: voucherPerson,
                      voucherNumber: voucherNumber,
                      voucherDate: voucherDate,
                      voucherTime: voucherTime,
                      paymentForm: (selectedReceivedTo ?? "cash")
                          .toLowerCase(), // ✅ FIXED paymentForm,
                      accountId: accountId,
                      paymentTo: paymentTo,
                      percent: percent,
                      totalAmount: paymentAmt, //totalAmt,
                      discount: discountAmt,
                      notes: notes,
                      voucherItems: voucherItems,
                    );

                    final provider = Provider.of<PaymentVoucherProvider>(
                        context,
                        listen: false);
                    bool success =
                        await provider.updatePaymentVoucher(voucherId, request);

                    if (success) {
                      Provider.of<CustomerProvider>(context, listen: false)
                          .clearSelectedCustomer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Payment voucher updated successfully!",
                                style: TextStyle(color: Colors.green))),
                      );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentOutList()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Failed to update payment voucher.")),
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              ),
            ],
          ),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               /// Total Amount Section
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5)),
//                     backgroundColor: Colors.green, // Button background color
//                     foregroundColor: Colors.white, // Button text color
//                   ),
//                   onPressed: () async {
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     String? userIdStr = prefs.getInt('user_id')?.toString();

//                     if (userIdStr == null) {
//                       debugPrint("User ID is null");
//                       return;
//                     }

//                     final selectedCustomer = Provider.of<CustomerProvider>(
//                             context,
//                             listen: false)
//                         .selectedCustomer; // ✅ Changed from selectedCustomerPayment

//                     if (selectedCustomer == null) {
//                       debugPrint('No customer selected.');
//                       return;
//                     }

//                     // ✅ Use the actual voucher ID from widget parameter
//                     String voucherId = widget
//                         .paymentOutId; // ✅ Use the ID passed to this screen

//                     int userId = int.parse(userIdStr);
//                     int customerId = selectedCustomer.id;
//                     int voucherPerson = selectedBillPersonData?.id ?? 0;
//                     String voucherNumber = voucherNumberController.text.trim();
//                     String voucherDate = DateFormat('yyyy-MM-dd')
//                         .format(selectedStartDate); // ✅ Use selected date
//                     String voucherTime =
//                         DateFormat('HH:mm:ss').format(DateTime.now());

//                     // Map payment form from UI selection to API format
//                     String paymentForm =
//                         reverseReceivedToMap[selectedReceivedTo] ??
//                             "cash"; // ✅ Use reverse mapping

//                     int accountId = selectedAccountId ?? 0;
//                     int paymentTo = customerId;
//                     String percent = selectedDiscountType ?? "%";
//                     double totalAmt = double.tryParse(totalAmount.text) ?? 0;
//                     double paymentAmt =
//                         double.tryParse(paymentAmount.text) ?? 0;
//                     double discountAmt =
//                         double.tryParse(discountAmount.text) ?? 0;
//                     String notes = 'Updated payment voucher';

//                     // ✅ Build voucher items from receipt controllers (the actual input fields)
//                     List<Map<String, dynamic>> voucherItems = [];

//                     final customerProvider =
//                         Provider.of<CustomerProvider>(context, listen: false);

//                     // ✅ Use receiptControllers instead of undefined paymentControllers
//                     for (int i = 0; i < receiptControllers.length; i++) {
//                       final TextEditingController? controller =
//                           receiptControllers[i];

//                       if (controller != null &&
//                           controller.text.trim().isNotEmpty) {
//                         final double amount =
//                             double.tryParse(controller.text.trim()) ?? 0;
//                         if (amount > 0) {
//                           // ✅ Create a simple map instead of undefined PaymentVoucherItem class
//                           voucherItems.add({
//                             'sales_id': i
//                                 .toString(), // or use actual invoice ID if available
//                             'amount': amount.toStringAsFixed(2),
//                           });
//                         }
//                       }
//                     }

//                      final request = update.PaymentVoucherRequest(
//   userId: userId,
//   customerId: customerId,
//   voucherPerson: voucherPerson,
//   voucherNumber: voucherNumber,
//   voucherDate: voucherDate,
//   voucherTime: voucherTime,
//   paymentForm: paymentForm,
//   accountId: accountId,
//   paymentTo: paymentTo,
//   percent: percent,
//   totalAmount: totalAmt,
//   discount: discountAmt,
//   notes: notes,
//   voucherItems: voucherItems.map((item) {
//     return update.PaymentVoucherItem(
//       salesId: item['sales_id'].toString(),
//       amount: item['amount'].toString(),
//     );
//   }).toList(),
// );

//                     final provider = Provider.of<PaymentVoucherProvider>(
//                         context,
//                         listen: false);

//                     // 🔄 Call the update method
//                     bool success =
//                         await provider.updatePaymentVoucher(voucherId, request);

//                     if (success) {
//                       // ✅ Clear the selected customer using existing method
//                       Provider.of<CustomerProvider>(context, listen: false)
//                           .clearSelectedCustomer(); // ✅ Use existing method

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text(
//                           "Payment voucher updated successfully!",
//                           style: TextStyle(color: Colors.green),
//                         )),
//                       );
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 const PaymentOutList()), // Your payment list screen
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text("Failed to update payment voucher.")),
//                       );
//                     }
//                   },
//                   child: const Text("Update"),
//                 ),
//               ),
//             ],
//           ),

          const SizedBox(
            height: 10,
          )
        ]),
      ),
    );
  }
}
