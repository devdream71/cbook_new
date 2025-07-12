class ExpenseListModel {
  bool success;
  String message;
  List<ExpenseData> data;

  ExpenseListModel({required this.success, required this.message, required this.data});

  factory ExpenseListModel.fromJson(Map<String, dynamic> json) {
    return ExpenseListModel(
      success: json['success'],
      message: json['message'],
      data: List<ExpenseData>.from(json['data'].map((x) => ExpenseData.fromJson(x))),
    );
  }
}

class ExpenseData {
  int id;
  String type;
  String voucherNumber;
  String voucherDate;
  String voucherTime;
  String receivedTo;
  int totalAmount;
  String notes;
  int accountID;

  ExpenseData({
    required this.id,
    required this.type,
    required this.voucherNumber,
    required this.voucherDate,
    required this.voucherTime,
    required this.receivedTo,
    required this.totalAmount,
    required this.notes,
    required this.accountID,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      id: json['id'],
      type: json['type'] ?? '',
      voucherNumber: json['voucher_number'] ?? '',
      voucherDate: json['voucher_date'] ?? '',
      voucherTime: json['voucher_time'] ?? '',
      receivedTo: json['received_to'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      notes: json['notes'] ?? '',
      accountID: json['account_id'],
    );
  }
}
