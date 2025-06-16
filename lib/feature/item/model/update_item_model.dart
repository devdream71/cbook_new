class UpdateItemModel {
  final String name;
  final dynamic openingStock;
  final dynamic openingPrice;
  final dynamic openingValue;
  final String? openingDate;
  final String? image;
  final int status;
  final dynamic purchasePrice; 
  final dynamic salePrice; 
  final dynamic mrpPrice; 

  UpdateItemModel({
    required this.name,
    required this.openingStock,
    required this.openingPrice,
    this.openingValue,
    this.openingDate,
    this.image,
    required this.status,
    this. purchasePrice,
    this. salePrice,
    this. mrpPrice,

  });

  factory UpdateItemModel.fromJson(Map<String, dynamic> json) {
    return UpdateItemModel(
      name: json['name'] ?? '',
      openingStock: json['opening_stock'] ?? 0,
      openingPrice: json['opening_price'] ?? 0,
      openingValue: json['opening_value'],
      openingDate: json['opening_date'],
      image: json['image'],
      status: json['status'] ?? 1,
      purchasePrice: json['purchase_price'] ?? 0,
      salePrice: json['sales_price'] ?? 0,
      mrpPrice: json['mrps_price'] ?? 0,
    );
  }
}






