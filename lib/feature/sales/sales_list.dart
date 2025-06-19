import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/purchase/provider/purchase_provider.dart';
import 'package:cbook_dt/feature/sales/provider/sales_provider.dart';
import 'package:cbook_dt/feature/sales/sales_details.dart';
import 'package:cbook_dt/feature/sales/sales_update.dart';
import 'package:cbook_dt/feature/sales/sales_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesScreen extends StatefulWidget {
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is initialized
    Future.delayed(Duration.zero, () {
      Provider.of<PurchaseProvider>(context, listen: false).fetchPurchases();

      final purchaseProvider =
          Provider.of<PurchaseProvider>(context, listen: false);
      purchaseProvider.fetchItems();

      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      salesProvider.fetchSales();
      _searchController.addListener(() {
        salesProvider.filterSales(_searchController.text);
      });
    });
  }

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

  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  //DateTime selectedStartDate = DateTime.now(); // Default to current date
  DateTime selectedEndDate = DateTime.now();

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  final TextEditingController _searchController = TextEditingController();

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider(
      create: (_) => SalesProvider()
        ..fetchSales()
        ..fetchItems(),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: isSearching
              ? Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 35,
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        cursorHeight: 15,
                        cursorColor: Colors.white,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: ' ',
                          hintStyle: const TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          fillColor: Colors.grey.shade100,
                          isDense: true,
                        ),
                        onChanged: (value) {
                          Provider.of<SalesProvider>(context, listen: false)
                              .filterSales(value);
                          // Your filter logic
                        },
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Sales List',
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                ),
          leading: const BackButton(color: Colors.white),
          backgroundColor: colorScheme.primary,
          actions: [
            // Search or Close Icon with circular background
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isSearching = !isSearching;
                    if (!isSearching) {
                      searchController.clear();
                    }
                  });
                },
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: isSearching ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                    border: isSearching
                        ? null
                        : Border.all(color: Colors.white, width: 2),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isSearching = !isSearching;
                        if (!isSearching) {
                          searchController.clear();
                          Provider.of<SalesProvider>(context, listen: false)
                              .resetFilter();
                        }
                      });
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        isSearching ? Icons.close : Icons.search,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                  // IconButton(
                  //   iconSize: 16, // Set icon size here
                  //   color: Colors.white, // Icon color
                  //   icon: Icon(isSearching ? Icons.close : Icons.search),
                  //   onPressed: () {
                  //     setState(() {
                  //       isSearching = !isSearching;
                  //       if (!isSearching) {
                  //         searchController.clear();
                  //         Provider.of<SalesProvider>(context, listen: false)
                  //             .resetFilter();
                  //       }
                  //     });
                  //   },
                  // ),
                ),

                //Container(
                //   decoration: BoxDecoration(
                //     color: isSearching ? Colors.red : Colors.green,
                //     shape: BoxShape.circle,
                //     border: isSearching
                //         ? null
                //         : Border.all(color: Colors.white, width: 2),
                //   ),
                //   padding: const EdgeInsets.all(6),
                //   child: IconButton(
                //     iconSize: 16,
                //     color: Colors.white,
                //     icon: Icon(isSearching ? Icons.close : Icons.search),
                //     onPressed: () {
                //       setState(() {
                //         isSearching = !isSearching;
                //         if (!isSearching) {
                //           searchController.clear();
                //           Provider.of<SalesProvider>(context, listen: false)
                //               .resetFilter();
                //         }
                //       });
                //     },
                //   ),

                //   // Icon(
                //   //   isSearching ? Icons.close : Icons.search,
                //   //   color: Colors.white,
                //   //   size: 16,
                //   // ),
                // ),
              ),
            ),

            // Bill Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesView(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white,
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Bill',
                      style: TextStyle(color: Colors.yellow, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            ///amount, due, date, bill, qty
            Container(
              color: const Color(0xffdddefa),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ////date, current date, bill qty
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ///month start date
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.23,
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
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
                                          style: GoogleFonts.notoSansPhagsPa(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today,
                                          size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Text("-",
                                style: GoogleFonts.notoSansPhagsPa(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 8),
                            // current date Picker
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: GestureDetector(
                                onTap: () => _selectDate(
                                    context, selectedEndDate, (date) {
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
                                        Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
                                          style: GoogleFonts.notoSansPhagsPa(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today,
                                          size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),

                        ///bill qty
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            "Bill Qty: 5",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    //amount, due
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Amount: 12,50,36,589.00",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Text(
                          "Due: 10,85,99,782.00",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            //show here all a sales. ===== >
            Expanded(
              child: Consumer<SalesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Show loading indicator when deleting a sale
                  if (provider.isDeleting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (provider.sales.isEmpty) {
                    return const Center(
                      child: Text("No sales data available",
                          style: TextStyle(color: Colors.black)),
                    );
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.sales.length,
                      itemBuilder: (context, index) {
                        final sale = provider.sales[index];

                        final sale2 = sale.purchaseDetails.isNotEmpty
                            ? sale.purchaseDetails.first.purchaseId
                            : null;

                        return InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => SalesDetails(sale: sale),
                            //   ),
                            // );
                          },
                          child: Card(
                            color: const Color(0xfff4f6ff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  2), // 👈 Rounded corners (radius: 2)
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 1),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //CircleAvatar(child: Text('${index+1}'),),

                                  const SizedBox(
                                    height: 5,
                                  ),
                                  // Left Side Info
                                  Expanded(
                                    child: InkWell(
                                      onTap: (){
                                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SalesDetails(sale: sale),
                              ),
                            );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ///date, bill qty
                                          ///
                                          Row(
                                            children: [
                                              ///date and invoice number
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    formatDate(sale.purchaseDate),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${sale.billNumber}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                      
                                              ///horozontal divider
                                              //Divider (horizontal line)
                                              Container(
                                                height: 30,
                                                width: 2,
                                                color: Colors.green.shade200,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                              ),
                                      
                                              //cash andf amount
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ///cash
                                                  Text(
                                                    sale.customerName == "N/A"
                                                        ? "Cash"
                                                        : sale.customerName,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12),
                                                  ),
                                      
                                                  //amount
                                                  Text(
                                                    '${sale.grossTotal} TK',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Right Side Info
                                  InkWell(
                                    onTap: () {},
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(height: 4),
                                        //> status, /=>edit  and delete button
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            //paid, due amount
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                //paid, unpaid
                                                Container(
                                                  child: Text(
                                                    sale.transectionMethod
                                                                .toLowerCase() ==
                                                            'cash'
                                                        ? 'Paid'
                                                        : 'Partial',
                                                    style: TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight.bold,
                                                        fontSize: 12,
                                                        color: sale.transectionMethod
                                                                    .toLowerCase() ==
                                                                "cash"
                                                            ? Colors.green
                                                            : Colors.amber),
                                                  ),
                                                ),

                                                sale.transectionMethod
                                                            .toLowerCase() !=
                                                        'cash'
                                                    ? Text(
                                                        "Due: ${sale.grossTotal} TK", // Show due amount here
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          // fontWeight:
                                                          //     FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),

                                            const SizedBox(width: 4),

                                            SizedBox(
                                              height: 20,
                                              width: 40,
                                              child: PopupMenuButton(
                                                iconSize: 30,
                                                //offset: const Offset(0, 40),
                                                position:
                                                    PopupMenuPosition.under,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context) {
                                                  List<PopupMenuEntry<String>>
                                                      items = [];

                                                  if (sale.disabled ==
                                                      'enable') {
                                                    items.add(
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit,
                                                                color: Colors
                                                                    .blue),
                                                            SizedBox(width: 5),
                                                            Text('Edit',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  items.add(
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          SizedBox(width: 5),
                                                          Text('Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ],
                                                      ),
                                                    ),
                                                  );

                                                  return items;
                                                },
                                                onSelected: (value) {
                                                  if (value == 'edit' &&
                                                      sale2 != null) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            salesUpdateScreen(
                                                                salesId: sale2),
                                                      ),
                                                    );
                                                  } else if (value == 'edit') {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "No purchase ID available for this sale"),
                                                      ),
                                                    );
                                                  }

                                                  if (value == 'delete') {
                                                    conformDelete(
                                                        context, sale2!);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> conformDelete(context, int saleId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
            "Are you sure you want to delete this sale?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Call your delete function here
                Provider.of<SalesProvider>(context, listen: false).deleteSale(
                  saleId,
                );
                Navigator.pop(context);

                debugPrint("Sale deleted"); // Replace with actual delete logic
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showFeatureNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Not Available'),
        content: const Text(
          'This feature is not available right now.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
