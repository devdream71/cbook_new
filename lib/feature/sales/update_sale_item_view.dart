import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/model/sales_update_model.dart';
import 'package:cbook_dt/feature/sales/sales_update.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateSaleItemView extends StatefulWidget {
  final index;
  final SaleUpdateProvider provider;
  // final SaleDetail itemDetail;
  final SaleUpdateModel itemDetail;
  final Map<int, String> itemMap;
  final Map<int, String> unitMap;

  const UpdateSaleItemView({
    Key? key,
    required this.index,
    required this.itemDetail,
    required this.provider,
    required this.itemMap,
    required this.unitMap,
  }) : super(key: key);

  @override
  _UpdateSaleItemViewState createState() => _UpdateSaleItemViewState();
}

class _UpdateSaleItemViewState extends State<UpdateSaleItemView> {
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();

  String? selectedItemName;
  String? selectedUnitName;

  String? selectedTaxName;
  String? selectedTaxId;

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

    // final fetchStockQuantity =
    //     Provider.of<AddItemProvider>(context, listen: false);

    widget.provider.saveData(
      itemId: widget.itemDetail != null
          ? widget.itemDetail.itemId.toString()
          : 'No Items Available',
      unitId: widget.itemDetail != null
          ? widget.itemDetail.unitId.toString() ?? 'pc'
          : 'No Units Available',
      price: widget.itemDetail.price,
      qty: widget.itemDetail.qty,
      subtotal: widget.itemDetail.subTotal,
    );
  }

  void updateItem() {
    print("Updating item:");
    print("Selected Item: $selectedItemName");
    print("Selected Unit: $selectedUnitName");
    print("Qty: ${qtyController.text}");
    print("Price: ${priceController.text}");
    print("Subtotal: ${subTotalController.text}");

    // Pass the updated values back to the provider
    Provider.of<SaleUpdateProvider>(context, listen: false).updateSelectedItem(
        selectedItemName ?? ''); // Update item name in provider

    Provider.of<SaleUpdateProvider>(context, listen: false).updateSelectedUnit(
        selectedUnitName ?? ''); // Update unit name in provider

    // Pass updated values to other relevant fields
    Provider.of<SaleUpdateProvider>(context, listen: false).qtyController.text =
        qtyController.text;

    Provider.of<SaleUpdateProvider>(context, listen: false)
        .priceController
        .text = priceController.text;

    Provider.of<SaleUpdateProvider>(context, listen: false)
        .subTotalController
        .text = subTotalController.text;

    Provider.of<SaleUpdateProvider>(context, listen: false).qtyController.text =
        qtyController.text;

    setState(() {});

    // Navigate back with the updated data
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemPurchaseProvider =
        Provider.of<SaleUpdateProvider>(context, listen: true);

    final controller = Provider.of<SalesController>(context, listen: false);

    widget.provider.priceController.addListener(calculateSubtotal);
    widget.provider.qtyController.addListener(calculateSubtotal);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Update Item",
            style: TextStyle(color: Colors.yellow, fontSize: 16),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ////==>Item
            const Text(
              "Item",
              style: TextStyle(color: Colors.black),
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

            ///==>Item Stock
            Consumer<AddItemProvider>(
              builder: (context, stockProvider, child) {
                //controller.mrpController.text = stockProvider.stockData!.price.toString();
                if (stockProvider.stockData != null) {
                  controller.mrpController.text =
                      stockProvider.stockData!.price.toString();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "   Stock Available:  ${stockProvider.stockData!.unitStocks} ৳ ${stockProvider.stockData!.price} ",
                        //"   Stock Available: ${stockProvider.stockData!.stocks} (${stockProvider.stockData!.unitStocks}) ৳ ${stockProvider.stockData!.price} ",

                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "   ", // Updated message for empty stock
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 5),

            //=>Qty , unit
            Row(
              children: [
                //qty
                Expanded(
                  child: AddSalesFormfield(
                      label: "Qty", controller: widget.provider.qtyController),
                ),
                const SizedBox(
                  width: 5,
                ),

                //unit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Unit",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      SizedBox(
                        child: CustomDropdownTwo(
                          items: widget.unitMap.isNotEmpty
                              ? widget.unitMap.values.toList()
                              : [
                                  'No Units Available'
                                ], // Show a default message if empty
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
                    ],
                  ),
                ),
              ],
            ),

            //price
            AddSalesFormfield(
                label: "Price", controller: widget.provider.priceController),

            //discout amount, discount percentance
            Row(children: [
              Expanded(
                child: Column(
                  children: [
                    //discount percentance
                    AddSalesFormfield(
                      label: "Discount (%)",
                      controller: widget.provider.discountPercentance,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        widget.provider.lastChanged = 'percent';
                        widget.provider.calculateSubtotal();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              //discount amount
              Expanded(
                child: Column(
                  children: [
                    AddSalesFormfield(
                      label: "Discount (Amount)",
                      controller: widget.provider.discountAmount,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        widget.provider.lastChanged = 'amount';
                        widget.provider.calculateSubtotal();
                      },
                    ),
                  ],
                ),
              ),
            ]),

            // ✅ VAT/TAX Dropdown Row
            Row(
              children: [
                // Dropdown
                Expanded(
                  child: Consumer<TaxProvider>(
                    builder: (context, taxProvider, child) {
                      if (taxProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (taxProvider.taxList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No tax options available.',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///tax
                              const Text(
                                "VAT/TAX (%)",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              CustomDropdownTwo(
                                hint: 'Select VAT/TAX',
                                items: taxProvider.taxList
                                    .map((tax) =>
                                        "${tax.name} - (${tax.percent})")
                                    .toList(),
                                width: double.infinity,
                                height: 30,
                                selectedItem: selectedTaxName,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedTaxName = newValue;

                                    final nameOnly =
                                        newValue?.split(" - ").first;

                                    final selected =
                                        taxProvider.taxList.firstWhere(
                                      (tax) => tax.name == nameOnly,
                                      orElse: () => taxProvider.taxList.first,
                                    );

                                    selectedTaxId = selected.id.toString();

                                    widget.provider.selectedTaxPercent =
                                        double.tryParse(selected.percent);

                                    // controller.setTaxPercent(selectedTaxPercent ?? 0.0); // 👈 Call controller
                                    widget.provider.taxPercent =
                                        widget.provider.selectedTaxPercent ??
                                            0.0;

                                    widget.provider.updateTaxPaecentId(
                                        '${selectedTaxId}_${widget.provider.selectedTaxPercent}');

                                    print(
                                        'tax_percent: "${controller.taxPercentValue}"');

                                    //controller.calculateSubtotal();

                                    debugPrint(
                                        "Selected Tax ID: $selectedTaxId");
                                    debugPrint(
                                        "Selected Tax Percent: ${controller.selectedTaxPercent}");
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                ///tax amount
                Expanded(
                  child: AddSalesFormfield(
                    label: "TAX amount",
                    controller: TextEditingController(
                      text: widget.provider.taxAmount
                          .toStringAsFixed(2), // 👈 show calculated tax
                    ),
                    keyboardType: TextInputType.number,
                    //readOnly: true, // 👈 prevent manual editing
                  ),
                ),
              ],
            ),

            AddSalesFormfield(
                readOnly: true,
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
                      widget.provider.updateSaleDetail(
                        widget.index,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Blue color for update button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Update   ",
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
