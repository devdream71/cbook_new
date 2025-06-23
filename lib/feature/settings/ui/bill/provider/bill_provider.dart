import 'dart:convert';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BillPersonProvider with ChangeNotifier {
  List<BillPersonModel> _billPersons = [];
  bool isLoading = false;
  String errorMessage = '';

  List<BillPersonModel> get billPersons => _billPersons;

  Future<void> fetchBillPersons() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/bill/person/list');

    try {
      final response = await http.get(url);
      debugPrint('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> billPersonsData = data['data'];
          _billPersons = billPersonsData.map((item) => BillPersonModel.fromJson(item)).toList();
        } else {
          errorMessage = 'Failed to load bill persons';
          _billPersons = [];
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        _billPersons = [];
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      _billPersons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
