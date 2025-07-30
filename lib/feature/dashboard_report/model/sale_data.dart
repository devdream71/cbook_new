class SalesData {
  final String date;
  final int sales;

  SalesData({required this.date, required this.sales});

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      date: json['date'],
      sales: json['sales'],
    );
  }
}
