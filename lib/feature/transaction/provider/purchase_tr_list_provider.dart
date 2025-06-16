// import 'package:cbook_dt/feature/transaction/model/purchase_tr_list_model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
 
 
 
//  class PurchaseProvider extends ChangeNotifier {
//   PurchaseViewModel? _purchaseData;
//   bool _isLoading = false;
//   String? _errorMessage;

//    Map<int, String> _itemsMap = {};

//    Map<int, String> _unitsMap = {}; // Store unit symbols

//   PurchaseViewModel? get purchaseData => _purchaseData;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   Future<void> fetchPurchases() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     final url = Uri.parse('https://commercebook.site/api/v1/purchase/');
//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         _purchaseData = PurchaseViewModel.fromJson(data); 
//         print(data);
//         print(_purchaseData);
//       } 
//         else if (response.statusCode==404){
//           _errorMessage = "Error 404: Data Not found";

//         } else if (response.statusCode == 500){
//           _errorMessage = "Error 500: Inteernal Server Error.";
//         }  
      
//       else {
//         //throw Exception('Failed to load purchases');
//         _errorMessage = "Unexpected Error ${response.statusCode}";
//       }
//     } catch (e) {
//       _errorMessage = "Exception occurred $e";
//       print('Error fetching purchases: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//    Future<void> fetchItems() async {
//     final url = Uri.parse('https://commercebook.site/api/v1/items');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         List<dynamic> itemsList = data['data'];

//         _itemsMap = {for (var item in itemsList) item['id']: item['name']};
//         notifyListeners();
//       } else {
//         _errorMessage = "Error fetching items: ${response.statusCode}";
//       }
//     } catch (e) {
//       _errorMessage = "Exception fetching items: $e";
//     }
//   }

//   /// Fetch unit symbols
//   Future<void> fetchUnits() async {
//     final url = Uri.parse('https://commercebook.site/api/v1/units');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data["success"] == true) {
//           _unitsMap = {
//             for (var key in data["data"].keys)
//               int.parse(key): data["data"][key]["symbol"]
//           };
//         }
//       }
//     } catch (e) {
//       _errorMessage = "Error fetching units: $e";
//     }
//     notifyListeners();
//   }



//   String getItemName(int itemId) {
//     return _itemsMap[itemId] ?? "Unknown Item";
//   }

//    /// Get unit symbol by ID
//   String getUnitSymbol(int unitId) {
//     return _unitsMap[unitId] ?? "";
//   }



//   Future<void> fetchPurchasesAndItems() async {
//     await fetchPurchases();
//     await fetchItems(); // Fetch items along with purchases
//      await fetchUnits();
//   }
  
// }


 