import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/expense/model/expence_item.dart';
import 'package:cbook_dt/feature/account/ui/expense/model/expense_paid_form_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// class ExpenseProvider with ChangeNotifier {
//   List<PaidFormData> paidFormList = [];

//   List<ExpenseItem> receiptItems = [];
  
//   bool isLoading = false;

//   Future<void> fetchPaidFormList() async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final response = await http.get(Uri.parse('https://commercebook.site/api/v1/expense/paid/form/list'));

//       if (response.statusCode == 200) {
//         final result = PaidFormModel.fromJson(json.decode(response.body));
//         paidFormList = result.data;
//       } else {
//         print('Failed to load paid form list');
//       }
//     } catch (e) {
//       print('Error fetching paid form list: $e');
//     }

//     isLoading = false;
//     notifyListeners();

//      // ✅ This is the missing method
//   void addReceiptItem(ExpenseItem item) {
//     receiptItems.add(item);
//     notifyListeners();
//   }

//   }
// }



class ExpenseProvider with ChangeNotifier {
  List<PaidFormData> paidFormList = [];
  List<ExpenseItem> receiptItems = [];

  bool isLoading = false;

  // ✅ API Fetch Method
  Future<void> fetchPaidFormList() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://commercebook.site/api/v1/expense/paid/form/list'));

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

  // ✅ Move this method outside
  void addReceiptItem(ExpenseItem item) {
    receiptItems.add(item);
    notifyListeners();
  }
}
