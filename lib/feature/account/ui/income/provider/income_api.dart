// income_provider.dart
import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/income/model/account_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_item.dart';
import 'package:cbook_dt/feature/account/ui/income/model/income_list_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_form_model.dart';
import 'package:cbook_dt/feature/account/ui/income/model/recived_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IncomeProvider with ChangeNotifier {
  IncomeListModel? incomeModel;
  bool isLoading = false;

  AccountModel? accountModel;
  List<String> accountNames = [];
  bool isAccountLoading = false;

  // Receipt From API
  ReceiptFromModel? receiptFromModel;
  List<String> receiptFromNames = [];
  bool isReceiptLoading = false;

  List<ReceiptItem> receiptItems = [];

  void addReceiptItem(ReceiptItem item) {
    receiptItems.add(item);
    notifyListeners();
  }

  void clearReceiptItems() {
    receiptItems.clear();
    notifyListeners();
  }

  ///recived form
  Future<void> fetchReceiptFromList() async {
    print('=== Starting fetchReceiptFromList ===');

    isReceiptLoading = true;
    notifyListeners();

    final url = 'https://commercebook.site/api/v1/income/receive/form/list';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        receiptFromModel = ReceiptFromModel.fromJson(data);
        receiptFromNames =
            receiptFromModel!.data.map((e) => e.accountName).toList();

        print('Fetched Receipt From Names: $receiptFromNames');
      } else {
        print('API Error: Status ${response.statusCode}');
        receiptFromModel = null;
        receiptFromNames = [];
      }
    } catch (e) {
      print('Exception occurred: $e');
      receiptFromModel = null;
      receiptFromNames = [];
    }

    isReceiptLoading = false;
    print('=== fetchReceiptFromList completed ===');
    notifyListeners();
  }

  /// fetch account
  Future<void> fetchAccounts(String type) async {
    print('=== Starting fetchAccounts for type: $type ===');

    isAccountLoading = true;
    notifyListeners();

    final url =
        'https://commercebook.site/api/v1/receive/form/account?type=$type';
    print('API URL: $url');

    try {
      print('Making API request...');
      final response = await http.post(Uri.parse(url));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      print('response Status code');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed JSON Data: $data');

        accountModel = AccountModel.fromJson(data);
        accountNames = accountModel!.data.map((e) => e.accountName).toList();

        print('Account Model Created Successfully');
        print('Total Accounts Found: ${accountModel!.data.length}');
        print('Account Names: $accountNames');

        // Print detailed account info
        for (int i = 0; i < accountModel!.data.length; i++) {
          final account = accountModel!.data[i];
          print('Account $i: ID=${account.id}, Name=${account.accountName}');
        }
      } else {
        print('API Error: Status ${response.statusCode}');
        print('Error Body: ${response.body}');

        // Clear previous data on error
        accountModel = null;
        accountNames = [];
      }
    } catch (e, st) {
      print('Exception occurred: $e');
      print(st);
      print('Stack trace: ${StackTrace.current}');

      print('❌ Exception: $e');

      // Clear data on exception
      accountModel = null;
      accountNames = [];
    }

    isAccountLoading = false;
    print('=== fetchAccounts completed. Loading state: $isAccountLoading ===');
    notifyListeners();
  }

  ///income list.
  Future<void> fetchIncomeList() async {
    isLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/income/list';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        incomeModel = IncomeListModel.fromJson(data);
      }
    } catch (e) {
      print('Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  ///delete income. ====>>>>>>><<<<<<
  Future<void> deleteIncome(String id) async {
    final url = 'https://commercebook.site/api/v1/income/remove?id=$id';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        incomeModel?.data
            .removeWhere((income) => income.id.toString() == id); // ✅ Correct
        notifyListeners(); // This will refresh the UI
      } else {
        print('Failed to delete income');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  ///create the income.
  Future<bool> storeIncome({
    required String userId,
    required String invoiceNo,
    required String date,
    required String receivedTo,
    required String account,
    required double totalAmount,
    required String notes,
    required int status,
    required List<IncomeItem> incomeItems,
  }) async {
    final url = Uri.parse('https://commercebook.site/api/v1/income/store?'
        'user_id=$userId&invoice_no=$invoiceNo&date=$date&received_to=$receivedTo&account=$account&total_amount=$totalAmount&notes=$notes&status=$status');

    final body = IncomeStoreRequest(incomeItems: incomeItems).toJson();

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
        debugPrint('Failed to store income: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error storing income: $e');
      return false;
    }
  }

  ///get the income to edit income.

  /// update the income.

  ///acoount type
}
