class SalesReturnHistoryModel {
  final dynamic salesDetailsID;
  final dynamic itemID;
  final String purchaseDate;
  final dynamic billNumber;
  final dynamic rate;
  final dynamic unitPrice;
  final dynamic unitQty;
  final dynamic billQty;

  SalesReturnHistoryModel(
      {required this.salesDetailsID,
      required this.itemID,
      required this.purchaseDate,
      required this.billNumber,
      required this.rate,
      required this.unitPrice,
      required this.unitQty,
      required this.billQty});

  factory SalesReturnHistoryModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnHistoryModel(
      salesDetailsID: json['sales_details_id'],
      itemID: json['item_id'],
      purchaseDate: json['pruchase_date'],
      billNumber: json['bill_number'],
      rate: json['rate'],
      unitPrice: json['unit_price'],
      unitQty: json['unit_qty'],
      billQty: json['bill_qty'],
    );
  }
}
