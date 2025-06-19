import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:cbook_dt/feature/paymentout/create_payment_out_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaymentOutList extends StatefulWidget {
  const PaymentOutList({super.key});

  @override
  State<PaymentOutList> createState() => _PaymentOutListState();
}

class _PaymentOutListState extends State<PaymentOutList> {
  @override
  void initState() {
    super.initState();
  }

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);
  TextStyle ts2 =
      const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              SizedBox(
                width: 5,
              ),
              Text(
                'Payment out',
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
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentOutCreateItem()));
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
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          // Start Date Picker
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: GestureDetector(
                              onTap: () => _selectDate(
                                  context, selectedStartDate, (date) {
                                setState(() {
                                  selectedStartDate = date;
                                });
                              }),
                              child: Container(
                                height: 30,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  // border:
                                  //     Border.all(color: Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
                                      style: GoogleFonts.notoSansPhagsPa(
                                          fontSize: 12, color: Colors.black),
                                    ),
                                    const Icon(Icons.calendar_today, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("To",
                              style: GoogleFonts.notoSansPhagsPa(
                                  fontSize: 14, color: Colors.black)),
                          const SizedBox(width: 8),

                          // End Date Picker
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: GestureDetector(
                              onTap: () =>
                                  _selectDate(context, selectedEndDate, (date) {
                                setState(() {
                                  selectedEndDate = date;
                                });
                              }),
                              child: Container(
                                height: 30,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  // border:
                                  //     Border.all(color: Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
                                      style: GoogleFonts.notoSansPhagsPa(
                                          fontSize: 12, color: Colors.black),
                                    ),
                                    const Icon(Icons.calendar_today, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          const Spacer(),

                          // Dropdown
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: SizedBox(
                              height: 30,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade100)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                value: selectedDropdownValue,
                                hint: const Text(""),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDropdownValue = newValue;
                                  });
                                },
                                items: [
                                  "All",
                                  "Purchase",
                                  "Sale",
                                  "P. Return",
                                  "S. Return"
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text(value,
                                          style: GoogleFonts.notoSansPhagsPa(
                                              fontSize: 12,
                                              color: Colors.black)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),

                //////new item
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Optional: if it's inside another scroll view
                  itemCount: 2, // Example: Two cards
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 1), // 🔥 Reduced vertical gap
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation:
                            1, // 🔥 Slightly lower elevation to make it look tighter
                        margin: const EdgeInsets.only(
                            bottom: 2), // 🔥 Remove default margin
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 6.0), // 🔥 Tightened internal padding
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Side
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Received To
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Payment To', style: ts2),
                                              Text('Cash In Hand', style: ts),
                                              Text('Cash', style: ts),
                                            ],
                                          ),
                                        ),
                                        // Received From
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Payment From', style: ts2),
                                              Text('Farbi Store', style: ts),
                                              Text('01778344090', style: ts),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Right Side
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('01/05/2025', style: ts),
                                      Text('Rec/4581', style: ts),
                                      const SizedBox(height: 5),
                                      Text('550', style: ts2),
                                    ],
                                  ),
                                  // const Icon(Icons.more_vert,
                                  //     size: 28), // 🔥 Slightly smaller icon

                                  PopupMenuButton<String>(
                                    onSelected: (String choice) {
                                      if (choice == 'edit') {
                                        // Navigate to Edit Page
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => ExpenseEdit(
                                        //         expenseId: expenseId),
                                        //   ),
                                        // );
                                      } else if (choice == 'delete') {
                                        // Show Delete Confirmation Dialog
                                        //_showDeleteDialog(context, expenseId);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        textStyle:
                                            TextStyle(color: Colors.blue),
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        textStyle: TextStyle(color: Colors.red),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    icon: const Icon(
                                        Icons.more_vert), // 3-dot icon
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            ///Bottom
          ],
        ));
  }

  void _showDeleteDialog(BuildContext context, String incomeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete payment out',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this payemnt out?',
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
              final provider =
                  Provider.of<IncomeProvider>(context, listen: false);
              await provider.deleteIncome(incomeId.toString());
              await provider
                  .fetchReceiptFromList(); // ✅ Re-fetch the latest list
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
