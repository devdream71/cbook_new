import 'dart:convert';

class PurchaseReturnResponse {
  final bool success;
  final String message;
  final List<PurchaseReturn> data;

  PurchaseReturnResponse({required this.success, required this.message, required this.data});

  factory PurchaseReturnResponse.fromJson(String str) =>
      PurchaseReturnResponse.fromMap(json.decode(str));

  factory PurchaseReturnResponse.fromMap(Map<String, dynamic> json) => PurchaseReturnResponse(
        success: json["success"],
        message: json["message"] ?? '',
        data: List<PurchaseReturn>.from(json["data"].map((x) => PurchaseReturn.fromMap(x))),
      );
}

// class PurchaseReturn {
//   final int userId;
//   final int supplierId;
//   final String? supplierName;
//   final String? transactionMethod;
//   final String billNumber;
//   final String? purchaseDate;
//   final double discount;
//   final dynamic grossTotal;
//   final String? detailsNotes;
//   final String disabled;
//   final List<PurchaseDetail> purchaseDetails;

//   PurchaseReturn({
//     required this.userId,
//     required this.supplierId,
//     required this.supplierName,
//     this.transactionMethod,
//     required this.billNumber,
//     this.purchaseDate,
//     required this.discount,
//     required this.grossTotal,
//     this.detailsNotes,
//     required this.disabled,
//     required this.purchaseDetails,
//   });

//   factory PurchaseReturn.fromMap(Map<String, dynamic> json) => PurchaseReturn(
//         userId: json["user_id"],
//         supplierId: json["supplier_id"],
//         supplierName: json["supplier_name"],
//         transactionMethod: json["transection_method"],
//         billNumber: json["bill_number"],
//         purchaseDate: json["pruchase_date"],
//         discount: (json["discount"] ?? 0).toDouble(),
//         grossTotal: (json["gross_total"] ?? 0).toDouble(),
//         detailsNotes: json["details_notes"],
//         disabled: json["disabled"],
//         purchaseDetails: List<PurchaseDetail>.from(
//             json["purchase_details"].map((x) => PurchaseDetail.fromMap(x))),
//       );
// }


class PurchaseReturn {
  final int? userId;
  final int? supplierId;
  final String? supplierName;
  final String? transactionMethod;
  final String billNumber;
  final String? purchaseDate;
  final double discount;
  final dynamic grossTotal;
  final String? detailsNotes;
  final String disabled;
  final List<PurchaseDetail> purchaseDetails;

  PurchaseReturn({
    this.userId,
    this.supplierId,
    this.supplierName,
    this.transactionMethod,
    required this.billNumber,
    this.purchaseDate,
    required this.discount,
    required this.grossTotal,
    this.detailsNotes,
    required this.disabled,
    required this.purchaseDetails,
  });

  factory PurchaseReturn.fromMap(Map<String, dynamic> json) => PurchaseReturn(
        userId: json["user_id"] as int?, // safely nullable
        supplierId: json["supplier_id"] as int?,
        supplierName: json["supplier_name"],
        transactionMethod: json["transection_method"],
        billNumber: json["bill_number"],
        purchaseDate: json["pruchase_date"],
        discount: (json["discount"] ?? 0).toDouble(),
        grossTotal: (json["gross_total"] ?? 0).toDouble(),
        detailsNotes: json["details_notes"],
        disabled: json["disabled"],
        purchaseDetails: List<PurchaseDetail>.from(
            json["purchase_details"].map((x) => PurchaseDetail.fromMap(x))),
      );
}

class PurchaseDetail {
  final int id;
  final int purchaseId;
  final String ? purchaseDetailsId;
  final String type;
  final String purchaseDate;
  final int itemId;
  final dynamic defaultQty;
  final dynamic qty;
  final dynamic rawQty;
  final int ? unitId;
  final dynamic price;
  final dynamic subTotal;

  PurchaseDetail({
    required this.id,
    required this.purchaseId,
    required this.purchaseDetailsId,
    required this.type,
    required this.purchaseDate,
    required this.itemId,
    required this.defaultQty,
    required this.qty,
    required this.rawQty,
    required this.unitId,
    required this.price,
    required this.subTotal,
  });

  factory PurchaseDetail.fromMap(Map<String, dynamic> json) => PurchaseDetail(
        id: json["id"],
        purchaseId: json["purchase_id"],
        purchaseDetailsId: json["purchase_details_id"],
        type: json["type"],
        purchaseDate: json["pruchase_date"],
        itemId: json["item_id"],
        defaultQty: json["default_qty"],
        qty: json["qty"],
        rawQty: json["raw_qty"],
        unitId: json["unit_id"],
        price: (json["price"] ?? 0).toDouble(),
        subTotal: (json["sub_total"] ?? 0).toDouble(),
      );
}
