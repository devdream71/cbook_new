
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/purchase/purchase_update.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/purchase_update_model.dart';

class UpdatePurchaseItemView extends StatefulWidget {
  final index;
  final PurchaseUpdateProvider provider;
  final PurchaseUpdateModel itemDetail;
  final Map<int, String> itemMap;  
  final Map<int, String> unitMap;  

  const UpdatePurchaseItemView({
    super.key,
    required this.index,
    required this.itemDetail,
    required this.provider,
    required this.itemMap,
    required this.unitMap,
  });

  @override
  _UpdatePurchaseItemViewState createState() => _UpdatePurchaseItemViewState();
}

class _UpdatePurchaseItemViewState extends State<UpdatePurchaseItemView> {
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();

  String? selectedItemName;
  String? selectedUnitName;

  void calculateSubtotal() {
    double price = double.tryParse(widget.provider.priceController.text) ?? 0.0;
    double qty = double.tryParse(widget.provider.qtyController.text) ?? 0.0;
    double subTotal = price * qty;
    widget.provider.subTotalController.text =
        subTotal.toStringAsFixed(2); // Format as needed
  }

  @override
  void initState() {
    super.initState();
    widget.provider.qtyController =
        TextEditingController(text: widget.itemDetail.qty.toString());
    widget.provider.priceController =
        TextEditingController(text: widget.itemDetail.price.toString());
    widget.provider.subTotalController =
        TextEditingController(text: widget.itemDetail.subTotal.toString());
  
    selectedItemName = widget.itemDetail != null
        ? widget.itemDetail.itemId.toString()
        : 'No Items Available';

    selectedUnitName = widget.itemDetail != null
    ? widget.unitMap[widget.itemDetail.unitId] ?? 'Pc'
    : 'No Units Available';    
      
  }

  void updateItem() {
    debugPrint("Updating item:");
    debugPrint("Selected Item: $selectedItemName");
    debugPrint("Selected Unit: $selectedUnitName");
    debugPrint("Qty: ${qtyController.text}");
    debugPrint("Price: ${priceController.text}");
    debugPrint("Subtotal: ${subTotalController.text}");

    // Pass the updated values back to the provider
    Provider.of<PurchaseUpdateProvider>(context, listen: false)
        .updateSelectedItem(
            selectedItemName ?? ''); // Update item name in provider
    Provider.of<PurchaseUpdateProvider>(context, listen: false)
        .updateSelectedUnit(
            selectedUnitName ?? ''); // Update unit name in provider

    // Pass updated values to other relevant fields
    Provider.of<PurchaseUpdateProvider>(context, listen: false)
        .qtyController
        .text = qtyController.text;
    Provider.of<PurchaseUpdateProvider>(context, listen: false)
        .priceController
        .text = priceController.text;
    Provider.of<PurchaseUpdateProvider>(context, listen: false)
        .subTotalController
        .text = subTotalController.text;

    setState(() {});

    // Navigate back with the updated data
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final itemPurchaseProvider =
        Provider.of<PurchaseUpdateProvider>(context, listen: true);

    widget.provider.priceController.addListener(calculateSubtotal);
    widget.provider.qtyController.addListener(calculateSubtotal);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase Update Item")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:  8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Item",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomDropdownTwo(
                items: widget.itemMap.isNotEmpty
                    ? widget.itemMap.values.toList()
                    : ['No Items Available'], // Show a default message if empty
                hint: selectedItemName ?? 'Select Item', // ✅ Show selected item
                width: double.infinity,
                height: 30,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedItemName = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Unit",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),

            SizedBox(
              width: double.infinity,
              child: CustomDropdownTwo(
                items: widget.unitMap.isNotEmpty
                    ? widget.unitMap.values.toList()
                    : ['No Units Available'], // Show a default message if empty
                hint: selectedUnitName ??
                    'Select Unit', // Show selected unit or default hint
                width: double.infinity,
                height: 30,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnitName = newValue;
                  });
                },
              ),
            ),

            AddSalesFormfield(
                label: "Price", controller: widget.provider.priceController),
            AddSalesFormfield(
                label: "Qty", controller: widget.provider.qtyController),
            AddSalesFormfield(
                label: "Subtotal",
                controller: widget.provider.subTotalController),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Red color for delete button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {}, // Ensure this function is implemented
                    child: const Text(
                      "Delete   ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      updateItem();
                      widget.provider.updatePurchaseDetail(
                        widget.index,
                      );

                      Provider.of(context)<PurchaseUpdateProvider>();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Blue color for update button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Update ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
