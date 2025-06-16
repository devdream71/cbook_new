class PurchaseHistoryModel {
  final int purchaseDetailsId;
  final int itemId;
  final String purchaseDate;
  final String type;
  final String billNumber;
  final dynamic rate;
  final dynamic billQty;
  final double outQty;
  final double currentQty;
  final String supplierName;
  final int unitID;
  final int? secondaryUnitID;
  final dynamic unitQty;
  final dynamic unitPrice;
  final int purchaseUnitId;

  PurchaseHistoryModel({
    required this.purchaseDetailsId,
    required this.itemId,
    required this.purchaseDate,
    required this.type,
    required this.billNumber,
    required this.rate,
    required this.billQty,
    required this.outQty,
    required this.currentQty,
    required this.supplierName,
    required this.unitID,
    required this.secondaryUnitID,
    required this.unitQty,
    required this.unitPrice,
    required this.purchaseUnitId,
  });

  factory PurchaseHistoryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryModel(
      purchaseDetailsId: json["purchase_details_id"],
      itemId: json["item_id"],
      purchaseDate: json["pruchase_date"],
      type: json["type"],
      billNumber: json["bill_number"],
      rate: json["rate"],
      billQty: json["bill_qty"],
      outQty: (json["out_qty"] ?? 0).toDouble(),
      currentQty: (json["current_qty"] ?? 0).toDouble(),
      supplierName: json["supplier_name"] ?? "N/A",
      unitID: int.tryParse(json["unit_id"].toString()) ?? 0,
      secondaryUnitID: json["secondary_unit_id"],
      unitQty: json["unit_qty"],
      unitPrice: json["unit_price"],
      purchaseUnitId: json["purchase_unit_id"],
    );
  }
}



// class PurchaseHistoryModel {
//   final int purchaseDetailsId;
//   final int itemId;
//   final String purchaseDate;
//   final String type;
//   final String billNumber;
//   final dynamic rate;
//   final dynamic billQty;
//   final dynamic outQty;
//   final dynamic currentQty;
//   final dynamic supplierName;
//   final dynamic unitID;
//   final dynamic unisecondaryUnitID;
//   final dynamic unitQty;
//   final dynamic unitPrice;
//   final dynamic purchaseUnitId;
//   final dynamic secondaryUnitID;


//   PurchaseHistoryModel({
//     required this.purchaseDetailsId,
//     required this.itemId,
//     required this.purchaseDate,
//     required this.type,
//     required this.billNumber,
//     required this.rate,
//     required this.billQty,
//     required this.outQty,
//     required this.currentQty,
//     this. supplierName,
//     required this.unitID,
//     required this.unisecondaryUnitID,
//     required this.unitQty,
//     required this.unitPrice,
//     required this.purchaseUnitId,
//      this.secondaryUnitID,
//   });

//   factory PurchaseHistoryModel.fromJson(Map<String, dynamic> json) {
//     return PurchaseHistoryModel(
//       purchaseDetailsId: json["purchase_details_id"],
//       itemId: json["item_id"],
//       purchaseDate: json["pruchase_date"], // Typo in API, keep it as is
//       type: json["type"],
//       billNumber: json["bill_number"],
//       rate: json["rate"],
//       purchaseUnitId: json["purchase_unit_id"],
//       unitID: json["unit_id"],
//       secondaryUnitID: json["secondary_unit_id"],
//       unitQty: json["unit_qty"],
//       unitPrice: json["unit_price"],
//       unisecondaryUnitID: json["secondary_unit_id"],
//       supplierName: json["supplier_name"] ?? "N/A",
//       billQty: json["bill_qty"],
//       outQty: (json["out_qty"] ?? 0).toDouble(),
//       currentQty: (json["current_qty"] ?? 0).toDouble(),
//     );
//   }
// }
