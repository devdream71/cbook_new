class PurchaseViewModel {
  bool? success;
  String? message;
  List<Data>? data;

  PurchaseViewModel({this.success, this.message, this.data});

  PurchaseViewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  dynamic userId;
  String? supplier;
  String? billNumber;
  String? pruchaseDate;
  dynamic discount;
  dynamic grossTotal;
  String? disabled;
  dynamic detailsNotes;
  //dynamic ? supplierName;
  String ? transectionMethod;
  List<PurchaseDetails>? purchaseDetails;

  Data(
      {this.userId,
      this.supplier,
      this.billNumber,
      this.pruchaseDate,
      this.discount,
      this.grossTotal,
      this.disabled,
      this.detailsNotes,
      //this.supplierName,
      this.transectionMethod,
      this.purchaseDetails});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    supplier = json['supplier_name'];
    billNumber = json['bill_number'];
    pruchaseDate = json['purchase_date'];
    discount = json['discount'];
    grossTotal = json['gross_total'];
    disabled = json['disabled'];
    detailsNotes = json['details_notes'];
    transectionMethod = json['transection_method'];
   // supplierName = json['supplier_name'];
    if (json['purchase_details'] != null) {
      purchaseDetails = <PurchaseDetails>[];
      json['purchase_details'].forEach((v) {
        purchaseDetails!.add(new PurchaseDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['supplier_name'] = this.supplier;
    data['bill_number'] = this.billNumber;
    data['transection_method'] = this.transectionMethod;
    data['purchase_date'] = this.pruchaseDate;
    data['discount'] = this.discount;
    data['gross_total'] = this.grossTotal;
    data['disabled'] = this.disabled;
    data['details_notes'] = this.detailsNotes;
    if (this.purchaseDetails != null) {
      data['purchase_details'] =
          this.purchaseDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseDetails {
  int? id;
  dynamic? purchaseId;
  //Null? purchaseDetailsId;
  String? type;  
  String? pruchaseDate;
  int? itemId;
  int? defaultQty;
  dynamic qty;
  dynamic rawQty;
  int? unitId;
  dynamic price;
  dynamic subTotal;
  dynamic salesQty;
  dynamic returnQty;
  Null deletedAt;
  String? createdAt;
  String? updatedAt;

  PurchaseDetails(
      {this.id,
      this.purchaseId,
      //this.purchaseDetailsId,
      this.type,
      this.pruchaseDate,
      this.itemId,
      this.defaultQty,
      this.qty,
      this.rawQty,
      this.unitId,
      this.price,
      this.subTotal,
      this.salesQty,
      this.returnQty,
      this.deletedAt,
      this.createdAt,
      this.updatedAt, required Data purchase});

  PurchaseDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    purchaseId = json['purchase_id'];
    //purchaseDetailsId = json['purchase_details_id'];
    type = json['type'];
    pruchaseDate = json['purchase_date'];
    itemId = json['item_id'];
    defaultQty = json['default_qty'];
    qty = json['qty'];
    rawQty = json['raw_qty'];
    unitId = json['unit_id'];
    price = json['price'];
    subTotal = json['sub_total'];
    salesQty = json['sales_qty'];
    returnQty = json['return_qty'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['purchase_id'] = this.purchaseId;
    //data['purchase_details_id'] = this.purchaseDetailsId;
    data['type'] = this.type;
    data['purchase_date'] = this.pruchaseDate;
    data['item_id'] = this.itemId;
    data['default_qty'] = this.defaultQty;
    data['qty'] = this.qty;
    data['raw_qty'] = this.rawQty;
    data['unit_id'] = this.unitId;
    data['price'] = this.price;
    data['sub_total'] = this.subTotal;
    data['sales_qty'] = this.salesQty;
    data['return_qty'] = this.returnQty;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}



 