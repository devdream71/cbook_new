import 'package:cbook_dt/feature/paymentout/create_payment_out_item.dart';
import 'package:cbook_dt/feature/paymentout/payment_details.dart';
import 'package:cbook_dt/feature/paymentout/payment_out_edit.dart';
import 'package:cbook_dt/feature/paymentout/provider/payment_out_provider.dart';
import 'package:flutter/material.dart';

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
    Future.microtask(() =>
        Provider.of<PaymentVoucherProvider>(context, listen: false)
            .fetchPaymentVouchers());
  }

  TextStyle ts = const TextStyle(color: Colors.black, fontSize: 12);
  TextStyle ts2 = const TextStyle(
      color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///top date start , end and dropdown
          
              Column(
                children: [
                  ////this working, but no need now, start date, end date, dropdown
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
                  //               onTap: () => _selectDate(
                  //                   context, selectedStartDate, (date) {
                  //                 setState(() {
                  //                   selectedStartDate = date;
                  //                 });
                  //               }),
                  //               child: Container(
                  //                 height: 30,
                  //                 padding:
                  //                     const EdgeInsets.symmetric(horizontal: 8),
                  //                 decoration: BoxDecoration(
                  //                   // border:
                  //                   //     Border.all(color: Colors.grey.shade100),
                  //                   borderRadius: BorderRadius.circular(4),
                  //                 ),
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
                  //                 decoration: BoxDecoration(
                  //                   // border:
                  //                   //     Border.all(color: Colors.grey.shade100),
                  //                   borderRadius: BorderRadius.circular(4),
                  //                 ),
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
                  //                         BorderSide(color: Colors.grey.shade200),
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
                  //                               fontSize: 12,
                  //                               color: Colors.black)),
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
          
                  Consumer<PaymentVoucherProvider>(
                      builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
          
                    if (provider.vouchers.isEmpty) {
                      return Center(
                          child: Text(
                        'No Payment Vouchers Found.',
                        style: ts2,
                      ));
                    }
          
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = provider.vouchers[index];
          
                          final voucherId = voucher.id.toString();
          
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 0),
                            child: InkWell(
                              onLongPress: () {
                                editDeleteDiolog(context, voucherId);
                              },
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentDetails()));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0)),
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 2),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              voucher.voucherDate,
                                                              style: ts),
                                                          Text(
                                                              voucher
                                                                  .voucherNumber,
                                                              style: ts),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                              voucher.totalAmount
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: ts2),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Container(
                                                  height: 55,
                                                  width: 2,
                                                  color: Colors.green.shade200,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 6),
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Payment From',
                                                          style: ts2),
                                                      Text('Cash In Hand',
                                                          style: ts),
                                                      Text('Cash', style: ts),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text('Payment To',
                                                          style: ts2),
                                                      Text(voucher.customer,
                                                          style: ts),
                                                      Text('N/A',
                                                          style:
                                                              ts), // Add phone if available
                                                    ],
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
                            ),
                          );
                        });
                  }),
          
                  //////payment out list
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   physics:
                  //       const NeverScrollableScrollPhysics(), // Optional: if it's inside another scroll view
                  //   itemCount: 2, // Example: Two cards
                  //   itemBuilder: (context, index) {
                  //     return Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 2,
                  //           vertical: 0), // 🔥 Reduced vertical gap
                  //       child: InkWell(
                  //         onLongPress: () {
                  //           editDeleteDiolog(context);
                  //         },
                  //         onTap: () {
                  //           Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       const PaymentDetails()));
                  //         },
                  //         child: Card(
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(0)),
                  //           elevation:
                  //               1, // 🔥 Slightly lower elevation to make it look tighter
                  //           margin: const EdgeInsets.only(
                  //               bottom: 2), // 🔥 Remove default margin
                  //           child: Padding(
                  //             padding: const EdgeInsets.symmetric(
                  //                 horizontal: 6.0,
                  //                 vertical: 6.0), // 🔥 Tightened internal padding
                  //             child: Row(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 // Left Side
                  //                 Expanded(
                  //                   child: Column(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Row(
                  //                         crossAxisAlignment:
                  //                             CrossAxisAlignment.start,
                  //                         children: [
                  //                           // Right Side
                  //                           Row(
                  //                             children: [
                  //                               Column(
                  //                                 crossAxisAlignment:
                  //                                     CrossAxisAlignment.start,
                  //                                 children: [
                  //                                   Text('01/05/2025', style: ts),
                  //                                   Text('Rec/4581', style: ts),
                  //                                   const SizedBox(height: 5),
                  //                                   Text('550', style: ts2),
                  //                                 ],
                  //                               ),
                  //                             ],
                  //                           ),
          
                  //                           const SizedBox(
                  //                             width: 5,
                  //                           ),
          
                  //                           //Divider (horizontal line)
                  //                           Container(
                  //                             height: 55,
                  //                             width: 2,
                  //                             color: Colors.green.shade200,
                  //                             margin: const EdgeInsets.symmetric(
                  //                                 horizontal: 6),
                  //                           ),
          
                  //                           const SizedBox(
                  //                             width: 5,
                  //                           ),
          
                  //                           // Received To
                  //                           Expanded(
                  //                             child: Column(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment.start,
                  //                               children: [
                  //                                 Text('Payment From',
                  //                                     style: ts2),
                  //                                 Text('Cash In Hand', style: ts),
                  //                                 Text('Cash', style: ts),
                  //                               ],
                  //                             ),
                  //                           ),
                  //                           // Received From
                  //                           Expanded(
                  //                             child: Column(
                  //                               crossAxisAlignment:
                  //                                   CrossAxisAlignment.end,
                  //                               children: [
                  //                                 Text('Payment To', style: ts2),
                  //                                 Text('Farbi Store', style: ts),
                  //                                 Text('01778344090', style: ts),
                  //                               ],
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
          
              ///Bottom
            ],
          ),
        ));
  }

  Future<dynamic> editDeleteDiolog(BuildContext context, String voucherId) {
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
                    closeButtonIcon(context, colorScheme)
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
                        builder: (context) =>
                              PaymenyOutEdit(paymentOutId: voucherId),
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
                    _showDeleteDialog(context, voucherId);
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

  void _showDeleteDialog(BuildContext context, String voucherId) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete payment Vouchers',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this payemnt Vouchers?',
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
                  Provider.of<PaymentVoucherProvider>(context, listen: false);
              bool isDeleted = await provider.deletePaymentVoucher(voucherId);

              if (isDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                    'Payment voucher deleted successfully!',
                    style: TextStyle(color: colorScheme.primary),
                  )),
                );
                Navigator.of(context).pop(); // Close confirmation dialog
                await provider.fetchPaymentVouchers();
              } else {
                Navigator.of(context).pop(); // Close confirmation dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                    'Failed to delete payment voucher.',
                    style: TextStyle(color: Colors.red),
                  )),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  InkWell closeButtonIcon(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          border: Border.all(
              color: Colors.grey, width: 1), // Border color and width
          borderRadius:
              BorderRadius.circular(50), // Corner radius, adjust as needed
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: 20,
            color: colorScheme.primary, // Use your color
          ),
        ),
      ),
    );
  }
}
