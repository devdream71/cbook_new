import 'dart:convert';
import 'package:cbook_dt/feature/tax/model/tax_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaxProvider with ChangeNotifier {
  List<TaxModel> _taxList = [];
  bool _isLoading = false;

  List<TaxModel> get taxList => _taxList;
  bool get isLoading => _isLoading;

  
  ///tax show list ====> 
  Future<void> fetchTaxes() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/tax');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> taxesJson = data['data'];

        _taxList = taxesJson.map((json) => TaxModel.fromJson(json)).toList();
      } else {
        debugPrint("Failed to load tax data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching tax data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  
  ///tax create ===>
    Future<void> createTax({
    required int userId,
    required String name,
    required String percent,
    required int status,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://commercebook.site/api/v1/tax/store?user_id=$userId&name=$name&percent=$percent&status=$status');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newTax = TaxModel.fromJson(data['data']);
        _taxList.add(newTax);
        fetchTaxes();
        notifyListeners();
        
        debugPrint("Tax created successfully: ${data['message']}");
      } else {
        debugPrint("Failed to create tax: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error during tax creation: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  ///tax delete ====>
  Future<void> deleteTax(int id) async {
    _isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('https://commercebook.site/api/v1/tax/remove/?id=$id');

    try {
      final response =
          await http.get(url); // Assuming the delete is a GET request
      if (response.statusCode == 200) {
        _taxList.removeWhere((tax) => tax.id == id);
        notifyListeners();
        debugPrint("Tax deleted successfully!");
      } else {
        debugPrint("Failed to delete tax: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error deleting tax: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  
  ///get tex by id
  Future<TaxModel?> getTaxById(int id) async {
    final url = Uri.parse('https://commercebook.site/api/v1/tax/edit/$id');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TaxModel(
          id: id,
          userId: 0, // userId is not returned in response
          name: data['data']['name'],
          percent: data['data']['percent'],
          status: data['data']['status'],
        );
      }
    } catch (e) {
      debugPrint("Error fetching tax details: $e");
    }
    return null;
  }

  
  ///tax update===>
  Future<void> updateTax({
    required int id,
    required String name,
    required String percent,
    required int status,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'https://commercebook.site/api/v1/tax/store?id=$id&name=$name&percent=$percent&status=$status',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        await fetchTaxes(); // Refresh list after update
        debugPrint("Tax updated successfully.");
      } else {
        debugPrint("Update failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error updating tax: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
