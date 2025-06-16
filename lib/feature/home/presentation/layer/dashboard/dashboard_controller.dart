
import 'package:cbook_dt/feature/purchase/purchase_list_api.dart';
import 'package:cbook_dt/feature/sales/sales_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dashboard_view.dart';

class DashboardController extends ChangeNotifier {
  final List<Map<String, String>> data = [
    {"label": "Opening Stock", "value": "10,000"},
    {"label": "Purchase/Add", "value": "25,000"},
    {"label": "P.Return/Reduce", "value": "3,000"},
    {"label": "Sales", "value": "10,000"},
    {"label": "Sales Return", "value": "25,000"},
    {"label": "Closing Stock", "value": "3,000"},
     
  ];

  void showFeatureNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Not Available'),
        content: const Text(
          'This feature is not available right now.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



  final List<ServiceBottmModel> buttonConfigurations = [
    // ServiceBottmModel('Sales', const SalesView()),
    //ServiceBottmModel('Purchase ', const PurchaseView()),
    ServiceBottmModel('Sales', SalesScreen()),

    ServiceBottmModel('Purchase ', const PurchaseListApi()),

  ];


  
  addButton(ServiceBottmModel data) {
    buttonConfigurations.add(data);
    notifyListeners();
  }

  bool isDeleted = false;
  void updateShowDeleteIcon() {
    isDeleted = !isDeleted;
    debugPrint(isDeleted.toString());
    notifyListeners();
  }

  void deletedThePage(int index) {
    if (index != 0 && index != 1) {
      buttonConfigurations.removeAt(index);
      isDeleted = false;
    }

    notifyListeners();
  }

  
  
}
