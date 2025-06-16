import 'dart:convert';
import 'package:cbook_dt/feature/settings/model/model_user_setting.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SettingUserProvider with ChangeNotifier {
  
  final TextEditingController nameCOntroller = TextEditingController();
  final TextEditingController nickController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  List<SetingsUserModel> _users = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<SetingsUserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError; // 👈 Add this line

  Future<void> fetchUsers() async {
    _isLoading = true;
    _hasError = false; // reset error before fetching
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/users/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List usersJson = data['data'];
        _users = usersJson.map((e) => SetingsUserModel.fromJson(e)).toList();
      } else {
        _hasError = true;
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}





// // providers/user_provider.dart
// import 'dart:convert';
// import 'package:cbook_dt/feature/settings/model/model_user_setting.dart';
// import 'package:cbook_dt/utils/date_time_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SettingUserProvider with ChangeNotifier {
//   final TextEditingController nameCOntroller = TextEditingController();
//   final TextEditingController nickController = TextEditingController();

//   DateTime _selectedDate = DateTime.now();

//   String get formattedDate => DateTimeHelper.formatDate(_selectedDate);

//   Future<void> pickDate(BuildContext context) async {
//     final pickedDate = await DateTimeHelper.pickDate(context, _selectedDate);
//     if (pickedDate != null && pickedDate != _selectedDate) {
//       _selectedDate = pickedDate;
//       notifyListeners();
//     }
//   }

//   List<SetingsUserModel> _users = [];
//   bool _isLoading = false;

//   List<SetingsUserModel> get users => _users;
//   bool get isLoading => _isLoading;

//   Future<void> fetchUsers() async {
//     _isLoading = true;
//     notifyListeners();

//     const url = 'https://commercebook.site/api/v1/users/';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List usersJson = data['data'];
//         print(data);
//         _users = usersJson.map((e) => SetingsUserModel.fromJson(e)).toList();
//       }
//     } catch (e) {
//       debugPrint("Error fetching users: $e");
//     }

//     _isLoading = false;
//     notifyListeners();
//   }
// }
