// import 'package:cbook_dt/common/custome_dropdown_two.dart';
// import 'package:cbook_dt/feature/Received/create_recevied_item.dart';
// import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
// import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
// import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
// import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
// import 'package:cbook_dt/feature/sales/widget/add_sales_form_two.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ReceivedCreate extends StatefulWidget {
//   const ReceivedCreate({super.key});

//   @override
//   State<ReceivedCreate> createState() => _ReceivedCreateState();
// }

// class _ReceivedCreateState extends State<ReceivedCreate> {
//   String? selectedReceivedTo;
//   String? selectedAccount;

//   int? selectedAccountId;

//   DateTime selectedStartDate = DateTime.now();
//   // Default to current date
//   DateTime selectedEndDate = DateTime.now();
//   // Default to current date
//   String? selectedDropdownValue;

//   Future<void> _selectDate(BuildContext context, DateTime initialDate,
//       Function(DateTime) onDateSelected) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       onDateSelected(picked);
//     }
//   }

//   TextEditingController billNoController = TextEditingController();
//   String billNo = '';

//   void prepareIncomeItems(IncomeProvider provider, String selectedAccountId) {
//     // Convert receiptItems to required JSON structure
//     final List<Map<String, dynamic>> incomeItems =
//         provider.receiptItems.map((item) {
//       return {
//         "account_id": selectedAccountId,
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

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<SalesController>();
//     //final provider = Provider.of<IncomeProvider>(context);
//     final provider = context.watch<IncomeProvider>();

//     final colorScheme = Theme.of(context).colorScheme;

//     final providerExpense = Provider.of<ExpenseProvider>(context, listen: true);

//     // List of forms with metadata

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: colorScheme.primary,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//         automaticallyImplyLeading: true,
//         title: const Column(
//           children: [
//             SizedBox(
//               width: 5,
//             ),
//             Text(
//               'Received Create',
//               style: TextStyle(
//                   color: Colors.yellow,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold),
//             ),
//             SizedBox(
//               width: 5,
//             )
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           ///1 section
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: CustomDropdownTwo(
//                       hint: '',
//                       items: ['Cash in Hand', 'Bank'],
//                       width: double.infinity,
//                       height: 30,
//                       labelText: 'Receipt To',
//                       selectedItem: selectedReceivedTo,
//                       onChanged: (value) async {
//                         print('=== Received To Selected: $value ===');

//                         setState(() {
//                           selectedReceivedTo = value;
//                           selectedAccount = null; // reset account selection
//                         });

//                         if (value == 'Cash in Hand') {
//                           print('Fetching Cash accounts...');
//                           await provider.fetchAccounts('cash');
//                         } else if (value == 'Bank') {
//                           print('Fetching Bank accounts...');
//                           await provider.fetchAccounts('bank');
//                         }

//                         print(
//                             'Fetched Account Names: ${provider.accountNames}');
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   /// Account Dropdown
//                   SizedBox(
//                     height: 30,
//                     width: 150,
//                     child: provider.isAccountLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : CustomDropdownTwo(
//                             hint: '',
//                             items: provider.accountNames,
//                             width: double.infinity,
//                             height: 30,
//                             labelText: 'A/C',
//                             selectedItem: selectedAccount,
//                             onChanged: (value) {
//                               print('=== Account Selected: $value ===');
//                               setState(() {
//                                 selectedAccount = value;
//                               });

//                               if (provider.accountModel != null) {
//                                 final selectedAccountData = provider
//                                     .accountModel!.data
//                                     .firstWhere((account) =>
//                                         account.accountName == value);

//                                 selectedAccountId = selectedAccountData.id;

//                                 print('=== Account Selected: $value ===');
//                                 if (selectedAccountId != null) {
//                                   print(
//                                       'Selected Account ID: $selectedAccountId');
//                                 }

//                                 print('Selected Account Details:');
//                                 print('- ID: ${selectedAccountData.id}');
//                                 print(
//                                     '- Name: ${selectedAccountData.accountName}');
//                                 print('- Type: $selectedReceivedTo');
//                               }
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   //bill person
//                   SizedBox(
//                     height: 30,
//                     width: 90,
//                     child: TextField(
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 12,
//                       ),
//                       controller: TextEditingController(),
//                       cursorHeight: 12, // Match cursor height to text size
//                       decoration: InputDecoration(
//                         isDense: true, // Ensures the field is compact
//                         contentPadding:
//                             EdgeInsets.zero, // Removes unnecessary padding
//                         hintText: "Bill Person",
//                         hintStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600),
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Colors.grey.shade400,
//                             width: 0.5,
//                           ),
//                         ),
//                         focusedBorder: const UnderlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Colors.green,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Bill No Field

//                   const SizedBox(
//                     height: 8,
//                   ),

//                   ///bill no, bill person
//                   SizedBox(
//                     height: 30,
//                     width: 90,
//                     child: TextField(
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 12,
//                       ),
//                       controller: billNoController,
//                       cursorHeight: 12,
//                       onChanged: (value) {
//                         billNo = value;
//                       }, // Match cursor height to text size
//                       decoration: InputDecoration(
//                         isDense: true, // Ensures the field is compact
//                         contentPadding:
//                             EdgeInsets.zero, // Removes unnecessary padding
//                         hintText: "Bill no",
//                         hintStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600),
//                         enabledBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Colors.grey.shade400,
//                             width: 0.5,
//                           ),
//                         ),
//                         focusedBorder: const UnderlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Colors.green,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   //person

//                   ///bill date
//                   SizedBox(
//                     height: 30,
//                     width: 90,
//                     child: InkWell(
//                       // onTap: () => controller.pickDate(
//                       //     context), // Trigger the date picker
//                       child: InputDecorator(
//                         decoration: InputDecoration(
//                           isDense: true,
//                           suffixIcon: Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                           suffixIconConstraints: const BoxConstraints(
//                             minWidth: 16,
//                             minHeight: 16,
//                           ), // Adjust constraints to align icon closely
//                           hintText: "Bill Date",
//                           hintStyle: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 9,
//                           ),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(
//                                 color: Colors.grey.shade400, width: 0.5),
//                           ),
//                           focusedBorder: const UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.green),
//                           ),
//                         ),
//                         child: Text(
//                           controller.formattedDate.isNotEmpty
//                               ? controller.formattedDate
//                               : "Select Date", // Default text when no date is selected
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),

//           const SizedBox(
//             height: 6,
//           ),

//           ///2 section
//           InkWell(
//             onTap: () async {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ReceivedCreateItem()));
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: colorScheme.primary,
//                 borderRadius: BorderRadius.circular(3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: const Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Received From",
//                       style: TextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(
//             height: 8,
//           ),

          

//           Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ///show text field search ====>
//               AddSalesFormfieldTwo(
//                 controller: controller.customerNameController,
//                 customerorSaleslist: "Showing Customer list",
//                 customerOrSupplierButtonLavel: "", // Add customer
//                 color: Colors.grey,
//                 onTap: () {
                 
//                 },
//                 //label: "Customer",
//               ),

//               /// show bottom payable or recivedable.
//               Consumer<CustomerProvider>(
//                 builder: (context, customerProvider, child) {
//                   final customerList =
//                       customerProvider.customerResponse?.data ?? [];

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // If the customer list is empty, show a SizedBox
//                       if (customerList.isEmpty)
//                         const SizedBox(height: 2), // Adjust height as needed

//                       // Otherwise, show the dropdown with customers
//                       if (customerList.isNotEmpty)

//                         // Check if the selected customer is valid
//                         if (customerProvider.selectedCustomer != null &&
//                             customerProvider.selectedCustomer!.id != -1)
//                           Row(
//                             children: [
//                               Text(
//                                 "${customerProvider.selectedCustomer!.type == 'customer' ? 'Receivable' : 'Payable'}: ",
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color:
//                                       customerProvider.selectedCustomer!.type ==
//                                               'customer'
//                                           ? Colors.green
//                                           : Colors.red,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 2.0),
//                                 child: Text(
//                                   "৳ ${customerProvider.selectedCustomer!.due.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ]),
//       ),
//     );
//   }
// }
