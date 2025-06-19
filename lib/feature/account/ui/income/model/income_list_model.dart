class IncomeListModel {
  bool success;
  String message;
  List<IncomeData> data;

  IncomeListModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory IncomeListModel.fromJson(Map<String, dynamic> json) {
    return IncomeListModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<IncomeData>.from(json['data'].map((e) => IncomeData.fromJson(e)))
          : [],
    );
  }
}

class IncomeData {
  int id;
  String type;
  int userId;
  String voucherNumber;
  String voucherDate;
  String voucherTime;
  String receivedTo;
  double totalAmount;
  int ? accountId;

  IncomeData({
    required this.id,
    required this.type,
    required this.userId,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.receivedTo,
    required this.totalAmount,
    this.accountId,
  });

  factory IncomeData.fromJson(Map<String, dynamic> json) {
    return IncomeData(
      id: json['id'],
      type: json['type'] ?? '',
      userId: int.parse(json['user_id'].toString()),
      voucherNumber: json['voucher_number'] ?? '',
      voucherDate: json['voucher_date'] ?? '',
      voucherTime: json['voucher_time'] ?? '',
      receivedTo: json['received_to'] ?? '',
      totalAmount: double.parse(json['total_amount'].toString()),
      accountId: int.parse(json['account_id'].toString()),
    );
  }
}




 