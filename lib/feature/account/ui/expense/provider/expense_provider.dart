import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/expense/model/expence_item.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_model.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_item_list_popup.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_paid_form_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/update_expense_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpenseProvider with ChangeNotifier {
  List<PaidFormData> paidFormList = [];
  List<ExpenseItem> receiptItems = [];

  ExpenseListModel? expenseModel;

  bool isLoading = false;

  List<ExpenseData> expenseList = [];

  void addReceiptItem(ExpenseItem item) {
    receiptItems.add(item);
    notifyListeners();
  }

  void clearReceiptItems() {
    receiptItems.clear();
    notifyListeners();
  }
  

  ///getting expemse paid form list
  String getAccountNameById(int id) {
  try {
    return paidFormList.firstWhere((element) => element.id == id).accountName;
  } catch (e) {
    return 'Unknown'; // fallback if ID not found
  }
}

  ///expense list api call
  Future<void> fetchExpenseList() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://commercebook.site/api/v1/expense/list'));

      if (response.statusCode == 200) {
        final result = ExpenseListModel.fromJson(json.decode(response.body));
        expenseList = result.data;
      } else {
        print('Failed to load expense list');
      }
    } catch (e) {
      print('Error fetching expense list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///expense update
  ExpenseEditModel? editExpenseData;

  ///expense update
  Future<void> fetchEditExpense(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://commercebook.site/api/v1/expense/edit/$id'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        editExpenseData = ExpenseEditModel.fromJson(result['data']);

        // Map API voucher details to receiptItems for showing in UI
        receiptItems = editExpenseData!.voucherDetails.map((detail) {
          return ExpenseItem(
            purchaseId: detail.purchaseId,
            receiptFrom: editExpenseData!.paidTo,
            note: detail.narration,
            amount: detail.amount,
          );
        }).toList();
      } else {
        debugPrint('Failed to load expense edit data');
      }
    } catch (e) {
      debugPrint('Error fetching expense edit data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///expense delete
  Future<void> deleteExpense(String id) async {
    final url = 'https://commercebook.site/api/v1/expense/remove?id=$id';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        expenseModel?.data.remove(id);
        notifyListeners(); // This will refresh the UI
      } else {
        print('Failed to delete income');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ API Fetch Method ///expense Paid From list
  Future<void> fetchPaidFormList() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
          Uri.parse('https://commercebook.site/api/v1/expense/paid/form/list'));

      if (response.statusCode == 200) {
        final result = PaidFormModel.fromJson(json.decode(response.body));
        paidFormList = result.data;
      } else {
        print('Failed to load paid form list');
      }
    } catch (e) {
      print('Error fetching paid form list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///expense create.
  Future<bool> storeExpense({
    required String userId,
    required String invoiceNo,
    required String date,
    required String receivedTo,
    required String account,
    required double totalAmount,
    required String notes,
    required int status,
    required List<ExpenseItemPopUp> expenseItems,
  }) async {
    final url = Uri.parse('https://commercebook.site/api/v1/expense/store?'
        'user_id=$userId&invoice_no=$invoiceNo&date=$date&paid_to=$receivedTo&account=$account&total_amount=$totalAmount&notes=$notes&status=$status');

    final body = ExpenseStoreRequest(expenseItems: expenseItems).toJson();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // You can parse the response if needed
        return true;
      } else {
        debugPrint('Failed to store expense: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error storing express: $e');
      return false;
    }
  }
}
