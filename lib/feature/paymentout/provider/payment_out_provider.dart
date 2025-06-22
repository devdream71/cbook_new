import 'dart:convert';
import 'package:cbook_dt/feature/paymentout/model/bill_person_list.dart';
import 'package:cbook_dt/feature/paymentout/model/payment_out_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PaymentVoucherProvider with ChangeNotifier {
  List<PaymentVoucherModel> _vouchers = [];
  bool isLoading = false;

  List<PaymentVoucherModel> get vouchers => _vouchers;


  ///bill person
  List<BillPersonModel> _billPersons = [];
  List<BillPersonModel> get billPersons => _billPersons;

    List<String> get billPersonNames => _billPersons.map((e) => e.name).toList();

  //bill person api call.
   Future<void> fetchBillPersons() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/bill/person/list');

    try {
      final response = await http.get(url);
      debugPrint('Bill Person API Response: ${response.body}');

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final List<dynamic> data = extractedData['data'];

        _billPersons = data.map((item) => BillPersonModel.fromJson(item)).toList();
      } else {
        _billPersons = [];
      }
    } catch (e) {
      debugPrint('Bill Person API Error: $e');
      _billPersons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  

  /////show payment voucher
  Future<void> fetchPaymentVouchers() async {
  isLoading = true;
  notifyListeners();

  final url = Uri.parse('https://commercebook.site/api/v1/payment-vouchers');

  try {
    final response = await http.get(url);
    debugPrint('API STATUS CODE: ${response.statusCode}');
    debugPrint('API RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final extractedData = json.decode(response.body);
      if (extractedData['success'] == true && extractedData['data'] != null) {
        final List<dynamic> data = extractedData['data'];
        debugPrint('DATA LENGTH: ${data.length}');

        _vouchers = data
            .map((voucher) => PaymentVoucherModel.fromJson(voucher))
            .toList();
      } else {
        debugPrint('Data key is null or API success false');
        _vouchers = [];
      }
    } else {
      debugPrint('HTTP ERROR');
      _vouchers = [];
    }
  } catch (error) {
    debugPrint('EXCEPTION: $error');
    _vouchers = [];
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


///delete payment voucher
Future<bool> deletePaymentVoucher(String id) async {
  final url = Uri.parse('https://commercebook.site/api/v1/payment-vouchers/removes?id=$id');
  try {
    final response = await http.post(url); 
    debugPrint('DELETE RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        await fetchPaymentVouchers(); // ✅ Refresh the list after deletion
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
