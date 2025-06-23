import 'package:cbook_dt/feature/account/ui/expense/add_expense.dart';
import 'package:cbook_dt/feature/account/ui/expense/expence_edit.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_view_details.dart';
import 'package:cbook_dt/feature/account/ui/expense/provider/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Expanse extends StatefulWidget {
  const Expanse({super.key});

  @override
  State<Expanse> createState() => _ExpanseState();
}

class _ExpanseState extends State<Expanse> {
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

  @override
  void initState() {
    super.initState();
    //Provider.of<ExpenseProvider>(context, listen: false).fetchExpenseList();
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenseList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Column(
          children: [
            Text(
              'Expense',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseCreate()));
            },
            child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.yellow,
                child: Icon(
                  Icons.add,
                  color: colorScheme.primary,
                )),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///top date start , end and dropdown

          Column(
            children: [
              ///start date, end date, dropdown, its working, but now no need.
              // SizedBox(
              //   width: double.infinity,
              //   child: DecoratedBox(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.all(6.0),
              //       child: Row(
              //         children: [
              //           // Start Date Picker
              //           SizedBox(
              //             width: MediaQuery.of(context).size.width * 0.25,
              //             child: GestureDetector(
              //               onTap: () =>
              //                   _selectDate(context, selectedStartDate, (date) {
              //                 setState(() {
              //                   selectedStartDate = date;
              //                 });
              //               }),
              //               child: Container(
              //                 height: 30,
              //                 padding:
              //                     const EdgeInsets.symmetric(horizontal: 8),
              //                 decoration: const BoxDecoration(
              //                     // border:
              //                     //     Border.all(color: Colors.grey.shade100),
              //                     // borderRadius: BorderRadius.circular(4),
              //                     ),
              //                 child: Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
              //                       style: GoogleFonts.notoSansPhagsPa(
              //                           fontSize: 12, color: Colors.black),
              //                     ),
              //                     const Icon(Icons.calendar_today, size: 14),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(width: 8),

              //           Text("To",
              //               style: GoogleFonts.notoSansPhagsPa(
              //                   fontSize: 14, color: Colors.black)),
              //           const SizedBox(width: 8),

              //           // End Date Picker
              //           SizedBox(
              //             width: MediaQuery.of(context).size.width * 0.25,
              //             child: GestureDetector(
              //               onTap: () =>
              //                   _selectDate(context, selectedEndDate, (date) {
              //                 setState(() {
              //                   selectedEndDate = date;
              //                 });
              //               }),
              //               child: Container(
              //                 height: 30,
              //                 padding:
              //                     const EdgeInsets.symmetric(horizontal: 8),
              //                 decoration: const BoxDecoration(
              //                     // border:
              //                     //     Border.all(color: Colors.grey.shade100),
              //                     // borderRadius: BorderRadius.circular(4),
              //                     ),
              //                 child: Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
              //                       style: GoogleFonts.notoSansPhagsPa(
              //                           fontSize: 12, color: Colors.black),
              //                     ),
              //                     const Icon(Icons.calendar_today, size: 14),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(width: 8),

              //           const Spacer(),

              //           // Dropdown
              //           SizedBox(
              //             width: MediaQuery.of(context).size.width * 0.25,
              //             child: SizedBox(
              //               height: 30,
              //               child: DropdownButtonFormField<String>(
              //                 decoration: InputDecoration(
              //                   contentPadding:
              //                       const EdgeInsets.symmetric(horizontal: 0),
              //                   enabledBorder: OutlineInputBorder(
              //                     borderSide:
              //                         BorderSide(color: Colors.grey.shade100),
              //                   ),
              //                   focusedBorder: OutlineInputBorder(
              //                       borderSide: BorderSide(
              //                           color: Colors.grey.shade100)),
              //                   border: OutlineInputBorder(
              //                     borderRadius: BorderRadius.circular(4),
              //                     borderSide:
              //                         BorderSide(color: Colors.grey.shade100),
              //                   ),
              //                 ),
              //                 value: selectedDropdownValue,
              //                 hint: const Text(""),
              //                 onChanged: (String? newValue) {
              //                   setState(() {
              //                     selectedDropdownValue = newValue;
              //                   });
              //                 },
              //                 items: [
              //                   "All",
              //                   "Purchase",
              //                   "Sale",
              //                   "P. Return",
              //                   "S. Return"
              //                 ].map<DropdownMenuItem<String>>((String value) {
              //                   return DropdownMenuItem<String>(
              //                     value: value,
              //                     child: Padding(
              //                       padding: const EdgeInsets.symmetric(
              //                           horizontal: 4.0),
              //                       child: Text(value,
              //                           style: GoogleFonts.notoSansPhagsPa(
              //                               fontSize: 12, color: Colors.black)),
              //                     ),
              //                   );
              //                 }).toList(),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              const SizedBox(
                height: 5,
              ),
              Consumer<ExpenseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.expenseList.isEmpty) {
                    return const Center(
                        child: Text(
                      'No expenses found.',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.expenseList.length,
                    itemBuilder: (context, index) {
                      final expense = provider.expenseList[index];

                      final expenseId = expense.id.toString();
                      return InkWell(
                        onLongPress: () {
                          editDeleteDiolog(context, expenseId);
                        },
                        onTap: () {
                          ///navigation to expense deatils page
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ExpanseDetails()));
                        },
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .zero, // ✅ Set corner radius to zero
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Voucher Number
                                    Text(
                                      "Paid Form",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),

                                    /// Date and Time
                                    Text(
                                      'Cash in Hand',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),

                                    /// Paid To
                                    Text(
                                      'Cash',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${expense.voucherDate}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '${expense.voucherNumber}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '${expense.totalAmount} ৳',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),

                                    ///3dot vertical button.
                                    // IconButton(
                                    //   onPressed: () {
                                    //     _showDeleteDialog(
                                    //       context, expenseId
                                    //     );

                                    //   },
                                    //   icon: const Icon(Icons.more_vert),
                                    // ),

                                    /////working. 3 dot, edit and delete.
                                    // PopupMenuButton<String>(
                                    //   onSelected: (String choice) {
                                    //     if (choice == 'edit') {
                                    //       // Navigate to Edit Page
                                    //       Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //           builder: (context) => ExpenseEdit(
                                    //               expenseId: expenseId),
                                    //         ),
                                    //       );
                                    //     } else if (choice == 'delete') {
                                    //       // Show Delete Confirmation Dialog
                                    //       _showDeleteDialog(context, expenseId);
                                    //     }
                                    //   },
                                    //   itemBuilder: (BuildContext context) =>
                                    //       <PopupMenuEntry<String>>[
                                    //     const PopupMenuItem<String>(
                                    //       value: 'edit',
                                    //       textStyle:
                                    //           TextStyle(color: Colors.blue),
                                    //       child: Text('Edit'),
                                    //     ),
                                    //     const PopupMenuItem<String>(
                                    //       value: 'delete',
                                    //       textStyle: TextStyle(color: Colors.red),
                                    //       child: Text('Delete'),
                                    //     ),
                                    //   ],
                                    //   icon: const Icon(
                                    //       Icons.more_vert), // 3-dot icon
                                    // )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            
            
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> editDeleteDiolog(BuildContext context, String expenseId) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16), // Adjust side padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Height as per content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Action',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border.all(
                              color: Colors.grey,
                              width: 1), // Border color and width
                          borderRadius: BorderRadius.circular(
                              50), // Corner radius, adjust as needed
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.primary, // Use your color
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    //Navigate to Edit Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseEdit(expenseId: expenseId),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Edit',
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                // const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog(context, expenseId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Delete',
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Expense',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this Expense?',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // await Provider.of<ExpenseProvider>(context, listen: false)
              //     .deleteExpense(expenseId.toString());

              // Navigator.of(context).pop(); // Close dialog

              final provider =
                  Provider.of<ExpenseProvider>(context, listen: false);
              await provider.deleteExpense(expenseId.toString());
              await provider.fetchExpenseList(); // ✅ Re-fetch the latest list
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
