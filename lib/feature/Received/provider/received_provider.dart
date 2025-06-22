import 'dart:convert';
import 'package:cbook_dt/feature/Received/model/received_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceiveVoucherProvider with ChangeNotifier {
  List<ReceiveVoucherModel> _vouchers = [];
  bool isLoading = false;

  List<ReceiveVoucherModel> get vouchers => _vouchers;

  Future<void> fetchReceiveVouchers() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/receive-vouchers');

    try {
      final response = await http.get(url);
      debugPrint('Receive Voucher API Response: ${response.body}');

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final List<dynamic> data = extractedData['data'];

        _vouchers =
            data.map((item) => ReceiveVoucherModel.fromJson(item)).toList();
      } else {
        _vouchers = [];
      }
    } catch (e) {
      debugPrint('Receive Voucher API Error: $e');
      _vouchers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///delete payment voucher
  Future<bool> deleteRecivedVoucher(String id) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/receive-vouchers/removes?id=$id');
    try {
      final response = await http.post(url);
      debugPrint('DELETE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          await fetchReceiveVouchers(); // ✅ Refresh the list after deletion
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
      return false;
    }
  }
}
