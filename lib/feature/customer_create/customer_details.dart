import 'dart:convert';
 import 'package:cbook_dt/feature/customer_create/model/customer_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerDetailsScreen extends StatefulWidget {
  final int customerId;
  final List<Purchase> purchases;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
    required this.purchases,
  });

  @override
  _SupplierDetailsScreenState createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<CustomerDetailsScreen> {
  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? customerDetails;

  @override
  void initState() {
    super.initState();
    fetchSupplierDetails();
  }

  Future<void> fetchSupplierDetails() async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/customer/edit/${widget.customerId}');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          customerDetails = data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load customer details";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Widget buildDetailRow(String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 260,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      customerDetails?["name"] ??
                                          "Customer Name",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    Text(
                                      "৳${customerDetails?["opening_balance"] ?? '0'}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 30, thickness: 1),
                              buildDetailRow("Proprietor",
                                  customerDetails?["proprietor_name"]),
                              buildDetailRow(
                                  "Email", customerDetails?["email"]),
                              buildDetailRow(
                                  "Phone", customerDetails?["phone"]),
                              buildDetailRow(
                                  "Address", customerDetails?["address"]),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///Customer Purchase list
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Purchase",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          widget.purchases.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Center(
                                    child: Text(
                                      "No Purchase Available",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: widget.purchases.length,
                                  itemBuilder: (context, index) {
                                    final purchase = widget.purchases[index];

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Text(purchase.id.toString()),
                                        ),
                                        title: Text(
                                          "Bill: ${purchase.billNumber}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Date: ${purchase.purchaseDate}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13)),
                                            Text(
                                                "Total: ৳ ${purchase.grossTotal}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        // trailing: const Icon(Icons.receipt_long,
                                        //     color: Colors.blue),
                                      ),
                                    );
                                  },
                                ),
                        ]),
                  ),
                ]),
    );
  }
}
