import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/item/model/unit_model.dart';
import 'package:cbook_dt/feature/item/provider/items_show_provider.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/sales_return/controller/sales_return_controller.dart';
import 'package:cbook_dt/feature/sales_return/model/sales_return_history_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaleReturnDetailsPage extends StatefulWidget {
  final List<SalesReturnHistoryModel> salesHistory;

  const SaleReturnDetailsPage({super.key, required this.salesHistory});

  @override
  SaleReturnDetailsPageState createState() => SaleReturnDetailsPageState();
}

class SaleReturnDetailsPageState extends State<SaleReturnDetailsPage> {
  final Map<int, TextEditingController> _reductionControllers = {};
  double totalReductionQty = 0;
  double totalPrice = 0;

  List<String> unitIdsList = [];

  @override
  void initState() {
    super.initState();

    // Fetch units when the page initializes
    Future.delayed(Duration.zero, () {
      Provider.of<UnitProvider>(context, listen: false).fetchUnits();
    });

    Provider.of<SalesReturnController>(context, listen: false)
        .addReductionQtyController(data: widget.salesHistory);
    for (var history in widget.salesHistory) {
      _reductionControllers.putIfAbsent(
          history.salesDetailsID, () => TextEditingController());
    }

    final purchaseHistory = widget.salesHistory;
    final haseDetailsHistoryID = purchaseHistory.first.salesDetailsID;
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

    for (var history in widget.salesHistory) {
      double reductionQty = double.tryParse(
              _reductionControllers[history.salesDetailsID]?.text.trim() ??
                  '0') ??
          0;

       

      double unitQty = history.unitPrice.toDouble(); // Ensure unitQty is double

      total += reductionQty * unitQty;
    }

    setState(() {
      totalPrice = total;
    });
  }

 

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<SalesReturnController>(context, listen: false);

    debugPrint(widget.salesHistory.length.toString());
    debugPrint(widget.salesHistory.first.billNumber);

    return Consumer<UnitProvider>(
      builder: (context, unitProvider, child) {
        if (unitProvider.units.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Sales Return Details")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Sales Return Details")),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Scrollable history list
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.salesHistory.length,
                    itemBuilder: (context, index) {
                      final history = widget.salesHistory[index];

                      TextEditingController unitPriceController =
                          TextEditingController(
                        text: history.unitPrice.toString(),
                      );

                      
                      List<String> allowedUnits = [];

                      final primaryUnit = unitProvider.units.firstWhere(
                        (unit) => unit.id == history.itemID,
                        orElse: () =>
                            Unit(id: 0, name: 'Unknown', symbol: '', status: 0),
                      );
                      if (primaryUnit.id != 0) {
                        allowedUnits.add(primaryUnit.name);
                      }

                      // Optional: if your model has secondaryUnitID
                      if (history.itemID != null) {
                        final secondaryUnit = unitProvider.units.firstWhere(
                          (unit) => unit.id == history.itemID,
                          orElse: () => Unit(
                              id: 0, name: 'Unknown', symbol: '', status: 0),
                        );
                        if (secondaryUnit.id != 0 &&
                            secondaryUnit.name != primaryUnit.name) {
                          allowedUnits.add(secondaryUnit.name);
                        }
                      }

                      return Card(
                        color: Colors.white70,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bill: ${history.billNumber},",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),

                              Text("Date: ${history.purchaseDate}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  )),
                              Text("Bill Qty: ${history.billQty}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  )),
                              Text("Rate: ${history.rate}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  )),

                              Text("Unit Qty: ${history.unitQty}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  )),

                              Text(
                                "Unit Price: ${history.unitPrice}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),

                              SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: unitPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Unit Price",
                                    labelStyle: TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 8),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  onChanged: (value) {
                                    debugPrint("top most $value");
                                  }
                                ),
                              ),

                              const SizedBox(height: 10),
                              const Text("Reduction Qty",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12)),
                              const SizedBox(height: 3),

                              ///reduction
                              SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                   
                                  controller:
                                      controller.reductionQtyList[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Reduction Qty",
                                    labelStyle: TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 8),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  onChanged: (value) {
                                    debugPrint("top most $value");

                                    controller.saveSaleReturn(
                                        itemId: history.itemID.toString(),
                                        qty: controller
                                            .reductionQtyList[index].value.text,
                                        index: index,
                                        price: history.unitPrice.toString(),
                                        purchaseDetailsId:
                                            history.salesDetailsID.toString(),
                                        itemName: Provider.of<AddItemProvider>(
                                                context,
                                                listen: false)
                                            .getItemName(history.itemID),
                                        unitName:
                                            controller.selectedUnit.toString());



                                     
                                  },
                                ),
                              ),

                               
                            ],
                          ),
                        ),
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
                      Text(
                        "All QTY: ${controller.getAllQty()}",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "PTK: $totalReductionQty",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Total Price: ${controller.getTotalPrice(widget.salesHistory)}",
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
                        final bool isSucces = controller.isCash
                            ? await controller.saveSaleReturnData()
                            : await controller.saveSaleReturnCreaditData();

                        debugPrint(
                            "Sale item return  ${controller.itemsCashReuturn.length}");
                        debugPrint(
                            "Sale item return  ${controller.itemsCash.length}");
                        debugPrint(
                            "Sale item return  ${controller.saleItemReturn.length}");
                        debugPrint(
                            "Sale item return  ${controller.itemsCashSales.length}");
                        debugPrint(
                            "Sale item return  ${controller.saleReturnItemModel}");
                        debugPrint(
                            "Sale item return  ${controller.demoPurchaseReturnModelList}");

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
                      ),),
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
