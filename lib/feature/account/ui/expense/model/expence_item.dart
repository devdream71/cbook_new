class ExpenseItem {
  final String receiptFrom;
  final String note;
  final double amount;
  final dynamic ? purchaseId;

  ExpenseItem({
    required this.receiptFrom,
    required this.note,
    required this.amount,
      this.purchaseId
  });
}