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

  ///update recived api call here 
  ///update received voucher
  Future<bool> updateReceivedVoucher(String voucherId, ReceivedVoucherRequest request) async {
    isLoading = true;
    notifyListeners();

    try {
      // Create query parameters for the URL
      final queryParams = {
        'id': voucherId,
        'user_id': request.userId.toString(),
        'voucher_person': request.voucherPerson.toString(),
        'voucher_number': request.voucherNumber,
        'voucher_date': request.voucherDate,
        'voucher_time': request.voucherTime,
        'received_to': request.receivedTo,
        'account_id': request.accountId.toString(),
        'received_from': request.receivedFrom.toString(),
        'percent': request.percent,
        'total_amount': request.totalAmount.toString(),
        'discount': request.discount.toString(),
        'notes': request.notes,
      };

      final uri = Uri.https(
        'commercebook.site',
        '/api/v1/receive-vouchers/update',
        queryParams,
      );

      // Create body with voucher_items
      final bodyData = {
        'voucher_items': request.voucherItems.map((item) => {
          'sales_id': item.salesId,
          'amount': item.amount,
        }).toList(),
      };

      final bodyJson = json.encode(bodyData);

      debugPrint('--- Update Received Voucher API Request ---');
      debugPrint('Request URL: $uri');
      debugPrint('Request Body JSON: $bodyJson');
      debugPrint('------------------------------------------');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: bodyJson,
      );

      debugPrint('Update API Status Code: ${response.statusCode}');
      debugPrint('Update API Response Body: ${response.body}');

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        // Refresh the vouchers list after successful update
        await fetchReceiveVouchers();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Exception in updateReceivedVoucher: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
