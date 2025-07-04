import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/purchase_return/controller/purchase_return_controller.dart';
import 'package:cbook_dt/feature/purchase_return/model/purchase_return_item_details.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PurchaseReturnDetailsPage extends StatefulWidget {
  final List<PurchaseHistoryModel> purchaseHistory;
  final String itemName;

  const PurchaseReturnDetailsPage(
      {super.key, required this.purchaseHistory, required this.itemName});

  @override
  PurchaseReturnDetailsPageState createState() =>
      PurchaseReturnDetailsPageState();
}

class PurchaseReturnDetailsPageState extends State<PurchaseReturnDetailsPage> {
  //late TextEditingController unitPriceController;

  final Map<int, TextEditingController> _reductionControllers = {};
  double totalReductionQty = 0;
  double totalPrice = 0;

  List<String> unitIdsList = [];

  @override
  void initState() {
    super.initState();

    // unitPriceController = TextEditingController(
    //   text:
    //       widget.purchaseHistory.first.unitPrice.toString(), // or initial value //need price
    // );

    // Fetch units when the page initializes
    Future.delayed(Duration.zero, () {
      Provider.of<UnitProvider>(context, listen: false).fetchUnits();
    });

    Provider.of<PurchaseReturnController>(context, listen: false)
        .addReductionQtyController(data: widget.purchaseHistory);
    for (var history in widget.purchaseHistory) {
      _reductionControllers.putIfAbsent(
          history.purchaseDetailsId, () => TextEditingController());
    }

    var controller =
        Provider.of<PurchaseReturnController>(context, listen: false);

    controller.clearReductionQty();

    final purchaseHistory = widget.purchaseHistory;
    final haseDetailsHistoryID = purchaseHistory.first.purchaseDetailsId;
  }

  TextEditingController priceController = TextEditingController();

  // Function to calculate total reduction quantity
  void calculateTotalReductionQty() {
    double total = 0;
    _reductionControllers.forEach((key, controller) {
      double value = double.tryParse(controller.text.trim()) ?? 0;
      total += value;
    });

    setState(() {
      totalReductionQty = total;
    });

    calculateTotalPrice(); // Ensure total price updates correctly
  }

  // Function to calculate total price
  void calculateTotalPrice() {
    double total = 0;

    for (var history in widget.purchaseHistory) {
      double reductionQty = double.tryParse(
              _reductionControllers[history.purchaseDetailsId]?.text.trim() ??
                  '0') ??
          0;

      // Ensure Reduction Qty doesn't exceed Current Qty
      if (reductionQty > history.currentQty) {
        reductionQty = history.currentQty;
      }

      double unitQty = history.unitPrice.toDouble(); // Ensure unitQty is double

      total += reductionQty * unitQty;
    }

    setState(() {
      totalPrice = total;
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    for (var controller in _reductionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller =
        Provider.of<PurchaseReturnController>(context, listen: false);

    return Consumer<UnitProvider>(
      builder: (context, unitProvider, child) {
        if (unitProvider.units.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Purchase Return Details")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        String primaryUnitName = '';
        String secondaryUnitName = '';

        if (widget.purchaseHistory.isNotEmpty) {
          final firstHistory = widget.purchaseHistory.first;

          final primaryUnit = unitProvider.units.firstWhere(
            (unit) => unit.id == firstHistory.unitID,
            orElse: () => Unit(id: 0, name: 'Unknown', symbol: '', status: 0),
          );
          primaryUnitName = primaryUnit.symbol;

          if (firstHistory.secondaryUnitID != null) {
            final secondaryUnit = unitProvider.units.firstWhere(
              (unit) => unit.id == firstHistory.secondaryUnitID,
              orElse: () => Unit(id: 0, name: '', symbol: '', status: 0),
            );
            if (secondaryUnit.id != 0 &&
                secondaryUnit.name != primaryUnit.name) {
              secondaryUnitName = secondaryUnit.symbol;
            }
          }
        }

        final firstHistory = widget.purchaseHistory.first;

        String conversionText = '';

        if (secondaryUnitName.isNotEmpty &&
            firstHistory.billQty.contains('=')) {
          final parts = firstHistory.billQty.split('=');
          if (parts.length == 2) {
            final left = double.tryParse(parts[0].trim());
            final right = double.tryParse(parts[1].trim());
            if (left != null && right != null && left != 0) {
              final result = right / left;
              conversionText =
                  ' = ${result.toStringAsFixed(0)} $secondaryUnitName';
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
              //  backgroundColor: colorScheme.surface,
              backgroundColor: colorScheme.primary,
              //actionsIconTheme: const IconThemeData(color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Purchase Return Details",
                style: TextStyle(color: Colors.yellow, fontSize: 16),
              )),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scrollable history list

                // Text(
                //   '${widget.itemName} (1 ${primaryUnitName}${secondaryUnitName.isNotEmpty ? ' =     $secondaryUnitName' : ''})',
                //   style: const TextStyle(color: Colors.black, fontSize: 13),
                // ),

                Text(
                  '${widget.itemName} (1 $primaryUnitName$conversionText)',
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                ),

                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.purchaseHistory.length,
                    itemBuilder: (context, index) {
                      final history = widget.purchaseHistory[index];

                      //unit price ===
                      TextEditingController unitPriceController =
                          TextEditingController(
                        text: history.unitPrice.toString(),
                      );

                      /// ✅ Prepare allowed units (primary + optional secondary)
                      List<String> allowedUnits = [];

                      final primaryUnit = unitProvider.units.firstWhere(
                        (unit) => unit.id == history.unitID,
                        orElse: () =>
                            Unit(id: 0, name: 'Unknown', symbol: '', status: 0),
                      );
                      if (primaryUnit.id != 0) {
                        allowedUnits.add(primaryUnit.name);
                      }

                      // Optional: if your model has secondaryUnitID
                      if (history.secondaryUnitID != null) {
                        final secondaryUnit = unitProvider.units.firstWhere(
                          (unit) => unit.id == history.secondaryUnitID,
                          orElse: () => Unit(
                              id: 0, name: 'Unknown', symbol: '', status: 0),
                        );
                        if (secondaryUnit.id != 0 &&
                            secondaryUnit.name != primaryUnit.name) {
                          allowedUnits.add(secondaryUnit.name);
                        }
                      }

                      return Column(
                        children: [
                          Card(
                            color: Colors.white70,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Bill: ${history.billNumber},", //Type: ${history.type}
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      //==>
                                      Text(
                                        '${history.rate}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),

                                      Text(
                                          "Account Name: ${history.supplierName.isEmpty ? 'N/A' : history.supplierName}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black)),
                                      Text(
                                        "Date: ${history.purchaseDate}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Bill Qty: ${history.billQty}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Rate: ${history.rate}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Out Qty: ${history.outQty}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Current Qty: ${history.currentQty}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Unit Qty: ${history.unitQty}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      // Text(
                                      //   "Unit Price: ${history.unitPrice}",
                                      //   style: const TextStyle(
                                      //     color: Colors.black,
                                      //     fontSize: 13,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),

                                      const Text(
                                        "Unit Price",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),

                                      SizedBox(
                                        width: 150,
                                        height: 30,
                                        child: AddSalesFormfield(
                                          controller: unitPriceController,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            debugPrint("top most $value");
                                          },
                                        ),
                                      ),

//                                       SizedBox(
//   width: 150,
//   height: 30,
//   child: AddSalesFormfield(
//     controller: unitPriceController,
//     keyboardType: TextInputType.number,
//     onChanged: (value) {
//       debugPrint("unit price changed: $value");
//       // You can update your model or state here if needed
//     },
//   ),
// ),

                                      const SizedBox(height: 6),
                                      const Text("Reduction Qty",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                      const SizedBox(height: 3),
                                      SizedBox(
                                        width: 150,
                                        height: 30,
                                        child: AddSalesFormfield(
                                          controller: controller
                                              .reductionQtyList[index],
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            debugPrint("top most $value");

                                            final reductionText = controller
                                                .reductionQtyList[index].text;

                                            final reductionQty =
                                                int.tryParse(reductionText) ??
                                                    0;

                                            if (reductionQty >
                                                history.currentQty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                  "Reduction QTY can't be above current QTY",
                                                ),
                                                backgroundColor: Colors.red,
                                              ));
                                            }

                                            controller.savePrucahseReturn(
                                                itemId:
                                                    history.itemId.toString(),
                                                qty: controller
                                                    .reductionQtyList[index]
                                                    .value
                                                    .text,
                                                index: index,
                                                price: history.unitPrice
                                                    .toString(),
                                                purchaseDetailsId: history
                                                    .purchaseDetailsId
                                                    .toString(),
                                                itemName: Provider.of<
                                                            AddItemProvider>(
                                                        context,
                                                        listen: false)
                                                    .getItemName(
                                                        history.itemId),
                                                unitName: controller
                                                    .selectedUnit
                                                    .toString());
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Unit",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),

                                      ///primary and secondary unit

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: CustomDropdownTwo(
                                          hint: 'Choose a unit',
                                          items: allowedUnits,
                                          width: 150,
                                          height: 30,
                                          selectedItem: allowedUnits.isNotEmpty
                                              ? allowedUnits.first
                                              : null,
                                          onChanged: (selectedUnit) {
                                            debugPrint(
                                                "Selected Unit: $selectedUnit");

                                            controller.selectedUnit =
                                                selectedUnit;

                                            final selectedUnitObj =
                                                unitProvider.units.firstWhere(
                                              (unit) =>
                                                  unit.name == selectedUnit,
                                              orElse: () => Unit(
                                                  id: 0,
                                                  name: "Unknown Unit",
                                                  symbol: "",
                                                  status: 0),
                                            );

                                            debugPrint(
                                                "🆔 Selected Unit ID: ${selectedUnitObj.id}_$selectedUnit");

                                            if (selectedUnitObj.id != 0) {
                                              String selectedUnitId =
                                                  selectedUnitObj.id.toString();

                                              // Matching logic
                                              if (selectedUnitId ==
                                                  history.secondaryUnitID
                                                      ?.toString()) {
                                                controller
                                                    .selectedUnitIdWithNameFunction(
                                                        "${selectedUnitId}_${selectedUnit}_${history.unitQty}");
                                              } else if (selectedUnitId ==
                                                  history.unitID.toString()) {
                                                controller
                                                    .selectedUnitIdWithNameFunction(
                                                        "${selectedUnitId}_${selectedUnit}_1");
                                              }
                                            }

                                            controller.notifyListeners();

                                            // If unit selected is "pieces", calculate the new quantity and total price
                                            if (selectedUnitObj.name
                                                    .toLowerCase() ==
                                                "pices") {
                                              double enteredQty =
                                                  double.tryParse(
                                                        _reductionControllers[
                                                                    history
                                                                        .purchaseDetailsId]
                                                                ?.text ??
                                                            '0',
                                                      ) ??
                                                      0;

                                              // Calculate new quantity based on the entered quantity and unit quantity (unitQty)
                                              double newQty = enteredQty /
                                                  history
                                                      .unitQty; // Reduction quantity in pieces

                                              // Calculate the new total price based on the unit price and new quantity in pieces
                                              double newTotalPrice =
                                                  newQty * history.unitPrice;

                                              // Update the reduction quantity text and total price
                                              _reductionControllers[history
                                                          .purchaseDetailsId]
                                                      ?.text =
                                                  newQty.toStringAsFixed(
                                                      2); // Update the reduction quantity
                                              setState(() {
                                                totalPrice +=
                                                    newTotalPrice; // Update the total price
                                              });
                                            } else if (selectedUnitObj.name
                                                    .toLowerCase() ==
                                                "packet") {
                                              // If unit selected is "packet", retain the current quantity logic
                                              double enteredQty =
                                                  double.tryParse(
                                                        _reductionControllers[
                                                                    history
                                                                        .purchaseDetailsId]
                                                                ?.text ??
                                                            '0',
                                                      ) ??
                                                      0;

                                              // Calculate total price for packet based on the original entered quantity
                                              double totalPacketPrice =
                                                  enteredQty *
                                                      history.unitPrice;

                                              // Update total price
                                              setState(() {
                                                totalPrice +=
                                                    totalPacketPrice; // Update total price when unit is packet
                                              });
                                            }

                                            calculateTotalReductionQty();
                                            calculateTotalPrice();

                                            // Recalculate the total reduction quantity and total price after unit change
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Fixed Total Qty and Price row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("All QTY: ${controller.getAllQty()}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Text("PTK: $totalReductionQty",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Text(
                        "Total Price: ${controller.getTotalPrice(widget.purchaseHistory)}",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          calculateTotalReductionQty();
                          calculateTotalPrice();
                        });

                        final bool isSucces = controller.isCash
                            ? await controller.savePurchaseReturnData()
                            : await controller.savePurchaseReturnCreaditData();

                        debugPrint(
                            "purchase item return  ${controller.itemsCashReuturn.length}");

                        if (isSucces) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      )),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
