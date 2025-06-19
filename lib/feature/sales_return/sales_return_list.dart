import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/sales_return/presentation/sales_return_view.dart';
import 'package:cbook_dt/feature/sales_return/provider/sale_return_provider.dart';
import 'package:cbook_dt/feature/sales_return/sales_return_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SalesReturnProvider>(context, listen: false).fetchSalesReturn();
    final provider = Provider.of<SalesReturnProvider>(context, listen: false);
    provider.fetchSalesReturn();
    provider.fetchItems();
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SalesReturnProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sales Return list",
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
                    builder: (context) => const SalesReturnView()),
              );
            },
            child: const Padding(
              padding:   EdgeInsets.only(right: 8.0),
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
                    'Sales Return',
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
          //             builder: (context) => const SalesReturnView()),
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
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            provider.isLoading
                ? const CircularProgressIndicator()
                : provider.salesReturns.isEmpty
                    ? const Center(
                        child: Text("No sales return data available.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: provider.salesReturns.length,
                          itemBuilder: (context, index) {
                            final item = provider.salesReturns[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesReturnDetailsPage(
                                        salesReturn: item),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                margin: const EdgeInsets.all(10),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(left: 16),

                                  title: Text(
                                    "Bill: ${item.billNumber}\nItem: ${provider.getItemName(item.purchaseDetails.first.itemId)}",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "Supplier: ${item.supplierName} \nTotal: ৳ ${item.grossTotal} \nDate: ${item.purchaseDate}",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  //trailing: const Icon(Icons.arrow_forward_ios),
                                  trailing: PopupMenuButton<String>(
                                    position: PopupMenuPosition.under,
                                    menuPadding: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.all(0),
                                    onSelected: (value) async {
                                      if (value == 'Edit') {
                                        //debugPrint("Edit Category ID: ${category.id}");
                                      } else if (value == 'delete') {
                                        //_confirmDelete(context, item.purchaseDetails[index].);
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
                                ),
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
}
