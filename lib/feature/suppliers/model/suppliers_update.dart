// class SupplierUpdateModel {
//   final String name;
//   final String proprietorName;
//   final String email;
//   final String phone;
//   final String address;
//   final double openingBalance;
//   final int status;

//   SupplierUpdateModel({
//     required this.name,
//     required this.proprietorName,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.openingBalance,
//     required this.status,
//   });

//   factory SupplierUpdateModel.fromJson(Map<String, dynamic> json) {
//     return SupplierUpdateModel(
//       name: json['name'] ?? '',
//       proprietorName: json['proprietor_name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       openingBalance: (json['opening_balance'] ?? 0).toDouble(),
//       status: json['status'] ?? 0,
//     );
//   }
// }
