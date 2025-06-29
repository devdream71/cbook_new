import 'dart:convert';
import 'package:cbook_dt/feature/Received/model/create_recived_voucher.dart';
import 'package:cbook_dt/feature/Received/model/edit_voucher_item_model.dart';
import 'package:cbook_dt/feature/Received/model/received_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceiveVoucherProvider with ChangeNotifier {
  List<ReceiveVoucherModel> _vouchers = [];
  bool isLoading = false;

  List<ReceiveVoucherModel> get vouchers => _vouchers;

  ///recived voucher item show all
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

  ///store recived voucher.
  Future<bool> storeReceivedVoucher(ReceivedVoucherRequest request) async {
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.https(
        'commercebook.site',
        '/api/v1/receive-vouchers/store',
        request.toQueryParameters(),
      );

      final bodyJson = json.encode(request.toJson());

      debugPrint('--- Received Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('------------------------------------');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: bodyJson,
      );

      debugPrint('API Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      isLoading = false;
      notifyListeners();

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Exception in storeReceivedVoucher: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  ///get by id for update.
  Future<Map<String, dynamic>?> fetchReceiveVoucherById(String id) async {
    final url =
        Uri.parse('https://commercebook.site/api/v1/receive-vouchers/edit/$id');

    try {
      final response = await http.get(url);
      debugPrint('Edit Voucher Response: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true && result['data'] != null) {
          return result['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Edit Voucher Fetch Error: $e");
      return null;
    }
  }
}
