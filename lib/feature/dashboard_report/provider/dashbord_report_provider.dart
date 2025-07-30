import 'dart:convert';
import 'package:cbook_dt/feature/dashboard_report/model/bank_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/customer_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/sale_data.dart';
import 'package:cbook_dt/feature/dashboard_report/model/supplier_trans.dart';
import 'package:cbook_dt/feature/dashboard_report/model/voucher_summary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 

class DashboardReportProvider extends ChangeNotifier {
  int? customerTransaction;
  bool isLoading = false;
  String? error;

  Future<void> fetchCustomerTransaction() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://commercebook.site/api/v1/dashboard/transection/customer?type=customer');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        customerTransaction = decoded['data'] ?? 0;
      } else {
        error = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  int? supplierTransaction;

  Future<void> fetchSupplierTransaction() async {
    _setLoading(true);

    try {
      final url = Uri.parse(
          'https://commercebook.site/api/v1/dashboard/transection/customer?type=suppliers');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        supplierTransaction =
            SupplierTransactionModel.fromJson(decoded).data;
      } else {
        error = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }



    int? cashInHand;

    Future<void> fetchCashInHandTransaction() async {
  final url = Uri.parse(
      'https://commercebook.site/api/v1/dashboard/transection?type=cash');
  try {
    isLoading = true;
    notifyListeners();

    final response = await http.post(url, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      cashInHand = jsonData['data'];
      error = null;
    } else {
      error = 'Failed to fetch cash in hand data';
    }
  } catch (e) {
    error = e.toString();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


BankBalanceModel? bankBalanceModel;

int? bankBalance;

 Future<void> fetchBankBalance() async {
  isLoading = true;
  error = null;
  notifyListeners();

  final url = Uri.parse('https://commercebook.site/api/v1/dashboard/transection?type=bank');

  try {
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      bankBalance = decoded['data'] ?? 0;
    } else {
      error = 'Server error: ${response.statusCode}';
    }
  } catch (e) {
    error = e.toString();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

VoucherSummary? voucherSummary;
Future<void> fetchVoucherSummary() async {
  isLoading = true;
  error = null;
  notifyListeners();

  final url = Uri.parse('https://commercebook.site/api/v1/dashboard/voucher-summary-30-days');

  try {
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      voucherSummary = VoucherSummary.fromJson(decoded['data']);
    } else {
      error = 'Server error: ${response.statusCode}';
    }
  } catch (e) {
    error = e.toString();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

List<SalesData> salesLast30Days = [];

Future<void> fetchSalesLast30Days() async {
  isLoading = true;
  error = null;
  notifyListeners();

  try {
    final url = Uri.parse('https://commercebook.site/api/v1/dashboard/sales-last-30-days');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> salesList = decoded['data'];
      salesLast30Days = salesList.map((item) => SalesData.fromJson(item)).toList();
    } else {
      error = "Server error: ${response.statusCode}";
    }
  } catch (e) {
    error = e.toString();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
  
}
