import 'dart:convert';
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/feature_not_available.dart';
import 'package:cbook_dt/feature/category/item_category_list.dart';
import 'package:cbook_dt/feature/category/sub_category/sub_category_list.dart';
import 'package:cbook_dt/feature/item/add_item.dart';
import 'package:cbook_dt/feature/item/item_details.dart';
import 'package:cbook_dt/feature/item/model/items_show.dart';
import 'package:cbook_dt/feature/item/provider/update_item_provider.dart';
import 'package:cbook_dt/feature/item/update_item.dart';
import 'package:cbook_dt/feature/purchase/purchase_list_api.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_list.dart';
import 'package:cbook_dt/feature/sales/sales_list.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/sales_bulk/sales_bulk.dart';
import 'package:cbook_dt/feature/sales_return/sales_return_list.dart';
import 'package:cbook_dt/feature/unit/unit_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../item/provider/items_show_provider.dart';
import 'package:http/http.dart' as http;

class ItemView extends StatefulWidget {
  const ItemView({super.key});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  @override
  void initState() {
    super.initState();

    // fetchUnits(); // Fetch unit names

    Future.microtask(() {
      final provider = context.read<AddItemProvider>();
      provider.fetchItems().then((_) {
        for (var item in provider.items) {
          provider.fetchStockQuantity(item.id.toString()); // Fetch stock data
        }
      });
      provider.fetchUnits(); // Fetch unit names
    });
  }

  // Map<int, String> unitMap = {}; // Store unitId -> unitName
  Map<int, String> unitMap = {};

  final String base_url = "https://commercebook.site/";

  Future<void> _deleteItem(BuildContext context, int itemId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(context);
    if (!confirmDelete) return;

    final String deleteUrl =
        "https://commercebook.site/api/v1/item/remove?id=$itemId";

    try {
      final response = await http.post(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Item deleted successfully!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh item list
        context.read<AddItemProvider>().fetchItems();
        //xyz
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to delete item",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> fetchUnits() async {
    const String url = "https://commercebook.site/api/v1/units";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final Map<String, dynamic> data = jsonData['data'];

        setState(() {
          unitMap = {
            for (var entry in data.entries)
              int.parse(entry.key): entry.value['name']
          };
        });
      } else {
        debugPrint("Failed to load units");
      }
    } catch (e) {
      debugPrint("Error fetching units: $e");
    }
  }

  

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorTheme.primary,
        centerTitle: true,
        title:   
        
    //     Row(
    //       children: [
    //         Text(
    //           'Item/Product',
    //           style: TextStyle(
    //               color: Colors.yellow,
    //               fontSize: 16,
    //               fontWeight: FontWeight.bold),
    //         ),

    //         IconButton(
    //   icon: const Icon(Icons.add, color: Colors.white),
    //   onPressed: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => const AddItem(),
    //       ),
    //     );
    //   },
    // ),
           
    //       ],
    //     ),

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
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    
                     enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: const BorderSide(color: Colors.white, width: 1),
                
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
                    //filled: true,
                    fillColor: Colors.green,
                    
                    hintText: '',
                    hintStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    
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
                'Item/Product',
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
                  margin: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.search, color: Colors.green, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    // Always visible: Add icon
    IconButton(
      icon: const CircleAvatar(
        radius: 12,
        backgroundColor: Colors.white,
        child:   Icon(Icons.add, color: Colors.green)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddItem(),
          ),
        );
      },
    ),
  ],
),




        automaticallyImplyLeading: false,
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     crossAxisAlignment: CrossAxisAlignment.end,
      //     children: [
      //       //////=====> purchase and sale commit out.

      //       IconButton(
      //         onPressed: () {
      //           showModalBottomSheet(
      //             context: context,
      //             shape: const RoundedRectangleBorder(
      //               borderRadius:
      //                   BorderRadius.vertical(top: Radius.circular(16)),
      //             ),
      //             builder: (context) => _buildBottomSheetContent(context),
      //           );
      //         },
      //         icon: Icon(
      //           Icons.add_circle_outline,
      //           color: colorScheme.primary,
      //           size: 40.0,
      //         ),
      //       ),
      //     ],
      //   ),
      // )

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FocusableActionDetector(
              autofocus: true,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => _buildBottomSheetContent(context),
                  );
                },
                child: Container(
                  width: 50, // Make sure width and height are equal
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
  padding: const EdgeInsets.all(12),
  decoration: const BoxDecoration(
    color: Color(0xffdddefa),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Left (Customer)
      const Row(
        children: [
          Icon(Icons.handshake, color: Colors.blue),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Item", style: TextStyle(color: Colors.black, fontSize: 12)),
              Text("50,000", style: const TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
        ],
      ),

      // Vertical Divider
      Container(
        height: 40,
        width: 1,
        color: Colors.green.shade800,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      ),

      // Right (Supplier)
      const Row(
        children: [
          Icon(Icons.person, color: Colors.blue),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Stock Value", style: TextStyle(color: Colors.black, fontSize: 12)),
              Text("10,01,55,320", style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        ],
      ),
    ],
  ),
),
            
            const SizedBox(
              height: 8,
            ),

            // Row(
            //   children: [
            //     Expanded(
            //       child: SizedBox(
            //         //width: double.maxFinite,
            //         child: ElevatedButton(
            //           onPressed: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => ItemCategoryView()),
            //             );
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColors.primaryColor,
            //             padding: const EdgeInsets.symmetric(
            //                 vertical: 12, horizontal: 20),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //           ),
            //           child: const Text(
            //             "Add Category",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     /////====>add unit.
            //     Expanded(
            //       child: SizedBox(
            //         //width: double.maxFinite,
            //         child: ElevatedButton(
            //           onPressed: () {},
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColors.primaryColor,
            //             padding: const EdgeInsets.symmetric(
            //                 vertical: 12, horizontal: 20),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //           ),
            //           child: const Text(
            //             "Add Subcategory",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: SizedBox(
            //         //width: double.maxFinite,
            //         child: ElevatedButton(
            //           onPressed: () {

            //             //showFeatureNotAvailableDialog(context);
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColors.primaryColor,
            //             padding: const EdgeInsets.symmetric(
            //                 vertical: 12, horizontal: 20),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //           ),
            //           child: const Text(
            //             "Add Item",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     /////====>add unit.
            //     Expanded(
            //       child: SizedBox(
            //         //width: double.maxFinite,
            //         child: ElevatedButton(
            //           onPressed: () {

            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColors.primaryColor,
            //             padding: const EdgeInsets.symmetric(
            //                 vertical: 12, horizontal: 20),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //           ),
            //           child: const Text(
            //             "Add Unit",
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            

            const SizedBox(
              height: 5,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "All Items",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Expanded(
              child: Consumer<AddItemProvider>(
                builder: (context, itemProvider, child) {
                  if (itemProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemProvider.items.isEmpty) {
                    return const Center(
                        child: Text(
                      'No items available.',
                      style: TextStyle(color: Colors.black),
                    ));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 0.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 0),
                            itemCount: itemProvider.items.length,
                            itemBuilder: (context, index) {
                              ItemsModel item = itemProvider.items[index];
                              debugPrint(
                                  "Item from provider: ${item.name}"); // Debugging
                              debugPrint("Item from provider: ${item.id}");

                              int? unitId = int.tryParse(item.unitId
                                  .toString()); // Convert unit_id to int
                              int? secondaryUnitId =
                                  item.secondaryUnitId; // Already an int

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetailsView(itemId: item.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6)),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 1.0, horizontal: 1),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.only(
                                        left: 16, right: 2),
                                    title: Row(
                                      children: [
                                        SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Image.network(
                                              "$base_url${item.image}",
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  "assets/image/cbook_logo.png",
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Spacer(),
                                                  const Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Text(
                                                      '1Box = 12PC',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xff9575CD)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ///===>>>pp
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "P.P",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            "${item.purchasePrice}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  ///===>>>pp
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "S.P",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            "${item.salesPrice}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  ///===>>>pp
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "M.R.P",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            "${item.mrp}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  const Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Stock",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12),
                                                          ),
                                                          FittedBox(
                                                            child: Text(
                                                              "50Bx 600Pc",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Text(
                                              //   "Stock: ${item.openingStock.toString()}",
                                              //   style: const TextStyle(
                                              //       fontSize: 12,
                                              //       color: Colors.black),
                                              // ),
                                              // Text(
                                              //   "Unit:  ${item.openingStock.toString()} ${itemProvider.unitSymbols[unitId] ?? 'N/A'} "
                                              //   "(${item.openingStock.toString()} ${secondaryUnitId != null ? (itemProvider.unitSymbols[secondaryUnitId] ?? '') : 'Pc '})",
                                              //   style: const TextStyle(
                                              //       fontSize: 12,
                                              //       color: Colors.black),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // trailing: PopupMenuButton<String>(
                                    //   onSelected: (value) async {
                                    //     debugPrint("Item ID: ${item.id}");

                                    //     if (value == 'update') {
                                    //       final itemProvider =
                                    //           Provider.of<ItemUpdateProvider>(
                                    //               context,
                                    //               listen: false);

                                    //       // Show loading dialog
                                    //       showDialog(
                                    //         context: context,
                                    //         barrierDismissible: false,
                                    //         builder: (_) => const Center(
                                    //             child:
                                    //                 CircularProgressIndicator()),
                                    //       );

                                    //       // Fetch data before navigating
                                    //       await itemProvider
                                    //           .fetchItemDetails(item.id);

                                    //       // Close the loading dialog
                                    //       Navigator.pop(context);

                                    //       // Navigate to the update screen
                                    //       Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               UpdateItem(itemId: item.id),
                                    //         ),
                                    //       );

                                    //       debugPrint("item data");
                                    //       debugPrint("${item.id}");
                                    //     } else if (value == 'delete') {
                                    //       debugPrint("Delete ${item.name}");
                                    //       _deleteItem(context, item.id);
                                    //     }
                                    //   },
                                    //   itemBuilder: (context) => [
                                    //     const PopupMenuItem(
                                    //       value: 'update',
                                    //       child: ListTile(
                                    //         leading: Icon(Icons.edit,
                                    //             color: Colors.blue),
                                    //         title: Text('Update'),
                                    //       ),
                                    //     ),
                                    //     const PopupMenuItem(
                                    //       value: 'delete',
                                    //       child: ListTile(
                                    //         leading: Icon(Icons.delete,
                                    //             color: Colors.red),
                                    //         title: Text('Delete'),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text(
                "Are you sure you want to delete this item?",
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
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

  Widget _buildBottomSheetContent(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title for Sales Transaction
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (_) => SalesScreen()));

                    _buildBottomSheetContent(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0), // Only vertical padding
                        child: Text(
                          "Sales Transaction",
                          style: GoogleFonts.notoSansPhagsPa(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.yellow,
                            )),
                      ),
                    ],
                  ),
                ),

                // Icons with text in a Wrap for Sales Transaction
                Wrap(
                  spacing: 10,
                  runSpacing: 20,
                  children: [
                    //// Sales/Bill/\nInvoice
                    InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => SalesScreen()));

                          // showFeatureNotAvailableDialog(context);
                        },
                        child: _buildIconWithLabel(Icons.shopping_cart_checkout,
                            "Sales/Bill/\nInvoice", context)),

                    
                  
                     //// bulk sales
                  InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ItemListPage()));

                        // showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(Icons.apps,
                          "Bulk sales/\nInvoice", context)),  
                    
                    
                    //// Estimate/\nQuotation
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.view_timeline, "Estimate/\nQuotation", context),
                    ),

                    //// Challan
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child:
                            _buildIconWithLabel(Icons.tab, "Challan", context)),

                    //// Receipt In
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child: _buildIconWithLabel(
                            Icons.receipt, "Receipt In", context)),

                    ////Sales\nReturn
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SalesReturnScreen())); //SalesReturnView
                        //showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.redo, "Sales\nReturn", context),
                    ),

                    ////Delivery
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child: _buildIconWithLabel(
                            Icons.delivery_dining, "Delivery", context)),
                  ],
                ),

                // Purchase Transaction Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Purchase Transaction",
                    style: GoogleFonts.notoSansPhagsPa(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Wrap(
                  runSpacing: 20,
                  spacing: 10,
                  children: [
                    ////Purchase
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PurchaseListApi()));

                        //showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.add_shopping_cart_rounded, "Purchase", context),
                    ),

                    ////  Purchase/\nOrder
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.work_history, "Purchase/\nOrder", context),
                    ),

                    //// Payment\nOut
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child: _buildIconWithLabel(
                            Icons.tab, "Payment\nOut", context)),

                    ///// Purchase\nReturn
                    InkWell(
                      onTap: () {},
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PurchaseReturnList()));

                          //showFeatureNotAvailableDialog(context);
                        },
                        child: _buildIconWithLabel(
                            Icons.redo_rounded, "Purchase\nReturn", context),
                      ),
                    ),
                  ],
                ),

                // Account Transaction Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Only vertical padding
                  child: Text(
                    "Account Transaction",
                    style: GoogleFonts.notoSansPhagsPa(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                Wrap(
                  runSpacing: 20,
                  spacing: 10,
                  children: [
                    ////Purchase
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.card_travel, "Expense", context),
                    ),

                    ////  Purchase/\nOrder
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.work_history, "Contacts", context),
                    ),

                    //// Payment\nOut
                    InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const FeatureNotAvailableDialog());
                        },
                        child:
                            _buildIconWithLabel(Icons.tab, "Income", context)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithLabel(
      IconData icon, String label, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primaryColor,
            ),
          ),
        ), // Icon size and color
        const SizedBox(height: 4), // Space between icon and text
        Text(
          label,
          style:
              GoogleFonts.notoSansPhagsPa(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
