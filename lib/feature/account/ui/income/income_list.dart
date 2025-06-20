import 'package:cbook_dt/feature/account/ui/income/add_income.dart';
import 'package:cbook_dt/feature/account/ui/income/income_edit.dart';
import 'package:cbook_dt/feature/account/ui/income/provider/income_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  @override
  void initState() {
    super.initState();
    Provider.of<IncomeProvider>(context, listen: false).fetchIncomeList();
  }

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
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: const Column(
            children: [
              SizedBox(
                width: 5,
              ),
              Text(
                'Income',
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IncomeCreate()));
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
                Consumer<IncomeProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.incomeModel == null ||
                        provider.incomeModel!.data.isEmpty) {
                      return const Center(child: Text('No Income Found'));
                    }

                    final incomes = provider.incomeModel!.data;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: incomes.length,
                      itemBuilder: (context, index) {
                        final income = incomes[index];
                        final incomeId = income.id
                            .toString(); // ✅ Correct: get the ID directly from the list item

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffe3e7fa),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  /// Left side
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Received To",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        income.receivedTo.toLowerCase() ==
                                                'cash'
                                            ? 'Cash In Hand'
                                            : income.receivedTo.toLowerCase() ==
                                                    'bank'
                                                ? 'Bank'
                                                : income.receivedTo,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        income.accountId == 1
                                            ? 'Cash'
                                            : income.accountId == 11
                                                ? 'PTCash'
                                                : income.accountId == 10
                                                    ? 'PTCash'
                                                    : income.accountId == 13
                                                        ? 'Cash 1'
                                                        : income.accountId == 15
                                                            ? 'Cash 2'
                                                            : '${income.accountId}', // Show ID if not matched
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),

                                  /// Right side
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            income.voucherDate,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            income.voucherNumber,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            income.totalAmount.toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (String choice) {
                                          if (choice == 'edit') {
                                            // Navigate to Edit Page
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) => IncomeEdit(
                                            //         incomeId: incomeId),
                                            //   ),
                                            // );
                                          } else if (choice == 'delete') {
                                            // Show Delete Confirmation Dialog
                                            _showDeleteDialog(
                                                context, incomeId);
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
                                            textStyle:
                                                TextStyle(color: Colors.red),
                                            child: Text('Delete'),
                                          ),
                                        ],
                                        icon: const Icon(
                                            Icons.more_vert), // 3-dot icon
                                      )
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

            ///Bottom
          ],
        ));
  }

  void _showDeleteDialog(BuildContext context, String incomeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Income',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this income?',
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

class AccountModel {
  final int id;
  final String accountName;

  AccountModel({required this.id, required this.accountName});
}
