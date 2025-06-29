import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_popup.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
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
        // ✅ Use this data to pre-fill your fields

        setState(() {
          

          voucherNumberController.text = data['voucher_number'] ?? '';
          //selectedReceivedTo = data['received_to']; //cash or bank //received_to
          selectedReceivedTo = receivedToMap[data['received_to']] ?? '';
          //selectedReceivedTo = receivedToMap[data['received_to']] ?? '';
          selectedBillPersonId = data['bill_person_id'];
          selectedAccountId =
              data['account_type']; // coount type //cash, cash 1,
          selectedDiscountType = data['discount_type'];
          discountAmount.text = (data['discount_amount'] ?? 0).toString();
          totalAmount.text = (data['total_amount'] ?? 0).toString();
          selectedStartDate =
              DateTime.tryParse(data['voucher_date']) ?? DateTime.now();
          selectedEndDate =
              DateTime.tryParse(data['voucher_date']) ?? DateTime.now();

          // ✅ Fill voucher details list
          if (data['voucher_detaiuls'] is List) {
            final List details = data['voucher_detaiuls'];
            for (int i = 0; i < details.length; i++) {
              final item = details[i];
              final controller =
                  TextEditingController(text: item['amount'].toString());
              receiptControllers[i] = controller;
            }
          }

          _recalculatePayment();

          debugPrint('receipt to === ${selectedReceivedTo} ');
        });
      }
    });
  }

  @override
  void dispose() {
    voucherNumberController.dispose();
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
                  // SizedBox(
                  //   height: 30,
                  //   width: 150,
                  //   child: CustomDropdownTwo(
                  //     hint: '',
                  //     items: const ['Cash in Hand', 'Bank'],
                  //     width: double.infinity,
                  //     height: 30,
                  //     labelText: 'Receipt To',
                  //     selectedItem: selectedReceivedTo,
                  //     onChanged: (value) async {
                  //       debugPrint('=== Received To Selected: $value ===');

                  //       setState(() {
                  //         selectedReceivedTo = value;
                  //         selectedAccount = null; // reset account selection
                  //       });

                  //       if (value == 'Cash in Hand') {
                  //         debugPrint('Fetching Cash accounts...');
                  //         await provider.fetchAccounts('cash');
                  //       } else if (value == 'Bank') {
                  //         debugPrint('Fetching Bank accounts...');
                  //         await provider.fetchAccounts('bank');
                  //       }

                  //       debugPrint(
                  //           'Fetched Account Names: ${provider.accountNames}');
                  //     },
                  //   ),
                  // ),

                  // SizedBox(
                  //   height: 30,
                  //   width: 150,
                  //   child: CustomDropdownTwo(
                  //     hint: '',
                  //     items: const ['Cash in Hand', 'Bank'],
                  //     width: double.infinity,
                  //     height: 30,
                  //     labelText: 'Receipt To',
                  //     selectedItem: selectedReceivedTo,
                  //     onChanged: (value) async {
                  //       debugPrint('=== Received To Selected: $value ===');

                  //       setState(() {
                  //         selectedReceivedTo = value;
                  //         selectedAccount = null; // reset account selection
                  //       });

                  //       final type = reverseReceivedToMap[value] ?? '';

                  //       if (type == 'cash') {
                  //         debugPrint('Fetching Cash accounts...');
                  //         await provider.fetchAccounts('cash');
                  //       } else if (type == 'bank') {
                  //         debugPrint('Fetching Bank accounts...');
                  //         await provider.fetchAccounts('bank');
                  //       }

                  //       debugPrint(
                  //           'Fetched Account Names: ${provider.accountNames}');
                  //     },
                  //   ),
                  // ),

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

          /// Customer search field
          AddSalesFormfieldTwo(
            controller: controller.customerNameController,
            customerorSaleslist: "Showing Customer list",
            customerOrSupplierButtonLavel: "",
            color: Colors.grey,
            isForReceivedVoucher: true,
            onTap: () async {
              // Add your customer selection logic
            },
          ),

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
              /// Total Amount Section

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),

                    backgroundColor: Colors.green, // Button background color
                    foregroundColor: Colors.white, // Button text color
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userId = prefs.getInt('user_id')?.toString();

                    if (userId == null) {
                      debugPrint("User ID is null");
                      return;
                    }

                    final invoiceNo = voucherNumberController.text.trim();
                    //final invoiceNo = billNoController.text.trim();
                    if (invoiceNo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Expense No cannot be empty')),
                      );
                      return;
                    }

                    const date = "2025-06-10";
                    final paidTo =
                        (selectedReceivedTo ?? '').toLowerCase().trim() ==
                                'cash in hand'
                            ? 'cash'
                            : 'bank';
                    //final account = selectedAccountId.toString();
                    final String account = providerExpense
                        .receiptItems.first.purchaseId
                        .toString(); // ✔️ Use correct account id

                    final expenseId = widget.paymentOutId;

                    const notes = 'text';
                    const status = 1;
                    //final expenseId = "59"; // Pass the correct expense ID

                    final totalAmount =
                        providerExpense.receiptItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum + (double.tryParse(item.amount.toString()) ?? 0),
                    );

                    final List<ExpenseItemPopUp> expenseItems =
                        providerExpense.receiptItems.map((item) {
                      return ExpenseItemPopUp(
                        accountId:
                            '10', // ✔️ Use correct item-specific account id
                        narration: item.note,
                        amount: item.amount.toString(),
                      );
                    }).toList();

                    debugPrint('Sending Data:');
                    debugPrint('User ID: $userId');
                    debugPrint('Expense No: $invoiceNo');
                    debugPrint('Date: $date');
                    debugPrint('Paid To: $paidTo');
                    debugPrint('Account: $account');
                    debugPrint('Total Amount: $totalAmount');
                    debugPrint('Notes: $notes');
                    debugPrint('Status: $status');
                    debugPrint(
                        'Expense Items: ${expenseItems.map((e) => e.toJson()).toList()}');

                    bool success = await providerExpense.updateExpense(
                      expenseId: expenseId,
                      userId: userId,
                      invoiceNo: invoiceNo,
                      date: date,
                      paidTo: paidTo,
                      account: account,
                      totalAmount: totalAmount,
                      notes: notes,
                      status: status,
                      expenseItems: expenseItems,
                    );

                    if (success) {
                      providerExpense.receiptItems.clear();
                      providerExpense.notifyListeners();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Expanse()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update expense.')),
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          )
        ]),
      ),
    );
  }
}
