import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expence_item.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_paid_form_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/income_list.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_item.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_item.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeEdit extends StatefulWidget {
  final String incomeId;
  const IncomeEdit({super.key, required this.incomeId});

  @override
  State<IncomeEdit> createState() => _IncomeEditState();
}

class _IncomeEditState extends State<IncomeEdit> {
  String? selectedReceivedTo;

  String? selectedAccount;

  int? selectedAccountId;

  late TextEditingController voucherNumberController;
  String billNo = '';
  String billDate = '';

  String? selectedBillPerson;
  int? selectedBillPersonId;
  BillPersonModel? selectedBillPersonData;

  @override
  void initState() {
    super.initState();
    voucherNumberController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final providerExpense =
          Provider.of<ExpenseProvider>(context, listen: false);
      final provider =
          Provider.of<IncomeProvider>(context, listen: false); // 👈 Add this

      /// ✅ First fetch Paid Form List
      await providerExpense.fetchPaidFormList();

      /// ✅ Then fetch Edit Expense
      await providerExpense.fetchEditExpense(widget.incomeId);

      voucherNumberController.text =
          providerExpense.editExpenseData?.voucherNumber ?? '';
      billDate = providerExpense.editExpenseData?.voucherDate ?? '';

      /// Paid to mapping
      String? paidToApi = providerExpense.editExpenseData?.paidTo;
      if (paidToApi == 'cash') {
        selectedReceivedTo = 'Cash in Hand';
        await provider.fetchAccounts('cash'); // Fetch related accounts
      } else if (paidToApi == 'bank') {
        selectedReceivedTo = 'Bank';
        await provider.fetchAccounts('bank'); // Fetch related accounts
      }

      /// ✅ Preselect Account Name based on accountId
      //int accountIdFromApi = providerExpense.editExpenseData?.accountId ?? 0;

      /// ✅ Preselect Account Name based on accountId
      int accountIdFromApi = providerExpense.editExpenseData?.accountId ?? 0;

      if (provider.accountModel != null) {
        final matchingAccount = provider.accountModel!.data.firstWhere(
          (account) => account.id == accountIdFromApi,
          orElse: () => provider
              .accountModel!.data.first, // fallback to first item if not found
        );

        selectedAccount = matchingAccount.accountName;
        selectedAccountId = matchingAccount.id;

        debugPrint('Selected Account from API: $selectedAccount');
      }

      setState(() {});
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

    final providerIncome = Provider.of<IncomeProvider>(context, listen: true);

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
              'Income Update',
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

          if (providerExpense.editExpenseData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///paid to
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
                                debugPrint(
                                    '=== Received To Selected: $value ===');

                                setState(() {
                                  selectedReceivedTo = value;
                                  selectedAccount =
                                      null; // reset account selection
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
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CustomDropdownTwo(
                                    hint: '',
                                    items: provider.accountNames,
                                    width: double.infinity,
                                    height: 30,
                                    labelText: 'Account',
                                    selectedItem: selectedAccount,
                                    onChanged: (value) {
                                      debugPrint(
                                          '=== Account Selected: $value ===');
                                      setState(() {
                                        selectedAccount = value;
                                      });

                                      if (provider.accountModel != null) {
                                        final selectedAccountData = provider
                                            .accountModel!.data
                                            .firstWhere((account) =>
                                                account.accountName == value);

                                        selectedAccountId =
                                            selectedAccountData.id;

                                        debugPrint(
                                            '=== Account Selected: $value ===');
                                        if (selectedAccountId != null) {
                                          debugPrint(
                                              'Selected Account ID: $selectedAccountId');
                                        }

                                        debugPrint('Selected Account Details:');
                                        debugPrint(
                                            '- ID: ${selectedAccountData.id}');
                                        debugPrint(
                                            '- Name: ${selectedAccountData.accountName}');
                                        debugPrint(
                                            '- Type: $selectedReceivedTo');
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
 


                          // SizedBox(
                          //   height: 30,
                          //   width: 90,
                          //   child: TextField(
                          //     style: const TextStyle(
                          //       color: Colors.black,
                          //       fontSize: 12,
                          //     ),
                          //     controller: TextEditingController(),
                          //     cursorHeight:
                          //         12, // Match cursor height to text size
                          //     decoration: InputDecoration(
                          //       isDense: true, // Ensures the field is compact
                          //       contentPadding: EdgeInsets
                          //           .zero, // Removes unnecessary padding
                          //       hintText: "Bill Person",
                          //       hintStyle: TextStyle(
                          //           color: Colors.grey.shade400,
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.w600),
                          //       enabledBorder: UnderlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.grey.shade400,
                          //           width: 0.5,
                          //         ),
                          //       ),
                          //       focusedBorder: const UnderlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.green,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
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
                              controller: voucherNumberController,
                              cursorHeight: 12,
                              onChanged: (value) {
                                billNo = value;
                              }, // Match cursor height to text size
                              decoration: InputDecoration(
                                isDense: true, // Ensures the field is compact
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
                            width: 90,
                            child: InkWell(
                              // onTap: () => controller.pickDate(
                              //     context), // Trigger the date picker
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // Example: Format the date if needed
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

                                  setState(() {
                                    billDate =
                                        formattedDate; // Update the selected date
                                  });
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
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                child: Text(
                                  billDate.isNotEmpty
                                      ? billDate
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
                ],
              ),
            ),

          const SizedBox(
            height: 8,
          ),

          ///expense item list.
          if (provider.receiptItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  providerExpense.receiptItems.asMap().entries.map((entry) {
                int index = entry.key + 1;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      showExpenseUpdateDialog(context, providerExpense, item);
                    },
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
                                  providerExpense.getAccountNameById(item
                                      .purchaseId), // ✅ show account_name instead of ID
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
                                  providerExpense.receiptItems.remove(item);
                                  providerExpense.notifyListeners();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 6),

          InkWell(
            onTap: () async {
              await provider
                  .fetchReceiptFromList(); // 🔥 Fetch API before showing dialog
              showIncomeCreateDialog(
                context,
                provider,
              ); // Pass provider
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
                      "Receipt From",
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

              //update.

              // Income Update Button Implementation

              // Income Update Button Implementation
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
                    if (invoiceNo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Income No cannot be empty')),
                      );
                      return;
                    }

                    const date = "2025-06-10";
                    final receivedTo =
                        (selectedReceivedTo ?? '').toLowerCase().trim() ==
                                'cash in hand'
                            ? 'cash'
                            : 'bank';

                    // Get the IncomeProvider instance
                    final providerIncome =
                        Provider.of<IncomeProvider>(context, listen: false);

                    // Get account from selected received form (from provider)
                    final String account = providerIncome
                            .selectedReceivedFormForUpdate?.id
                            .toString() ??
                        '10';

                    final incomeId =
                        widget.incomeId; // Get income ID from widget

                    const notes = 'text';
                    const status = 1;

                    final totalAmount =
                        providerIncome.receiptItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum + (double.tryParse(item.amount.toString()) ?? 0),
                    );

                    final List<IncomeItem> incomeItems =
                        providerIncome.receiptItems.map((item) {
                      return IncomeItem(
                        accountId: providerIncome.selectedAccountForUpdate?.id
                                .toString() ??
                            '',
                        narration: item.note,
                        amount: item.amount.toString(),
                      );
                    }).toList();

                    debugPrint('Sending Income Update Data:');
                    debugPrint('User ID: $userId');
                    debugPrint('Income ID: $incomeId');
                    debugPrint('Invoice No: $invoiceNo');
                    debugPrint('Date: $date');
                    debugPrint('Received To: $receivedTo');
                    debugPrint('Account: $account');
                    debugPrint('Total Amount: $totalAmount');
                    debugPrint('Notes: $notes');
                    debugPrint('Status: $status');
                    debugPrint(
                        'Income Items: ${incomeItems.map((e) => e.toJson()).toList()}');

                    bool success = await providerIncome.updateIncome(
                      incomeId: incomeId,
                      userId: userId,
                      invoiceNo: invoiceNo,
                      date: date,
                      receivedTo: receivedTo,
                      account: account,
                      totalAmount: totalAmount,
                      notes: notes,
                      status: status,
                      incomeItems: incomeItems,
                    );

                    if (success) {
                      providerIncome.receiptItems.clear();
                      providerIncome.notifyListeners();

                      // Refresh the income list after successful update
                      await providerIncome.fetchIncomeList();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const Income()), // Replace with your income page
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update income.')),
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

  ////expense item create=====>
  ///
  void showExpenseCreateDialog(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    await provider.fetchPaidFormList();

    // ✅ Move variables OUTSIDE StatefulBuilder
    TextEditingController amountController = TextEditingController();
    TextEditingController noteController = TextEditingController();
    String? selectedPaidTo;
    PaidFormData? selectedPaidForm;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                                "Paid To",
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
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
                                debugPrint('Selected Paid To: $selectedItem');

                                final matchedAccount = provider.paidFormList
                                    .firstWhere((element) =>
                                        element.accountName == selectedItem);

                                setState(() {
                                  selectedPaidTo = selectedItem;
                                  selectedPaidForm =
                                      matchedAccount; // ✅ Track object correctly
                                });
                              },
                            ),
                    ),
                    AddSalesFormfield(
                      label: "",
                      labelText: "Amount",
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                    ),
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
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text('Add & New'),
                        // ),
                        TextButton(
                          onPressed: () {
                            if (selectedPaidForm != null &&
                                amountController.text.isNotEmpty) {
                              provider.addReceiptItem(
                                ExpenseItem(
                                  purchaseId: selectedPaidForm!.id,
                                  receiptFrom: selectedPaidTo!,
                                  note: noteController.text,
                                  amount:
                                      double.tryParse(amountController.text) ??
                                          0.0,
                                ),
                              );
                              amountController.clear();
                              noteController.clear();
                              Navigator.of(context).pop();
                            } else {
                              // ✅ Optional: Show warning if not selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select Paid To'),
                                ),
                              );
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ////expenseItem update

  void showExpenseUpdateDialog(
    BuildContext context,
    ExpenseProvider provider,
    ExpenseItem item, // ✅ Pass the selected item
  ) async {
    await provider
        .fetchPaidFormList(); // ✅ Fetch API data before showing dialog

    TextEditingController amountController =
        TextEditingController(text: item.amount.toString());
    TextEditingController noteController =
        TextEditingController(text: item.note);
    //String? selectedPaidTo = item.purchaseId.toString(); // ✅ Preselect existing item value

    /// ✅ Preselect account_name instead of ID
    String? selectedPaidTo = provider.getAccountNameById(item.purchaseId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                                "Update Paid Form",
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
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
                                debugPrint('Selected Paid To: $selectedItem');
                                setState(() {
                                  selectedPaidTo = selectedItem;
                                  // providerIncome
                                  //     .setSelectedReceivedFormForUpdate(
                                  //         matchedAccount);
                                });
                              },
                            ),
                    ),
                    AddSalesFormfield(
                      label: "",
                      labelText: "Amount",
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                    ),
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
                        TextButton(
                          onPressed: () {
                            if (selectedPaidTo != null &&
                                amountController.text.isNotEmpty) {
                              // ✅ Update the item values
                              item.receiptFrom = selectedPaidTo!;
                              item.note = noteController.text;
                              item.amount =
                                  double.tryParse(amountController.text) ?? 0.0;

                              provider.notifyListeners(); // ✅ Refresh UI
                              Navigator.of(context).pop();

                              // Optional: Show a success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Expense item updated successfully')),
                              );
                            }
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showIncomeCreateDialog(
    BuildContext context,
    IncomeProvider provider,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController amountController = TextEditingController();
        TextEditingController noteController = TextEditingController();
        String? selectedReceiptFrom;

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width:
                                  30), // Placeholder for left spacing (can be removed or adjusted)

                          // Centered text and icon
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text(
                                "Receipt From",
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
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 30,
                      child: provider.isReceiptLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomDropdownTwo(
                              hint: '',
                              items: provider.receiptFromNames,
                              width: double.infinity,
                              height: 30,
                              labelText: 'Receipt From',
                              selectedItem: selectedReceiptFrom,
                              onChanged: (selectedItem) {
                                debugPrint(
                                    'Selected Receipt From: $selectedItem');
                                setState(() {
                                  selectedReceiptFrom = selectedItem;
                                });
                              },
                            ),
                    ),
                    AddSalesFormfield(
                      label: "",
                      labelText: "Amount",
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                    ),
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
                        TextButton(
                          onPressed: () {
                            if (selectedReceiptFrom != null &&
                                amountController.text.isNotEmpty) {
                              provider.addReceiptItem(ReceiptItem(
                                receiptFrom: selectedReceiptFrom!,
                                amount: amountController.text,
                                note: noteController.text,
                              ));
                              amountController.clear();
                              noteController.clear();
                              setState(() {
                                selectedReceiptFrom = null;
                              });
                            }
                          },
                          child: const Text('Add & New'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (selectedReceiptFrom != null &&
                                amountController.text.isNotEmpty) {
                              provider.addReceiptItem(ReceiptItem(
                                receiptFrom: selectedReceiptFrom!,
                                amount: amountController.text,
                                note: noteController.text,
                              ));
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
