import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/party/add_supplier_customer.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:cbook_dt/feature/suppliers/supplier_update.dart';
import 'package:cbook_dt/feature/suppliers/supplies_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Party extends StatefulWidget {
  const Party({super.key});

  @override
  State<Party> createState() => _PartyState();
}

class _PartyState extends State<Party> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers());

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomsr());
  }

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of forms with metadata

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title:

              // Row(
              //   children: [

              //     //search text field
              //           if (isSearching)
              //             Expanded(
              //               child: Row(
              //                 children: [
              //                   Expanded(
              //                     child: SizedBox(
              //                       height: 30,
              //                       child: TextField(
              //                         cursorHeight: 15,
              //                         controller: searchController,
              //                         autofocus: true,
              //                         style: const TextStyle(
              //                             color: Colors.white, fontSize: 12),
              //                         decoration: InputDecoration(
              //                           hintText: '',
              //                           border: OutlineInputBorder(
              //                             borderRadius: BorderRadius.circular(6),

              //                           ),

              //                           contentPadding: const EdgeInsets.symmetric(
              //                               horizontal: 8, vertical: 2),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   IconButton(
              //                     icon: const Icon(Icons.close),
              //                     onPressed: () {
              //                       setState(() {
              //                         isSearching = false;
              //                         searchController.clear();
              //                       });
              //                     },
              //                   ),
              //                 ],
              //               ),
              //             )
              //           else ...[
              //             Expanded(
              //               child: Align(
              //                 alignment: Alignment.centerLeft,
              //                 child: GestureDetector(
              //                   onTap: () {
              //                     setState(() {
              //                       isSearching = true;
              //                     });
              //                   },
              //                   child: Container(
              //                     decoration: BoxDecoration(
              //                       border: Border.all(color: Colors.blue),
              //                       borderRadius: BorderRadius.circular(50),
              //                     ),
              //                     child: const CircleAvatar(
              //                       radius: 14,
              //                       backgroundColor: Colors.white,
              //                       child: Icon(Icons.search, color: Colors.blue),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),

              //           ],

              //     const Text(
              //       'Party',
              //       style: TextStyle(
              //           color: Colors.yellow,
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold),
              //     ),

              //    IconButton(onPressed: (){

              //                   Navigator.push(
              //                       context,
              //                       MaterialPageRoute(
              //                           builder: (context) =>
              //                               const AddSupplierCustomer()));

              //    }, icon: Icon(Icons.add))

              //   ],
              // ),

              Row(
            children: [
              // If searching: Show search field (left side)
              if (isSearching)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              //filled: true,
                              fillColor: Colors.green,

                              hintText: '',
                              hintStyle: TextStyle(fontSize: 12),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            isSearching = false;
                            searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                )
              else
                // If not searching: Show search icon + Party text + Add icon
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center: Party title
                      const Center(
                        child: Text(
                          'Party',
                          style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Left: Search icon
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = true;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.search,
                                  color: Colors.green, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Always visible: Add icon
              IconButton(
                icon: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  
                  child: const Icon(Icons.add, color: Colors.green)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSupplierCustomer(),
                    ),
                  );
                },
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Container(
              //padding: EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xffdddefa),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left (Customer)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(Icons.handshake, color: Colors.blue),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer: 560",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12)),
                          Text("10,01,55,320",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  // Vertical Divider
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.green.shade800,
                    margin: EdgeInsets.symmetric(horizontal: 12),
                  ),

                  // Right (Supplier)
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Supplier: 102",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12)),
                            Text("10,01,55,320",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child:
                  //search, purchase, sales
                  Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
                child: Row(
                  children: [],
                ),
              ),
            ),

            //customer or supplier
            Container(
              //color: Colors.red,
              child: Expanded(
                child: Consumer<SupplierProvider>(
                  builder: (context, supplierProvider, child) {
                    if (supplierProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (supplierProvider.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          supplierProvider.errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }

                    // final suppliers =
                    //     supplierProvider.supplierResponse?.data.values.toList() ?? [];

                    final suppliers =
                        supplierProvider.supplierResponse?.data ?? [];

                    if (suppliers.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Suppliers Found",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        final supplierPurchase = suppliers[index].purchases;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SupplierDetailsScreen(
                                  supplierId: supplier.id,
                                  purchases: supplierPurchase,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            elevation: 1,
                            //margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/image/cbook_logo.png"),
                              ),
                              title: Text(
                                supplier.name,
                                style: const TextStyle(
                                   fontFamily: 'Calibri',
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.proprietorName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey[800], fontSize: 12),
                                  ),
                                  Text(
                                    "01759546853",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey[800], fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 140, // Adjust width as needed
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.red[700],
                                    ),

                                    // Icon(
                                    //   Icons.keyboard_control_key,
                                    //   color: Colors.red[700],
                                    // ),
                                    Text(
                                      "${supplier.due}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    PopupMenuButton<String>(
                                      position: PopupMenuPosition.under,
                                      onSelected: (value) async {
                                        if (value == 'Edit') {
                                          final supplierProvider =
                                              Provider.of<SupplierProvider>(
                                                  context,
                                                  listen: false);

                                          debugPrint(
                                              "Clicked Edit for Supplier ID: ${supplier.id}");

                                          // Fetch supplier data by ID
                                          final supplierData =
                                              await supplierProvider
                                                  .fetchSupplierById(
                                                      supplier.id);

                                          if (supplierData != null) {
                                            debugPrint(
                                                "Fetched Supplier Data: ${supplierData.id}");

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SupplierUpdate(
                                                        supplier: supplierData),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Failed to fetch supplier details")),
                                            );
                                          }
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text("Delete Supplier"),
                                              content: const Text(
                                                "Are you sure you want to delete this supplier?",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                  child: const Text("Delete",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await Provider.of<SupplierProvider>(
                                                    context,
                                                    listen: false)
                                                .deleteSupplier(supplier.id);
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'Edit',
                                          child: ListTile(
                                            leading: Icon(Icons.edit,
                                                color: Colors.blue),
                                            title: Text('Edit'),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(Icons.delete,
                                                color: Colors.red),
                                            title: Text('Delete'),
                                          ),
                                        ),
                                      ],
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
