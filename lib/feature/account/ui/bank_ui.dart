import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Bank extends StatefulWidget {
  const Bank({super.key});

  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> {
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
      backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All A/C",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Bank',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "A/C Name",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add)),
              SizedBox(
                width: 5,
              ),
              Text(
                "Add Balance",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
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
                                  border:
                                      Border.all(color: Colors.grey.shade100),
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
                                  border:
                                      Border.all(color: Colors.grey.shade100),
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
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
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

                ///Sales
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffe3e7fa),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          ///left side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "01/05,2025",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Sales",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "PT Cash",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),

                          Spacer(),

                          //right side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sal/4581",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Amount",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //

                                  Text(
                                    "550",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                ///Purchase
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffe3e7fa),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          ///left side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "01/05,2025",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Received",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "PT Cash",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),

                          Spacer(),

                          //right side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sal/4581",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Amount",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //

                                  Text(
                                    "550",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                ///Sales
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffe3e7fa),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          ///left side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "01/05,2025",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Payment",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Cash",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ],
                          ),

                          Spacer(),

                          //right side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sal/4581",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Amount",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //

                                  Text(
                                    "550",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ///Bottom
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffe3e7fa),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          ///left side
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Opening: 1000",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Debit: 5000",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          Spacer(),

                          //bottom
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Credit: 20,000",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                "Closing: 40,000",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          Text(
                            "",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ],
        ));
  }
}
