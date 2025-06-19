import 'dart:convert';
import 'package:cbook_dt/common/item_details_pop_up.dart';
import 'package:cbook_dt/common/item_details_pop_up_two.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ItemDetailsView extends StatefulWidget {
  final int itemId;

  const ItemDetailsView({super.key, required this.itemId});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  bool isLoading = true;
  Map<String, dynamic>? itemDetails;
  List<dynamic> purchaseDetails = [];
  final String baseUrl = "https://commercebook.site/";

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
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    final String apiUrl =
        "https://commercebook.site/api/v1/item/show/${widget.itemId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          itemDetails = data['data']['item_name'];
          purchaseDetails = itemDetails?['pruchase_details'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load item details")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Column(
          children: [
            Text(
              'Item Details',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemDetails == null
              ? const Center(child: Text("No data available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ///===>>>Image , text, and 5 icon
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(4)),
                                  height: 95,
                                  width: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      "$baseUrl${itemDetails!['image'] ?? ''}",
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                            "assets/image/cbook_logo.png",
                                            fit: BoxFit.fill);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 130,
                                  child: Center(
                                    child: Text(
                                      "1 Box = 10 Pc",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showItemDetailsDialog(context);
                                      },
                                      child: const Icon(
                                        Icons.info,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.help,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const Icon(
                                      Icons.info,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const Icon(
                                      Icons.help,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                    const Icon(
                                      Icons.info,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const Icon(
                                      Icons.help,
                                      color: Colors.brown,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            ///item name, vat/tex, exclusive, inclusive
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("${itemDetails!['name']}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            ItemDetailsPopUpTwo(
                                              leftTest: "Vat/Tax 15%",
                                              rightText: 'Exclusive',
                                              last: "Inclusive",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "Pur Price",
                                              rightText: '100',
                                              last: "120",
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "Sales. Price",
                                              rightText: '120',
                                              last: "140",
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "Discount",
                                              rightText: '5%',
                                              last: " ",
                                            ),
                                            ItemDetailsPopUpTwo(
                                              leftTest: "MRP",
                                              rightText: '145',
                                              last: "",
                                            ),
                                          ],
                                        )

                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.start,
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //   children: [
                                        //     ///===>>>vat,default price, seal, discount, mrp price
                                        //     Column(
                                        //       crossAxisAlignment:
                                        //           CrossAxisAlignment.start,
                                        //       children: [
                                        //         Container(
                                        //           decoration: const BoxDecoration(
                                        //               color: Colors.green),
                                        //           child: const Padding(
                                        //             padding: EdgeInsets.symmetric(
                                        //                 horizontal: 6.0),
                                        //             child: Text(
                                        //               "Vat/Tax:     15%",
                                        //               style: TextStyle(
                                        //                   color: Colors.white,
                                        //                   fontSize: 12,
                                        //                   fontWeight:
                                        //                       FontWeight.bold),
                                        //             ),
                                        //           ),
                                        //         ),
                                        //         const Text(
                                        //           "Def P.Price", //${itemDetails!['sales_price'] ?? 'N/A'}
                                        //           style: TextStyle(
                                        //               color: Colors.black,
                                        //               fontSize: 12),
                                        //         ),
                                        //         const Text(
                                        //           "Def S.Price", //${itemDetails!['sales_price'] ?? 'N/A'}
                                        //           style: TextStyle(
                                        //               color: Colors.black,
                                        //               fontSize: 12),
                                        //         ),
                                        //         const Text(
                                        //           "Def Discount",
                                        //           style: TextStyle(
                                        //               color: Colors.black,
                                        //               fontSize: 12),
                                        //         ),
                                        //         const Text(
                                        //           "MRP", //${itemDetails!['mrp_price'] ?? 'N/A'}
                                        //           style: TextStyle(
                                        //               color: Colors.black,
                                        //               fontSize: 12),
                                        //         ),
                                        //       ],
                                        //     ),

                                        //     // spacing before divider

                                        //     // Divider (horizontal line)
                                        //     Container(
                                        //       height: 80,
                                        //       width: 2,
                                        //       color: Colors.grey[300],
                                        //       margin: const EdgeInsets.symmetric(
                                        //           horizontal: 6),
                                        //     ),

                                        //     ///excclusive
                                        //     Column(
                                        //       crossAxisAlignment:
                                        //           CrossAxisAlignment.center,
                                        //       mainAxisAlignment:
                                        //           MainAxisAlignment.center,
                                        //       children: [
                                        //         Container(
                                        //           decoration: const BoxDecoration(
                                        //               color: Colors.green),
                                        //           child: const Padding(
                                        //             padding: EdgeInsets.symmetric(
                                        //                 horizontal: 6.0),
                                        //             child: Text("Exc",
                                        //                 style: TextStyle(
                                        //                     color: Colors.white,
                                        //                     fontSize: 12,
                                        //                     fontWeight:
                                        //                         FontWeight.bold)),
                                        //           ),
                                        //         ),
                                        //         const Text(""),
                                        //         const Align(
                                        //           alignment: Alignment.center,
                                        //           child: Text(
                                        //             "100",
                                        //             style: TextStyle(
                                        //                 color: Colors.black,
                                        //                 fontSize: 12,
                                        //                 fontWeight:
                                        //                     FontWeight.bold),
                                        //           ),
                                        //         ),
                                        //         const Align(
                                        //           alignment: Alignment.center,
                                        //           child: Text(
                                        //             "5 %",
                                        //             style: TextStyle(
                                        //                 color: Colors.black,
                                        //                 fontSize: 12,
                                        //                 fontWeight:
                                        //                     FontWeight.bold),
                                        //           ),
                                        //         )
                                        //       ],
                                        //     ),

                                        //     ///===>>> divider
                                        //     Container(
                                        //       height: 80,
                                        //       width: 2,
                                        //       color: Colors.grey[300],
                                        //       margin: const EdgeInsets.symmetric(
                                        //           horizontal: 6),
                                        //     ),

                                        //     ///===>>>inc
                                        //     Column(
                                        //       crossAxisAlignment:
                                        //           CrossAxisAlignment.center,
                                        //       mainAxisAlignment:
                                        //           MainAxisAlignment.center,
                                        //       children: [
                                        //         Container(
                                        //           decoration: const BoxDecoration(
                                        //               color: Colors.green),
                                        //           child: const Padding(
                                        //             padding: EdgeInsets.symmetric(
                                        //                 horizontal: 6.0),
                                        //             child: Text("Inc.",
                                        //                 style: TextStyle(
                                        //                     color: Colors.white,
                                        //                     fontSize: 12,
                                        //                     fontWeight:
                                        //                         FontWeight.bold)),
                                        //           ),
                                        //         ),
                                        //         const Text(""),
                                        //         const Align(
                                        //           alignment: Alignment.center,
                                        //           child: Text(
                                        //             "120",
                                        //             style: TextStyle(
                                        //                 color: Colors.black,
                                        //                 fontSize: 12,
                                        //                 fontWeight:
                                        //                     FontWeight.bold),
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ],
                                        // ),
                                        ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),

                        //// start date v, end date, dropdown,
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              color: Colors.green),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: GestureDetector(
                                    onTap: () => _selectDate(
                                        context, selectedStartDate, (date) {
                                      setState(() {
                                        selectedStartDate = date;
                                      });
                                    }),
                                    child: Container(
                                      height: 30,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade100),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
                                            style: GoogleFonts.notoSansPhagsPa(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 14),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),
                                Text("To",
                                    style: GoogleFonts.notoSansPhagsPa(
                                        fontSize: 14, color: Colors.white)),
                                const SizedBox(width: 8),
                                // End Date Picker
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: GestureDetector(
                                    onTap: () => _selectDate(
                                        context, selectedEndDate, (date) {
                                      setState(() {
                                        selectedEndDate = date;
                                      });
                                    }),
                                    child: Container(
                                      height: 30,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
                                            style: GoogleFonts.notoSansPhagsPa(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 14),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                // Dropdown
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: SizedBox(
                                    height: 30,
                                    child: DropdownButtonFormField<String>(
                                      // decoration: InputDecoration(
                                      //   contentPadding:
                                      //       const EdgeInsets.symmetric(
                                      //           horizontal: 0),
                                      //   border: OutlineInputBorder(

                                      //     borderRadius:
                                      //         BorderRadius.circular(4),
                                      //     borderSide: const BorderSide(
                                      //       color: Colors.grey,
                                      //     ),
                                      //   ),
                                      // ),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 0),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade400),
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
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Text(value,
                                                style:
                                                    GoogleFonts.notoSansPhagsPa(
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

                        ///===>>> this section no need
                        // Text("Name: ${itemDetails!['name']}",
                        //     style: const TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.black)),
                        // const SizedBox(height: 5),
                        // Text(
                        //   "Unit: ${itemDetails!['unit_id'] ?? 'N/A'}",
                        //   style: const TextStyle(
                        //       color: Colors.black, fontSize: 12),
                        // ),
                        // Text("MRP: ${itemDetails!['mrp_price'] ?? 'N/A'}",
                        //     style: const TextStyle(
                        //         color: Colors.black, fontSize: 12)),
                        // Text(
                        //     "Purchase Price: ${itemDetails!['purchase_price'] ?? 'N/A'}",
                        //     style: const TextStyle(
                        //         color: Colors.black, fontSize: 12)),
                        // Text(
                        //     "Sales Price: ${itemDetails!['sales_price'] ?? 'N/A'}",
                        //     style: const TextStyle(
                        //         color: Colors.black, fontSize: 12)),
                        // Text(
                        //     "Opening Date: ${itemDetails!['opening_date'] ?? 'N/A'}",
                        //     style: const TextStyle(
                        //         color: Colors.black, fontSize: 12)),

                        ///===>>>item details section
                        const Text("Item Details:",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        purchaseDetails.isEmpty
                            ? const Center(
                                child: Text("No details available.",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14)),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: purchaseDetails.length,
                                itemBuilder: (context, index) {
                                  var detail = purchaseDetails[index];

                                  String capitalize(String text) {
                                    if (text.isEmpty) return text;
                                    return text[0].toUpperCase() +
                                        text.substring(1);
                                  }

// Inside your build method:
                                  Text(
                                    capitalize(detail['type'] ?? ''),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                  return Container(
                                    //elevation: 2,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),

                                      ///===>>> type, store name, date, billl
                                      title: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //type, store name,
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
// Inside your build method:
                                              Text(
                                                capitalize(
                                                    detail['type'] ?? ''),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const Text("Farabi Store",
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                            ],
                                          ),

                                          ///===>>> date, invoice
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text("01/05/2025",
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              Text("${detail['bill_number']}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      subtitle: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Bill Qty: 18 Pc",
                                              style: TextStyle(fontSize: 12)),
                                          const Text("Price: 55",
                                              style: TextStyle(fontSize: 12)),
                                          Text("Bill: ${detail['sub_total']}",
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }

  void showItemDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 270,
            decoration: BoxDecoration(
              color: const Color(0xffe7edf4),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  color: Colors.yellow,
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
                        children:   [
                          SizedBox(width: 5),
                          Text(
                            "Item Information",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // Cancel icon on the right
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.cancel,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Code/SKU/HSN",
                        rightText: ' ',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Model No",
                        rightText: ' ',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Barcode",
                        rightText: ' ',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Unit",
                        rightText: '1 box = 10',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Category",
                        rightText: 'Light',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Sub Category",
                        rightText: 'Gadget',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Brand",
                        rightText: 'Vision',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Opening Date",
                        rightText: '01/01/2025',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "current Stock Qty",
                        rightText: '2.5 Box',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Secondary Stock Qty",
                        rightText: '25 Pc',
                      ),
                      ItemDetailsPopUp(
                        leftTest: "Current Unit Value",
                        rightText: '155',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
