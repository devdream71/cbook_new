
class SalesResponse {
  final bool success;
  final String message;
  final List<SaleItem> data;

  SalesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SalesResponse.fromJson(Map<String, dynamic> json) {
    return SalesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    );
  }
}

class SaleItem {
  final int userId;
  final dynamic customerId;
  final String customerName;
  final String transectionMethod;
  final String billNumber;
  final String purchaseDate;
  final double discount;
  final double grossTotal;
  final String? detailsNotes;
  final String disabled;
  final List<PurchaseDetail> purchaseDetails;

  SaleItem({
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.transectionMethod,
    required this.billNumber,
    required this.purchaseDate,
    required this.discount,
    required this.grossTotal,
    this.detailsNotes,
    required this.disabled,
    required this.purchaseDetails,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      userId: json['user_id'] ?? 0,
      customerId: json['customer_id'] ?? 'N/A',
      customerName: json['customer_name'] ?? 'N/A',
      transectionMethod: json['transection_method'] ?? '',
      billNumber: json['bill_number'] ?? '',
      //purchaseDate: json['pruchase_date'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      grossTotal: (json['gross_total'] ?? 0).toDouble(),
      detailsNotes: json['details_notes'],
      disabled: json['disabled'] ?? 'enable',
      purchaseDetails: (json['purchase_details'] as List)
          .map((e) => PurchaseDetail.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseDetail {
  final int id;
  final int purchaseId;
  final String purchaseDetailsId;
  final String type;
  final String purchaseDate;
  final int itemId;
  final dynamic defaultQty;
  final dynamic qty;
  final dynamic rawQty;
  final int unitId;
  final double price;
  final double subTotal;
  final dynamic salesQty;
  final dynamic returnQty;
  final dynamic discountAmount;
  final dynamic discountPercenmtace;
  final dynamic taxAmount;
  final dynamic taxPercentace;



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
    required this.salesQty,
    required this.returnQty,
    required this.discountAmount,
    required this.discountPercenmtace,
    required this.taxAmount,
    required this.taxPercentace
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'] ?? 0,
      purchaseId: json['purchase_id'] ?? 0,
      purchaseDetailsId: json['purchase_details_id'] ?? '',
      type: json['type'] ?? '',
      purchaseDate: json['pruchase_date'] ?? '',
      itemId: json['item_id'] ?? 0,
      defaultQty: json['default_qty'] ?? 0,
      qty: json['qty'] ?? 0,
      rawQty: json['raw_qty'] ?? 0,
      unitId: json['unit_id'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      subTotal: (json['sub_total'] ?? 0).toDouble(),
      salesQty: json['sales_qty'] ?? 0,
      returnQty: json['return_qty'] ?? 0,
      discountAmount: json['discount_amount'] ?? 0,
      discountPercenmtace: json['discount_percentage'] ?? 0,
      taxAmount: json['discount_amount'] ?? 0,
      taxPercentace: json['tax_percent'] ?? 0,

    );
  }
}
