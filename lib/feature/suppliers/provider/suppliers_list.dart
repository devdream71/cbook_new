import 'dart:convert';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/suppliers/model/suppliers_creat.dart';
import 'package:cbook_dt/feature/suppliers/model/suppliers_list.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupplierProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  bool isLoading = false;
  SupplierResponse? supplierResponse;
  String errorMessage = "";

  ///show supplier
  Future<void> fetchSuppliers() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners(); // Notify listeners that data is being fetched

    final url = Uri.parse('https://commercebook.site/api/v1/suppliers');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      // Print the entire response in the terminal
      debugPrint("API Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        supplierResponse = SupplierResponse.fromJson(data);
        // Print the parsed data for debugging
        debugPrint("Parsed Supplier Data: ${supplierResponse!.data}");
      } else {
        errorMessage = "Failed to fetch suppliers";
        debugPrint("Error: $errorMessage");
      }
    } catch (e) {
      errorMessage = "Error: $e";
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners(); // Notify after data fetch is completed
  }

  /// **Delete Supplier**
  Future<void> deleteSupplier(int supplierId) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/supplier/remove/$supplierId');

    try {
      final response = await http.post(url);
      final data = jsonDecode(response.body);

      debugPrint("Delete Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        // Remove the deleted supplier from the local list
        supplierResponse?.data.remove(supplierId);
        notifyListeners();
        fetchSuppliers();
        notifyListeners();
      } else {
        debugPrint("Error deleting supplier: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  
  ///  **create supplier**
  
  Future<void> createSupplier({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String status, // Expecting '1' or '0' as strings
    required String proprietorName,
    required String openingBalance,
  }) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getInt('user_id')?.toString();

    if (userId == null || userId.isEmpty) {
      errorMessage = "User ID is missing. Please log in again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('https://commercebook.site/api/v1/supplier/store');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'user_id':
            userId, // ✅ Fix: Send user_id in the body instead of query params
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'status': status, // ✅ Ensure '1' or '0' is passed
        'proprietor_name': proprietorName,
        'opening_balance': openingBalance,
      },
    );

    try {
      final data = jsonDecode(response.body);
      debugPrint("Create Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        debugPrint("Supplier Created: ${data['data']['name']}");
      } else {
        errorMessage = data['message'] ?? "Failed to create supplier";
      }
    } catch (e) {
      errorMessage = "Error: $e";
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  
  /// **featch supplier by id**
  Future<SupplierData?> fetchSupplierById(int supplierId) async {
    final url =
        Uri.parse('https://commercebook.site/api/v1/supplier/edit/$supplierId');
    try {
      final response = await http.get(url);
      debugPrint("API Response: ${response.body}"); // 🔍 Debugging Step

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return SupplierCreateResponse.fromJson(data).data;
      } else {
        debugPrint("Error fetching supplier: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return null;
  }

  
  /// **update supplier**
  Future<void> updateSupplier({
    required String id,
    required String name,
    required String proprietorName,
    required String email,
    required String phone,
    required String address,
    required String status,
    required BuildContext context,
  }) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getInt('user_id')?.toString();

    if (userId == null || userId.isEmpty) {
      errorMessage = "User ID is not available. Please login again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    // Check if supplier ID is provided correctly
    if (id.isEmpty || id == '0') {
      errorMessage = "Supplier ID is not valid!";
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse(
        'https://commercebook.site/api/v1/supplier/update?user_id=$userId&id=$id&name=$name&proprietor_name=$proprietorName&email=$email&phone=$phone&address=$address&status=$status');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        debugPrint("Supplier updated successfully");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomeView()));
      } else {
        errorMessage = data["message"] ?? "Failed to update supplier";
      }
    } catch (e) {
      errorMessage = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
