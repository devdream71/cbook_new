import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentOutCreateItem extends StatefulWidget {
  const PaymentOutCreateItem({super.key});

  @override
  State<PaymentOutCreateItem> createState() => _PaymentOutCreateItemState();
}

class _PaymentOutCreateItemState extends State<PaymentOutCreateItem> {
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

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);

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

  //int? selectedIndex; // 🔥 To track which item is expanded

  Set<int> expandedIndexes = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    //final provider = Provider.of<IncomeProvider>(context);
    final provider = context.watch<IncomeProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    final providerExpense = Provider.of<ExpenseProvider>(context, listen: true);

    // List of forms with metadata

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
              'Payment out Create',
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
                      labelText: 'Payment From',
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
                      "Payment To",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// Customer search field
          // AddSalesFormfieldTwo(
          //   controller: controller.customerNameController,
          //   customerorSaleslist: "Showing Customer list",
          //   customerOrSupplierButtonLavel: "",
          //   color: Colors.grey,
          //   onTap: () {
          //     // Add your customer selection logic
          //   },
          // ),

          // /// Show customer payable/receivable if selected
          // Consumer<CustomerProvider>(
          //   builder: (context, customerProvider, child) {
          //     final customerList =
          //         customerProvider.customerResponse?.data ?? [];
          //     final selectedCustomer = customerProvider.selectedCustomer;

          //     return Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         if (customerList.isEmpty) const SizedBox(height: 2),
          //         if (customerList.isNotEmpty &&
          //             selectedCustomer != null &&
          //             selectedCustomer.id != -1) ...[
          //           Row(
          //             children: [
          //               Text(
          //                 "${selectedCustomer.type == 'customer' ? 'Receivable' : 'Payable'}: ",
          //                 style: TextStyle(
          //                   fontSize: 10,
          //                   fontWeight: FontWeight.bold,
          //                   color: selectedCustomer.type == 'customer'
          //                       ? Colors.green
          //                       : Colors.red,
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 2.0),
          //                 child: Text(
          //                   "৳ ${selectedCustomer.due.toStringAsFixed(2)}",
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

          //         ]
          //       ],
          //     );
          //   },
          // ),

          /// Sales List (Only show when customer is selected)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2, // Replace with your sales list count
            itemBuilder: (context, index) {
              bool isExpanded = expandedIndexes.contains(index);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 2),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        // Toggle individual expansion
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sales/1254', style: ts),
                              Text('12/05/2025', style: ts),
                              Text('Bill 5,000', style: ts),
                              Text('Due 4,360', style: ts),
                              Icon(
                                isExpanded
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 28,
                              ),
                            ],
                          ),
                          // Expanded Section
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Payment', style: ts),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 30,
                                  width: 150,
                                  child: AddSalesFormfield(
                                    controller: TextEditingController(),
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const Spacer(),

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
                        controller: TextEditingController(),
                        onChanged: (value) {},
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
                        labelText: '%',
                        selectedItem: selectedReceivedTo,
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      width: 76,
                      child: AddSalesFormfield(
                        controller: TextEditingController(),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Received
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Payment", style: ts),
                    const SizedBox(width: 24),
                    SizedBox(
                      height: 30,
                      width: 163,
                      child: AddSalesFormfield(
                        controller: TextEditingController(),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Total Amount Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
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
                  onPressed: () async {},
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
    );
  }
}
