// models/payment_voucher_model.dart
class PaymentVoucherCustomer {
  final String billNumber;
  final String purchaseDate;
  final String voucherDate;
  final double grossTotal;
  final double due;

  PaymentVoucherCustomer({
    required this.billNumber,
    required this.purchaseDate,
    required this.voucherDate,
    required this.grossTotal,
    required this.due,
  });

  factory PaymentVoucherCustomer.fromJson(Map<String, dynamic> json) {
    return PaymentVoucherCustomer(
      billNumber: json['bill_number'],
      purchaseDate: json['purchase_date'],
      voucherDate: json['voucher_date'],
      grossTotal: (json['gross_total'] as num).toDouble(),
      due: (json['due'] as num).toDouble(),
    );
  }
}
