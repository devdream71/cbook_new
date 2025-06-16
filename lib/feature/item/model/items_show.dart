class ItemsModel {
  final int id;
  final String name;
  final String? unitId; // Note: still String? because API returns string
  final int? unitQty;
  final dynamic openingStock;
  final int? secondaryUnitId;
  final String? openingDate;
  final int? status;
  final String? image;
  final int? secondaryUnitQty;
  final String? createdAt;
  final String? updatedAt;
  final dynamic salesPrice;
  final dynamic purchasePrice;
  final dynamic mrp;
  final int ? itemCategoryId;      // <- Must be added
  final int ? itemSubCategoryId;

  ItemsModel({
    required this.id,
    required this.name,
    this.unitId,
    this.unitQty,
    this.openingStock,
    this.secondaryUnitId,
    this.openingDate,
    this.status,
    this.image,
    this.secondaryUnitQty,
    this.salesPrice,
    this.purchasePrice,
    this.mrp,
    this.itemCategoryId,     // <- Must be added
    this.itemSubCategoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      unitId: json['unit_id'] != null && json['unit_id'] != "null"
          ? json['unit_id'].toString()
          : null,
      salesPrice: json['sales_price'] != null ? json['sales_price'] as int? : 0,
      purchasePrice: json['purchase_price'] != null ? json['purchase_price'] as int? : 0,
      mrp: json['mrp_price'] != null ? json['mrp_price'] as int? : 0,
      unitQty: json['unit_qty'] != null ? json['unit_qty'] as int? : null,
      openingStock: json['opening_stock'] != null ? json['opening_stock'] as int? : null,
      secondaryUnitId: json['secondary_unit_id'] != null ? json['secondary_unit_id'] as int? : null,
      secondaryUnitQty: json['secondary_unit_qty'] != null ? json['secondary_unit_qty'] as int? : null,
      openingDate: json['opening_date'] ?? '',
      status: json['status'] ?? 0,
      image: json['image'] ?? '',
       itemCategoryId: json['item_category_id'],      // <- Correct mapping
      itemSubCategoryId: json['item_sub_category_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  static List<ItemsModel> fromJsonMap(Map<String, dynamic> jsonMap) {
    return jsonMap.values
        .map((item) => ItemsModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}


 