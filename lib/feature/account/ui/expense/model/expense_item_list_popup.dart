class ExpenseItemPopUp {
  final String accountId;
  final String narration;
  final String amount;

  ExpenseItemPopUp({
    required this.accountId,
    required this.narration,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'narration': narration,
        'amount': amount,
        
      };
}

class ExpenseStoreRequest {
  final List<ExpenseItemPopUp> expenseItems;

  ExpenseStoreRequest({required this.expenseItems});

  Map<String, dynamic> toJson() => {
        'expense_items': expenseItems.map((item) => item.toJson()).toList(),
      };
}
