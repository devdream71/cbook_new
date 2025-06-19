import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/suppliers/provider/suppliers_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuppliersCreate extends StatefulWidget {
  const SuppliersCreate({super.key});

  @override
  State<SuppliersCreate> createState() => _SuppliersCreateState();
}

class _SuppliersCreateState extends State<SuppliersCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _proprietorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _opiningBanglaceController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String selectedStatus = "1"; // Default status

  void _saveSupplier() async {
    final supplierProvider =
        Provider.of<SupplierProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final status = selectedStatus;
    final proprietorName = _proprietorController.text.trim();
    final openingBalance = _opiningBanglaceController.text.trim();

    // ✅ Basic required field check
    if (name.isNotEmpty &&
        proprietorName.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        openingBalance.isNotEmpty) {
      await supplierProvider.createSupplier(
        name: name,
        email: email,
        phone: phone,
        address: address,
        status: status,
        proprietorName: proprietorName,
        openingBalance: openingBalance,
      );

      if (supplierProvider.errorMessage.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Supplier Created",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Clear form
        _nameController.clear();
        _proprietorController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _opiningBanglaceController.clear();
        _statusController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              supplierProvider.errorMessage,
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all required fields.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = Provider.of<SupplierProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Create Supplier",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AddSalesFormfield(
                label: "Enter Supplier Name",
                controller: _nameController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                label: "Enter Proprietor Name",
                controller: _proprietorController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                label: "Enter Email",
                controller: _emailController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                label: "Enter Phone",
                controller: _phoneController,
                keyboardType: TextInputType.number,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                label: "Enter Address",
                controller: _addressController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              AddSalesFormfield(
                label: "Enter Opening Balance",
                controller: _opiningBanglaceController,
                //validator: _validateRequired,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                "Status",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
              SizedBox(
                width: double.infinity,
                child: CustomDropdownTwo(
                  items: const ["Active", "Inactive"], // Display labels
                  hint: '', //Select status
                  width: double.infinity,
                  height: 30,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = (value == "Active")
                          ? "1"
                          : "0"; // ✅ Convert label to 1 or 0
                    });
                    debugPrint(selectedStatus);
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSupplier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Save Supplier",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildFieldLabel(
      String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
