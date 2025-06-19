class ExpenseItem {
    String receiptFrom;
    String note;
    double amount;
    dynamic ? purchaseId;

  ExpenseItem({
    required this.receiptFrom,
    required this.note,
    required this.amount,
      this.purchaseId
  });
}