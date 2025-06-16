class ItemModel {
  String? category;
  String? subCategory;
  String? itemName;
  String? itemCode;
  String? mrp;
  String? quantity;
  String? total;
  String? price;
  String? unit;

  ItemModel({
    this.category,
    this.subCategory,
    this.itemName,
    this.itemCode,
    this.mrp,
    this.quantity,
    this.total,
    this.price,
    this.unit,
  });

  @override
  String toString() {
    return 'ItemModel(itemName: $itemName, price: $price, quantity: $quantity, unit: $unit)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          itemCode == other.itemCode;

  @override
  int get hashCode => itemCode.hashCode;
}



 