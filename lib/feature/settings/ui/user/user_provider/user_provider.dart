import 'dart:convert';
import 'package:cbook_dt/feature/settings/model/model_user_setting.dart';
import 'package:cbook_dt/feature/settings/ui/user/model/role_model.dart';
import 'package:cbook_dt/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingUserProvider with ChangeNotifier {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nickController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confromController = TextEditingController();




  

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

  
  ///fetch user
  Future<void> fetchUsers() async {
    _isLoading = true;
    _hasError = false; // reset error before fetching
    notifyListeners();

    const url = 'https://commercebook.site/api/v1/users/list/';
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

  ///delete user
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final url = Uri.parse('https://commercebook.site/api/v1/users/remove/$id');

    try {
      final response = await http.post(url); // or POST if backend expects POST

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _users.removeWhere((user) => user.id == id);
          notifyListeners();
          debugPrint("✅ User deleted successfully.");
          return true;
        } else {
          _errorMessage = data['message'] ?? "Failed to delete user.";
          debugPrint("❌ $errorMessage");
          return false;
        }
      } else {
        _errorMessage = "Server error: ${response.statusCode}";
        debugPrint("❌ $_errorMessage");
        return false;
      }
    } catch (e) {
      _errorMessage = "Exception: $e";
      debugPrint("❌ $_errorMessage");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  
  ///role mnodel.
  List<RoleModel> _roles = [];
  List<RoleModel> get roles => _roles;

  Future<void> fetchRoles() async {
    const url = 'https://commercebook.site/api/v1/roles/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rolesJson = data['data'];
        _roles = rolesJson.map((e) => RoleModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        debugPrint("❌ Failed to fetch roles: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching roles: $e");
    }
  }
}
