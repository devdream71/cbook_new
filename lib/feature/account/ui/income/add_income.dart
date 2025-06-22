import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/income/income_list.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_item.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_item.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeCreate extends StatefulWidget {
  const IncomeCreate({super.key});

  @override
  State<IncomeCreate> createState() => _IncomeCreateState();
}

class _IncomeCreateState extends State<IncomeCreate> {
  String? selectedReceivedTo;
  String? selectedAccount;

  int? selectedAccountId;

  DateTime selectedStartDate = DateTime.now();
  // Default to current date
  DateTime selectedEndDate = DateTime.now();
  // Default to current date
  String? selectedDropdownValue;

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

  void prepareIncomeItems(IncomeProvider provider, String selectedAccountId) {
    // Convert receiptItems to required JSON structure
    final List<Map<String, dynamic>> incomeItems =
        provider.receiptItems.map((item) {
      return {
        "account_id": selectedAccountId,
        "narration": item.note,
        "amount": item.amount.toString(),
      };
    }).toList();

    final Map<String, dynamic> finalPayload = {
      "income_items": incomeItems,
    };

    // Print JSON string in console
    debugPrint('Final JSON Payload: $finalPayload');
  }

  @override
  void dispose() {
    // Clear receipt items when leaving the page
    final providerIncome = Provider.of<IncomeProvider>(context, listen: false);
    providerIncome.clearReceiptItems();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    //final provider = Provider.of<IncomeProvider>(context);
    final provider = context.watch<IncomeProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          provider.clearReceiptItems();
        }
      },
      child: Scaffold(
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
                'Income Create',
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
                    SizedBox(
                      height: 30,
                      width: 150,
                      child: CustomDropdownTwo(
                        hint: '',
                        items: const ['Cash in Hand', 'Bank'],
                        width: double.infinity,
                        height: 30,
                        labelText: 'Received to',
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
                    SizedBox(
                      height: 30,
                      width: 90,
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        controller: TextEditingController(),
                        cursorHeight: 12, // Match cursor height to text size
                        decoration: InputDecoration(
                          isDense: true, // Ensures the field is compact
                          contentPadding:
                              EdgeInsets.zero, // Removes unnecessary padding
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
                          focusedBorder: const UnderlineInputBorder(
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
                        controller: billNoController,
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
                      width: 90,
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
              height: 6,
            ),

            if (provider.receiptItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: provider.receiptItems.asMap().entries.map((entry) {
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
                          /// Index number
                          Text(
                            '$index.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),

                          /// Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Title
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

                                /// Note
                                Text(
                                  item.note,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          /// Amount and Delete Button
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
                                    child: Icon(Icons.close, size: 20)),
                                onPressed: () {
                                  setState(() {
                                    provider.receiptItems.remove(item);
                                    provider.notifyListeners();
                                  });
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
                        provider.receiptItems.fold<double>(
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
                        backgroundColor:
                            Colors.green, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? userId = prefs.getInt('user_id')?.toString();

                      if (userId == null) {
                        debugPrint("User ID is null");
                        return;
                      }

                      final invoiceNo = billNoController.text.trim();
                      const date =
                          "2025-06-10"; // your date string like '2025-06-10'
                      final receivedTo =
                          (selectedReceivedTo ?? '').toLowerCase();
                      final account = selectedAccountId.toString();
                      const notes = 'text'; // Or from your input field
                      const status = 1;

                      final totalAmount = provider.receiptItems.fold<double>(
                        0,
                        (sum, item) =>
                            sum +
                            (double.tryParse(item.amount.toString()) ?? 0),
                      );

                      // Prepare income items with correct account_id (use your actual accountId)
                      final List<IncomeItem> incomeItems =
                          provider.receiptItems.map((item) {
                        return IncomeItem(
                          accountId:
                              account, // or item-specific account id if different
                          narration: item.note,
                          amount: item.amount.toString(),
                        );
                      }).toList();

                      // 👉 Print all sending data
                      debugPrint('Sending Data:');
                      debugPrint('User ID: $userId');
                      debugPrint('Expense No: $invoiceNo');
                      debugPrint('Date: $date');
                      debugPrint('Paid To: $receivedTo');
                      debugPrint('Account: $account');
                      debugPrint('Total Amount: $totalAmount');
                      debugPrint('Notes: $notes');
                      debugPrint('Status: $status');
                      debugPrint(
                          'income Items: ${incomeItems.map((e) => e.toJson()).toList()}');

                      bool success = await provider.storeIncome(
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
                        provider.receiptItems.clear();
                        provider.notifyListeners();

                        // Navigate to Income page (replace with your actual route)
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Income()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to save income.')),
                        );
                      }
                    },

                    // onPressed: () async {
                    //   SharedPreferences prefs =
                    //       await SharedPreferences.getInstance();
                    //   String? userId = prefs.getInt('user_id')?.toString();

                    //   debugPrint("User ID: $userId");
                    //   debugPrint("invoice_no : ${billNoController.text}");
                    //   debugPrint(" Date: ${controller.formattedDate}");
                    //   debugPrint(
                    //       'Fetched Account Names: ${provider.accountNames}');
                    //   debugPrint('ReceivedTo:  $selectedReceivedTo');

                    //   debugPrint(" Account ID: $selectedAccountId");

                    //   debugPrint('- Type: $selectedReceivedTo');

                    //   final totalAmount = provider.receiptItems.fold<double>(
                    //     0,
                    //     (sum, item) =>
                    //         sum + (double.tryParse(item.amount.toString()) ?? 0),
                    //   );

                    //   // Print to console
                    //   debugPrint('Total Amount: $totalAmount');

                    //   debugPrint("Receipt Items:");
                    //   for (var item in provider.receiptItems) {
                    //     debugPrint(
                    //         "From: ${item.receiptFrom}, Note: ${item.note}, Amount: ${item.amount}");
                    //   }

                    //   void prepareIncomeItems(
                    //       IncomeProvider provider, String selectedAccountId) {
                    //     // Convert receiptItems to required JSON structure
                    //     final List<Map<String, dynamic>> incomeItems =
                    //         provider.receiptItems.map((item) {
                    //       return {
                    //         "account_id": "10",
                    //         "narration": item.note,
                    //         "amount": item.amount.toString(),
                    //       };
                    //     }).toList();

                    //     final Map<String, dynamic> finalPayload = {
                    //       "income_items": incomeItems,
                    //     };

                    //     // Print JSON string in console
                    //     debugPrint('Final JSON Payload: ${finalPayload}');
                    //   }

                    //   prepareIncomeItems(provider, selectedAccountId.toString());

                    // },

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
