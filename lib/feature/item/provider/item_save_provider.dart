import 'dart:convert';
import 'dart:io';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class ItemProvider with ChangeNotifier {
  Map<String, String> _priceValues = {};

  Map<String, String> get priceValues => _priceValues;

  void setPriceValues(Map<String, String> prices) {
    _priceValues = prices;
    notifyListeners();
  }

  Map<String, String> _categoryPriceValues = {};

  Map<String, String> get categoryPriceValues => _categoryPriceValues;

  void setCategoryPriceValues(Map<String, String> prices) {
    _categoryPriceValues = prices;
    notifyListeners();
  }

  // NEW: Store list of qty/price
  List<Map<String, String>> _qtyPriceList = [];
  List<Map<String, String>> get qtyPriceList => _qtyPriceList;

  // Add or update Qty and Price at a specific index
  void updateQtyPrice(int index, {required String qty, required String price}) {
    if (index < _qtyPriceList.length) {
      _qtyPriceList[index] = {'qty': qty, 'price': price};
    } else {
      _qtyPriceList.add({'qty': qty, 'price': price});
    }
    notifyListeners();
  }

  // Remove row
  void removeQtyPrice(int index) {
    if (index < _qtyPriceList.length) {
      _qtyPriceList.removeAt(index);
      notifyListeners();
    }
  }

  // Print all rows (You asked for this)
  void printAllQtyPrice() {
    for (int i = 0; i < _qtyPriceList.length; i++) {
      print(
          'Row $i: Qty = ${_qtyPriceList[i]['qty']}, Price = ${_qtyPriceList[i]['price']}');
    }

    print(jsonEncode(_qtyPriceList));
  }

  ////=======No need demo
  void removeQtyPrice2 (int index ){
    if(index < _qtyPriceList.length){
      _qtyPriceList.removeAt(index);
      notifyListeners();
    }
  }
   

  Future<void> saveItem(
    BuildContext context, {
    required String name,
    required String openingDate,
    required String status,
    required double price,
    required double value,
    required int stock,
    required int unitId,
    required int secondaryUnitId,
    required String unitQty,
    required int? selectedCategoryId, // ✅ Use int instead of String
    required int? selectedSubCategoryId, // ✅ Use int instead of String
  
    File? imageFile,
    String? salePrice,
    String? purchaePrice,
    String? mrpPrice,
    String? wholesalessPrice,
    String? dealersPrice,
    String? retailersPrice,
    String? brokersPrice,
    String? ecommercesPrice,
    String? selectedSalePriceOption, // "blank" or "1"
    String? selectedPurchasePriceOption, // "blank" or "1"
    String? selectedMrpPriceOption, // "blank" or "1"
  }) async {
    const String url = "https://commercebook.site/api/v1/item/store";

    // Debug prints to confirm the category and subcategory IDs
    debugPrint('Selected Category ID: $selectedCategoryId');
    debugPrint('Selected Subcategory ID: $selectedSubCategoryId');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getInt('user_id')?.toString() ?? '';

      var request = http.MultipartRequest("POST", Uri.parse(url));

      // Format opening date properly
      String formattedDate;
      if (openingDate.isNotEmpty && openingDate != "0000-00-00") {
        try {
          DateTime tempDate = DateFormat("dd-MM-yyyy").parse(openingDate);
          formattedDate = DateFormat("yyyy-MM-dd").format(tempDate);
        } catch (e) {
          formattedDate = DateTime.now().toIso8601String().split("T")[0];
        }
      } else {
        formattedDate = DateTime.now().toIso8601String().split("T")[0];
      }

      debugPrint("Formatted Opening Date: $formattedDate");

      // Add text fields
      request.fields["name"] = name;
      request.fields["opening_date"] = formattedDate;
      request.fields["status"] = status;
      request.fields["opening_stock"] = stock.toString();
      request.fields["opening_price"] = price.toString();
      request.fields["value"] = value.toString();
      request.fields["user_id"] = userId;
      request.fields["unit_qty"] = unitQty;
      request.fields["unit_id"] = unitId.toString();
      request.fields["secondary_unit_id"] = secondaryUnitId.toString();

      // Ensure category IDs are properly assigned
      if (selectedCategoryId != null) {
        request.fields["categories_id"] = selectedCategoryId.toString();
        debugPrint(
            'Item Category ID Added: ${selectedCategoryId.toString()}'); // Debug print
      }

      if (selectedSubCategoryId != null) {
        request.fields["sub_categories_id"] = selectedSubCategoryId.toString();
        debugPrint(
            'Item Subcategory ID Added: ${selectedSubCategoryId.toString()}'); // Debug print
      }

      // Sale Price Handling
      if (salePrice != null && salePrice.isNotEmpty) {
        request.fields["sales_price"] = salePrice;
        request.fields["sales_price_type"] = "1";
      }

      // Purchase Price Handling
      if (purchaePrice != null && purchaePrice.isNotEmpty) {
        request.fields["purchase_price"] = purchaePrice;
        request.fields["purchase_price_type"] = "1";
      }

      // MRP Price Handling
      if (mrpPrice != null && mrpPrice.isNotEmpty) {
        request.fields["mrps_price"] = mrpPrice;
      }

      if ( wholesalessPrice!= null && wholesalessPrice.isNotEmpty) {
        request.fields["wholesaless_price"] = wholesalessPrice;
      }

      if(dealersPrice!= null && dealersPrice.isNotEmpty) {
        request.fields['dealers_price'] = dealersPrice;
      }

      if(retailersPrice!=null && retailersPrice.isNotEmpty){
        request.fields['retailers_price'] = retailersPrice;
      }

      if(brokersPrice!=null && brokersPrice.isNotEmpty){
        request.fields['brokers_price'] = brokersPrice;
      }

      if(ecommercesPrice!=null && ecommercesPrice.isNotEmpty) {
        request.fields['wholesalessPrice'] = ecommercesPrice;
      }


      // Add Image File if available
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: path.basename(imageFile.path),
          ),
        );
      }

      // Debugging: Log all the request fields to check if they are being added correctly
      request.fields.forEach((key, value) {
        debugPrint('$key: $value'); // Debugging each field before sending
      });

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      debugPrint("Raw Response: ${response.body}");

      final responseData = json.decode(response.body);

      // Handle response message
      String message = responseData['message'] is String
          ? responseData['message']
          : responseData['message'].toString();

      if (response.statusCode == 200) {
        debugPrint("✅ Success: $message");

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!context.mounted) return;
          debugPrint("Navigating to Item List Page...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        });
      } else {
        debugPrint("❌ Error: $message");

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $message")),
        );
      }
    } catch (error) {
      debugPrint("❌ Exception: $error");

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save item")),
      );
    }
  }
}
