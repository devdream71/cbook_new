import 'package:cbook_dt/feature/purchase_return/presentation/purchase_return_view.dart';
import 'package:cbook_dt/feature/purchase_return/provider/purchase_return_provider.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_details.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseReturnList extends StatefulWidget {
  const PurchaseReturnList({super.key});

  @override
  State<PurchaseReturnList> createState() => _PurchaseReturnListState();
}

class _PurchaseReturnListState extends State<PurchaseReturnList> {
  @override
  void initState() {
    Future.microtask(() {
      Provider.of<PurchaseReturnProvider>(context, listen: false)
          .fetchPurchaseReturns();
    });
    super.initState();
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _confirmDelete(BuildContext context, int purchaseReturnID) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this Purchase Return?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await context
          .read<PurchaseReturnProvider>()
          .deletePurchaseReturn(purchaseReturnID);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Purchase Return Delete successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Purchase Return List",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        backgroundColor: colorScheme.primary,
        leading: const BackButton(color: Colors.white),
        //centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PurchaseReturnView(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    'P. Return',
                    style: TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ],
              ),
            ),
          )

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => const PurchaseReturnView()),
          //       );
          //     },
          //     child: Container(
          //       width: 60,
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          //       decoration: BoxDecoration(
          //         color: Colors.blueAccent,
          //         borderRadius: BorderRadius.circular(8),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.blueAccent.withOpacity(0.4),
          //             blurRadius: 10,
          //             offset: const Offset(0, 4),
          //           ),
          //         ],
          //       ),
          //       child: const Center(
          //         child: Icon(Icons.add_circle_outline,
          //             color: Colors.white, size: 24),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AddSalesFormfield(
                label: "Search",
                controller: _searchController,
                keyboardType: TextInputType.number,
                onChanged: (value) {},
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<PurchaseReturnProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                        child: Text(provider.errorMessage,
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (provider.purchaseReturns.isEmpty) {
                    return const Center(
                        child: Text(
                      "No purchase returns found.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ));
                  }

                  // return ListView.builder(
                  //   itemCount: provider.purchaseReturns.length,
                  //   itemBuilder: (context, index) {
                  //     final item = provider.purchaseReturns[index];

                  //     return InkWell(
                  //         onTap: () {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (_) =>
                  //                   PurchaseReturnDetails(purchaseReturn: item),
                  //             ),
                  //           );
                  //         },
                  //         child: Card(
                  //           margin: const EdgeInsets.symmetric(
                  //               vertical: 8, horizontal: 5),
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(10)),
                  //           child: ListTile(
                  //             contentPadding: const EdgeInsets.only(left: 16),
                  //             subtitle: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   "${item.supplierName}",
                  //                   style: const TextStyle(fontSize: 12),
                  //                 ),
                  //                 Text("Total: ৳ ${item.grossTotal}",
                  //                     style: const TextStyle(fontSize: 12)),
                  //                 const SizedBox(
                  //                   height: 30,
                  //                 ),
                  //                 Text(
                  //                   '${item.purchaseDetails.first.itemId}',
                  //                   style: const TextStyle(
                  //                     color: Colors.amberAccent,
                  //                     fontSize: 14,
                  //                     wordSpacing: 3.0,
                  //                   ),
                  //                 )
                  //               ],
                  //             ),
                  //             trailing: Column(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Text("${item.purchaseDate ?? 'N/A'}",
                  //                     style: const TextStyle(fontSize: 12)),
                  //                 Text("${item.billNumber ?? 'N/A'}",
                  //                     style: const TextStyle(fontSize: 12)),
                  //                 Row(
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   mainAxisAlignment:
                  //                       MainAxisAlignment.spaceAround,
                  //                   children: [
                  //                     Container(
                  //                       decoration: BoxDecoration(
                  //                         color: Colors.yellow.shade400,
                  //                         borderRadius:
                  //                             BorderRadius.circular(10),
                  //                       ),
                  //                       padding: const EdgeInsets.symmetric(
                  //                           vertical: 5, horizontal: 5),
                  //                       child: const Text(
                  //                         'Unpaid',
                  //                         style: TextStyle(
                  //                           fontWeight: FontWeight.bold,
                  //                           fontSize: 14,
                  //                           color: Colors.red,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     SizedBox(
                  //                       height: 20,
                  //                       child: PopupMenuButton<String>(
                  //                         iconSize: 18,
                  //                         position: PopupMenuPosition.under,
                  //                         menuPadding: EdgeInsets.all(0),
                  //                         padding: EdgeInsets.all(0),
                  //                         onSelected: (value) async {
                  //                           if (value == 'Edit') {
                  //                             //debugPrint("Edit Category ID: ${category.id}");
                  //                           } else if (value == 'delete') {
                  //                             //_confirmDelete(context, item.purchaseDetails[index].);
                  //                           }
                  //                         },
                  //                         itemBuilder: (context) => [
                  //                           const PopupMenuItem(
                  //                             value: 'Edit',
                  //                             child: ListTile(
                  //                               leading: Icon(Icons.edit,
                  //                                   color: Colors.blue),
                  //                               title: Text('Edit'),
                  //                             ),
                  //                           ),
                  //                           const PopupMenuItem(
                  //                             value: 'delete',
                  //                             child: ListTile(
                  //                               leading: Icon(Icons.delete,
                  //                                   color: Colors.red),
                  //                               title: Text('Delete'),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                         icon: const Icon(Icons.more_vert),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ));
                  //   },
                  // );

                  return ListView.builder(
                    itemCount: provider.purchaseReturns.length,
                    itemBuilder: (context, index) {
                      final item = provider.purchaseReturns[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PurchaseReturnDetails(purchaseReturn: item),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Supplier and Amount
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.supplierName ?? "N/A",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        "৳ ${item.grossTotal ?? 0}",
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),

                                // Right: Date, Bill, Status, Menu
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      item.billNumber ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    ),

                                    // Text(
                                    //   item.purchaseDate ?? 'N/A',
                                    //   style: const TextStyle(fontSize: 12, color: Colors.black),
                                    // ),

                                    Text(
                                      formatDate(item.purchaseDate),
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),

                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade400,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 6),
                                          child: const Text(
                                            'Unpaid',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.red),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        SizedBox(
                                          height: 20,
                                          width: 15,
                                          child: PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert,
                                                size: 18),
                                            padding: EdgeInsets.zero,
                                            onSelected: (value) {
                                              if (value == 'Edit') {
                                                // handle edit
                                              } else if (value == 'delete') {
                                                //_confirmDelete(context, item.id!);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'Edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    SizedBox(width: 5),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.red),
                                                    SizedBox(width: 5),
                                                    Text('Delete'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
