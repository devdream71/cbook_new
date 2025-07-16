import 'dart:convert';
import 'package:cbook_dt/feature/account/ui/cash_in_hand/model/cash_in_hand.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 

class CashInHandProvider extends ChangeNotifier {
  CashInHandModel? cashInHandModel;
  bool isLoading = false;

  Future<void> fetchCashInHandData() async {
    isLoading = true;
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/accounts/cash-in/hand';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        cashInHandModel = CashInHandModel.fromJson(data);
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
