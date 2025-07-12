import 'package:cbook_dt/app_const/app_colors.dart';
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

    // selectedItemName = widget.itemDetail != null
    //     ? widget.itemDetail.itemId.toString()
    //     : 'No Items Available';

    selectedItemName = widget.itemDetail != null
        ? widget.itemMap[int.tryParse(widget.itemDetail.itemId) ?? 0] ??
            'No Items Available'
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

    // Find itemId from selectedItemName (reverse lookup)
    int? updatedItemId = widget.itemMap.entries
        .firstWhere((entry) => entry.value == selectedItemName,
            orElse: () => MapEntry(0, ''))
        .key;

    // Find unitId from selectedUnitName (reverse lookup)
    int? updatedUnitId = widget.unitMap.entries
        .firstWhere((entry) => entry.value == selectedUnitName,
            orElse: () => MapEntry(0, ''))
        .key;

    if (updatedItemId == 0 || updatedUnitId == 0) {
      // Invalid selection, show error or return
      debugPrint("Invalid item or unit selection");
      return;
    }

    // Update the purchaseUpdateList item at index
    widget.provider.purchaseUpdateList[widget.index] = PurchaseUpdateModel(
      itemId: updatedItemId.toString(),
      price: priceController.text,
      qty: qtyController.text,
      subTotal: subTotalController.text,
      unitId: "${updatedUnitId}_$selectedUnitName",
    );

    // Also update any response models if necessary
    if (widget.provider.purchaseEditResponse.data?.purchaseDetails != null) {
      widget.provider.purchaseEditResponse.data!.purchaseDetails![widget.index]
          .itemId = updatedItemId;
      widget.provider.purchaseEditResponse.data!.purchaseDetails![widget.index]
          .unitId = updatedUnitId;
      widget.provider.purchaseEditResponse.data!.purchaseDetails![widget.index]
          .price = int.tryParse(priceController.text) ?? 0;
      widget.provider.purchaseEditResponse.data!.purchaseDetails![widget.index]
          .qty = int.tryParse(qtyController.text) ?? 0;
      widget.provider.purchaseEditResponse.data!.purchaseDetails![widget.index]
          .subTotal = double.tryParse(subTotalController.text) ?? 0.0;
    }

    widget.provider.notifyListeners();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final itemPurchaseProvider =
        Provider.of<PurchaseUpdateProvider>(context, listen: true);

    widget.provider.priceController.addListener(calculateSubtotal);
    widget.provider.qtyController.addListener(calculateSubtotal);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: const Text(
            "Purchase Update Item",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomDropdownTwo(
                labelText: 'Item',
                items: widget.itemMap.isNotEmpty
                    ? widget.itemMap.values.toList()
                    : ['No Items Available'], // Show a default message if empty
                hint: selectedItemName ?? 'Select Item', // ✅ Show selected item
                selectedItem: selectedItemName,
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
            SizedBox(
              child: CustomDropdownTwo(
                labelText: 'Unit',
                items: widget.unitMap.isNotEmpty
                    ? widget.unitMap.values.toList()
                    : ['No Units Available'], // Show a default message if empty
                hint: selectedUnitName ??
                    'Select Unit', // Show selected unit or default hint
                width: double.infinity,
                selectedItem: selectedUnitName,
                height: 30,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnitName = newValue;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            AddSalesFormfield(
                labelText: "Price",
                controller: widget.provider.priceController),
            const SizedBox(height: 8),
            AddSalesFormfield(
                labelText: "Qty", controller: widget.provider.qtyController),
            const SizedBox(height: 8),
            AddSalesFormfield(
                labelText: "Subtotal",
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
                      style: TextStyle(color: Colors.white, fontSize: 14),
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
