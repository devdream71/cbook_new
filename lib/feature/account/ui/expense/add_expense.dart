import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expence_item.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_popup.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_paid_form_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseCreate extends StatefulWidget {
  const ExpenseCreate({super.key});

  @override
  State<ExpenseCreate> createState() => _ExpenseCreateState();
}

class _ExpenseCreateState extends State<ExpenseCreate> {
  String? selectedReceivedTo;
  String? selectedAccount;

  int? selectedAccountId;

  String? selectedDropdownValue;

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchBillPersons());

    // Set today's date after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<SalesController>(context, listen: false);

      if (controller.formattedDate2.isEmpty) {
        final now = DateTime.now();
        controller.formattedDate2 =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        setState(() {}); // 👈 make sure UI updates
      }
    });
  }

  void resetForm() {
    setState(() {
      // Dropdowns and selections
      selectedReceivedTo = null;
      selectedAccount = null;
      selectedAccountId = null;

      selectedBillPerson = null;
      selectedBillPersonId = null;
      selectedBillPersonData = null;

      // Text input
      billNoController.clear();
      billNo = '';

      // Date
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      Provider.of<SalesController>(context, listen: false).formattedDate2 =
          formattedDate;

      // Clear added items
      Provider.of<ExpenseProvider>(context, listen: false).clearReceiptItems();
    });
  }

  @override
  void dispose() {
    // Clear receipt items when leaving the page
    final providerExpense =
        Provider.of<ExpenseProvider>(context, listen: false);
    providerExpense.clearReceiptItems();

    super.dispose();
  }

  TextEditingController billNoController = TextEditingController();
  String billNo = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();

    final provider = context.watch<IncomeProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    final providerExpense = Provider.of<ExpenseProvider>(context, listen: true);

    // List of forms with metadata

    return PopScope(
      canPop: true, // Allow the back navigation

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Clear receipt items when user navigates back
          providerExpense.clearReceiptItems();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.sfWhite,
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
                'Expence Create',
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ///1 section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///cash in hand or bank
                    SizedBox(
                      height: 30,
                      width: 150,
                      child: CustomDropdownTwo(
                        hint: '',
                        items: const ['Cash in Hand', 'Bank'],
                        width: double.infinity,
                        height: 30,
                        labelText: 'Paid To',
                        selectedItem: selectedReceivedTo,
                        onChanged: (value) async {
                          debugPrint('=== Received To Selected: $value ===');

                          setState(() {
                            selectedReceivedTo = value;
                            selectedAccount = null; // reset account selection
                          });

                          if (value == 'Cash in Hand') {
                            debugPrint('Fetching Cash accounts...');
                            await provider.fetchAccounts('cash');
                          } else if (value == 'Bank') {
                            debugPrint('Fetching Bank accounts...');
                            await provider.fetchAccounts('bank');
                          }

                          debugPrint(
                              'Fetched Account Names: ${provider.accountNames}');
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

                                  debugPrint(
                                      '=== Account Selected: $value ===');
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
                    //bill person

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Consumer<PaymentVoucherProvider>(
                        builder: (context, provider, child) {
                          return SizedBox(
                            height: 30,
                            width: 130,
                            child: provider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
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

                    const SizedBox(
                      height: 8,
                    ),

                    ///bill no, bill person
                    SizedBox(
                      height: 30,
                      width: 130,
                      child: AddSalesFormfield(
                        labelText: "Bill No",
                        controller: billNoController,
                        onChanged: (value) {
                          billNo = value;
                        }, // Match cursor height to text size
                      ),
                    ),

                    //person

                    ///bill date
                    ///bill date.
                    SizedBox(
                      height: 30,
                      width: 130,
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            final formatted =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

                            setState(() {
                              controller.formattedDate2 =
                                  formatted; // ✅ update UI
                            });

                            debugPrint("📅 Selected Bill Date: $formatted");
                          }
                        },
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
                            ),
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
                            controller.formattedDate2.isNotEmpty
                                ? controller.formattedDate2
                                : "Select Date",
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
              height: 6,
            ),

            if (providerExpense.receiptItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    providerExpense.receiptItems.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '$index.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.receiptFrom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  item.note,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.amount.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 13,
                                  child: Icon(Icons.close, size: 20),
                                ),
                                onPressed: () {
                                  // providerExpense.receiptItems.remove(item);
                                  // providerExpense.notifyListeners();

                                  showDeleteConfirmationDialog(
                                    context: context,
                                    onConfirm: () {
                                      setState(() {
                                        providerExpense.receiptItems
                                            .remove(item);
                                        providerExpense.notifyListeners();
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 6),

            ///2 section
            InkWell(
              onTap: () async {
                await provider
                    .fetchReceiptFromList(); // 🔥 Fetch API before showing dialog

                final expenseProvider =
                    Provider.of<ExpenseProvider>(context, listen: false);
                await expenseProvider.fetchPaidFormList();
                showExpenseCreateDialog(context, expenseProvider);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Paid From",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      InkWell(
                        onTap: () {},
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
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Total Amount Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Total: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      Text(
                        providerExpense.receiptItems.fold<double>(
                          0,
                          (sum, item) {
                            // parse amount string safely to double
                            final amt =
                                double.tryParse(item.amount.toString()) ?? 0.0;
                            return sum + amt;
                          },
                        ).toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
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

                      final invoiceNo = billNoController.text.trim();
                      final date = controller
                          .formattedDate2; // your date string like '2025-06-10'
                      final receivedTo =
                          (selectedReceivedTo ?? '').toLowerCase();
                      final accountID = selectedAccountId.toString();
                      const notes = 'text'; // Or from your input field
                      const status = 1;

                      final billPersonId = selectedBillPersonData!.id;

                      final totalAmount =
                          providerExpense.receiptItems.fold<double>(
                        0,
                        (sum, item) =>
                            sum +
                            (double.tryParse(item.amount.toString()) ?? 0),
                      );

                      // Prepare income items with correct account_id (use your actual accountId)
                      final List<ExpenseItemPopUp> expenseItems =
                          providerExpense.receiptItems.map((item) {
                        return ExpenseItemPopUp(
                          //itemAccountId: selectedPaidTo!, // or item-specific account id if different
                          //accountId: providerExpense.selectedAccountForUpdate?.id.toString() ?? '',
                          itemAccountId: item.purchaseId.toString(),
                          narration: item.note,
                          amount: item.amount.toString(),
                        );
                      }).toList();

                      // 👉 Print all sending data
                      debugPrint('Sending Data:');
                      debugPrint('User ID: $userId');
                      debugPrint('Expense No: $invoiceNo');
                      debugPrint('Date: ${controller.formattedDate2}');
                      debugPrint('Paid To: $receivedTo');
                      debugPrint('AccountID: $accountID');
                      debugPrint('Total Amount: $totalAmount');
                      debugPrint('Notes: $notes');
                      debugPrint('Status: $status');
                      debugPrint('bill person: $billPersonId');
                      debugPrint(
                          'Expense Items: ${expenseItems.map((e) => e.toJson()).toList()}');

                      bool success = await providerExpense.storeExpense(
                        userId: userId,
                        invoiceNo: invoiceNo,
                        date: date,
                        receivedTo: receivedTo,
                        account: accountID,
                        totalAmount: totalAmount,
                        notes: notes,
                        status: status,
                        expenseItems: expenseItems,
                        billPersonId: billPersonId.toString(),
                      );

                      if (success) {
                        providerExpense.receiptItems.clear();
                        providerExpense.notifyListeners();

                        providerExpense.fetchExpenseList();

                        // ✅ Clear everything
                        resetForm();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Expanse()),
                          (Route<dynamic> route) => false,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.green,
                              content:
                                  Text('Successfully. Save  The Expense.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to save expense.')),
                        );
                      }
                    }, 
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            )
          ]),
        ),
      ),
    );
  }

  void showExpenseCreateDialog(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    await provider
        .fetchPaidFormList(); // ✅ Fetch API data before showing dialog

    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController amountController = TextEditingController();
          TextEditingController noteController = TextEditingController();
          String? selectedPaidTo;
           
       int? selectedPaidToId; 

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(6.0),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 30,
                          color: const Color(0xff278d46),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 30),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 5),
                                  Text(
                                    "Paid Form",
                                    style: TextStyle(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey.shade100,
                                    child: const Icon(Icons.close,
                                        size: 18, color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///paid to from pop up
                        // SizedBox(
                        //   height: 30,
                        //   child: provider.isLoading
                        //       ? const Center(child: CircularProgressIndicator())
                        //       : CustomDropdownTwo(
                        //           hint: '',
                        //           items: provider.paidFormList
                        //               .map((e) => e.accountName)
                        //               .toList(),
                        //           width: double.infinity,
                        //           height: 30,
                        //           labelText: 'Paid To',
                        //           selectedItem: selectedPaidTo,
                        //           onChanged: (selectedItem) {
                        //             debugPrint(
                        //                 'Selected Paid To: $selectedItem');

                        //             final selected =
                        //                 provider.paidFormList.firstWhere(
                        //               (e) => e.accountName == selectedItem,
                        //               orElse: () => PaidFormData(
                        //                   id: 0, accountName: 'Unknown'),
                        //             );

                        //             debugPrint(
                        //                 '✅ Selected Paid Form ID: ${selected.id}');

                        //             setState(() {
                        //               selectedPaidTo = selectedItem;

                        //               // Optionally, if you want to store the object too:
                        //               // selectedPaidFormData = selected;
                        //             });
                        //             // debugPrint(
                        //             //     'Selected Paid To: $selectedItem');
                        //             // debugPrint(
                        //             //     'Selected Paid To: $selectedItem.');
                        //             // setState(() {
                        //             //   selectedPaidTo = selectedItem;
                        //             // });
                        //           },
                        //         ),
                        // ),

                        SizedBox(
                          height: 30,
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomDropdownTwo(
                                  hint: '',
                                  items: provider.paidFormList
                                      .map((e) => e.accountName)
                                      .toList(),
                                  width: double.infinity,
                                  height: 30,
                                  labelText: 'Paid To',
                                  selectedItem: selectedPaidTo,
                                  onChanged: (selectedItem) {
                                     final selected = provider.paidFormList.firstWhere(
    (e) => e.accountName == selectedItem,
    orElse: () => PaidFormData(id: 0, accountName: 'Unknown'),
  );

  debugPrint('✅ Selected Paid Form ID: ${selected.id}');

  setState(() {
    selectedPaidTo = selectedItem;
    selectedPaidToId = selected.id; // ✅ STORE ID HERE
  });
                                  },
                                ),
                        ),

                        ///amount
                        AddSalesFormfield(
                          label: "",
                          labelText: "Amount",
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {},
                        ),

                        ///note
                        AddSalesFormfield(
                          label: "",
                          labelText: "Note",
                          controller: noteController,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {},
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ///add
                            TextButton(
                              onPressed: () {
                                if (selectedPaidTo != null &&
                                    amountController.text.isNotEmpty) {
                                  provider.addReceiptItem(
                                    ExpenseItem(
                                      purchaseId: selectedPaidToId, 
                                      receiptFrom: selectedPaidTo!,
                                      note: noteController.text,
                                      amount: double.tryParse(
                                              amountController.text) ??
                                          0.0,
                                    ),
                                  );
                                  amountController.clear();
                                  noteController.clear();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text(
                                'Add',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            },
          );
        });
  }

  //remove item
  void showDeleteConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Remove?"),
        content: const Text(
          "Are you sure you want to remove the item?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onConfirm(); // Run the actual delete
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
