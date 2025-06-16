import 'dart:convert'; 
import 'package:cbook_dt/feature/customer_create/model/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_list.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class CustomerProvider extends ChangeNotifier {

  
  Customer? _selectedCustomer;
  
  Customer? get selectedCustomer => _selectedCustomer;

   void setSelectedCustomer(Customer customer) {
   _selectedCustomer = customer;
   notifyListeners();
   }

   void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  } 

  void clearCustomerList() {
  customerResponse = null;
  notifyListeners();
} 

  bool isLoading = false;
  CustomerResponse? customerResponse;

  String errorMessage = "";

  ///show supplier
  Future<void> fetchCustomsr() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners(); // Notify listeners that data is being fetched

    //final url = Uri.parse('https://commercebook.site/api/v1/customers/list');

    final url = Uri.parse('https://commercebook.site/api/v1/all/customers/'); //api/v1/all/customers/


    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      // Print the entire response in the terminal
      debugPrint("API Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        customerResponse = CustomerResponse.fromJson(data);
        // Print the parsed data for debugging
        debugPrint("Parsed Supplier Data: ${customerResponse!.data}");
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
  Future<void> deleteCustomer(int supplierId) async {
    final url = Uri.parse(
        'https://commercebook.site/api/v1/customer/remove/$supplierId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Ensure JSON request
          'Accept': 'application/json', // Ensure JSON response
        },
      );
      final data = jsonDecode(response.body);

      debugPrint("Delete Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        // Remove the deleted supplier from the local list
        customerResponse?.data.remove(supplierId);
        notifyListeners();
        fetchCustomsr();
        notifyListeners();
      } else {
        debugPrint("Error deleting supplier: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

 
  /// Create new customer
Future<void> createCustomer({
  required String name,
  required String email,
  required String phone,
  required String address,
  required String status, // '1' or '0'
  required String proprietorName,
  required String openingBalance,
  String levelType = "",
  String level = "",
}) async {
  isLoading = true;
  errorMessage = "";
  notifyListeners();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getInt('user_id')?.toString() ?? '';

  final url = Uri.parse('https://commercebook.site/api/v1/customer/store');

  try {
    // Build the request body dynamically
    Map<String, dynamic> body = {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status, // Ensure it's '1' or '0'
      'proprietor_name': proprietorName,
      'opening_balance': openingBalance,
    };

    // Add level_type and level only if levelType is not empty
    if (levelType.isNotEmpty) {
      body['level_type'] = levelType;
      body['level'] = "1";
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Debugging: Print the raw response
    debugPrint("Response Status: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        debugPrint("Customer Created: ${data['data']['name']}");

    

      } else {
        errorMessage = data['message'] ?? "Failed to create customer";
      }
    } else {
      errorMessage = "Unexpected response from the server";
    }
  } catch (e) {
    errorMessage = "Error: $e";
    debugPrint("Error: $e");
  }

  isLoading = false;
  notifyListeners();
}




  ///get customer by id
  Future<CustomerData?> fetchCustomerById(int customerId) async {
    final url =
        Uri.parse('https://commercebook.site/api/v1/customer/edit/$customerId');
    try {
      final response = await http.get(url);
      debugPrint("API Response: ${response.body}"); // 🔍 Debugging Step

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return CustomerCreateResponse.fromJson(data).data;
      } else {
        debugPrint("Error fetching customer: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return null;
  }

  ///customer update
  // Future<void> updateCustomer({
  //   required String id,
  //   required String name,
  //   required String proprietorName,
  //   required String email,
  //   required String phone,
  //   required String address,
  //   required String status,
  //   required BuildContext context,
  // }) async {
  //   isLoading = true;
  //   errorMessage = "";
  //   notifyListeners();

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userId = prefs.getInt('user_id')?.toString();

  //   if (userId == null || userId.isEmpty) {
  //     errorMessage = "User ID is not available. Please login again.";
  //     isLoading = false;
  //     notifyListeners();
  //     return;
  //   }

  //   // Check if supplier ID is provided correctly
  //   if (id.isEmpty || id == '0') {
  //     errorMessage = "Supplier ID is not valid!";
  //     isLoading = false;
  //     notifyListeners();
  //     return;
  //   }

  //   final url = Uri.parse(
  //       'https://commercebook.site/api/v1/customer/update?user_id=$userId&id=$id&name=$name&proprietor_name=$proprietorName&email=$email&phone=$phone&address=$address&status=$status');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   try {
  //     final data = jsonDecode(response.body);
  //     if (response.statusCode == 200 && data["success"] == true) {
  //       debugPrint("Supplier updated successfully");
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => const HomeView()));
  //     } else {
  //       errorMessage = data["message"] ?? "Failed to update supplier";
  //     }
  //   } catch (e) {
  //     errorMessage = "Error: $e";
  //   }

  //   isLoading = false;
  //   notifyListeners();
  // }

Future<void> updateCustomer({
  required String id,
  required String name,
  required String proprietorName,
  required String email,
  required String phone,
  required String address,
  required String status,
  required String level, // "0" or "1"
  required String levelType, // Only used if level is "1"
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

  if (id.isEmpty || id == '0') {
    errorMessage = "Customer ID is not valid!";
    isLoading = false;
    notifyListeners();
    return;
  }

  final url = Uri.parse('https://commercebook.site/api/v1/customer/update');

  Map<String, dynamic> body = {
    'user_id': userId,
    'id': id,
    'name': name,
    'proprietor_name': proprietorName,
    'email': email,
    'phone': phone,
    'address': address,
    'status': status,
    'level': level,
  };

  // Only add `level_type` if level is "1"
  if (level == "1") {
    body['level_type'] = levelType;
  }

  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  try {
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      debugPrint("Customer updated successfully");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeView()));
    } else {
      errorMessage = data["message"] ?? "Failed to update customer";
    }
  } catch (e) {
    errorMessage = "Error: $e";
  }

  isLoading = false;
  notifyListeners();
}

}
