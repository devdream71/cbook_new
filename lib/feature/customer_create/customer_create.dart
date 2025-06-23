import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/price_option_selector_customer.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerCreate extends StatefulWidget {
  const CustomerCreate({super.key});

  @override
  State<CustomerCreate> createState() => _CustomerCreateState();
}

class _CustomerCreateState extends State<CustomerCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _proprietorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _opiningBanglaceController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _selectedPrice = "";
  bool _isChecked = false;

  String selectedStatus = "1"; // Default status

  // Validation functions
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    final phoneRegex =
        RegExp(r'^\d{10,15}$'); // Ensure only numbers, 10-15 digits
    if (!phoneRegex.hasMatch(value)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  bool isLoading = false;

  void _saveCustomer() async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final status = selectedStatus;
    final proprietorName = _proprietorController.text.trim();
    final openingBalance = _opiningBanglaceController.text.trim();
    final levelType = _isChecked ? _selectedPrice : "";
    final level = _isChecked ? "1" : "";

    if (name.isNotEmpty &&
        proprietorName.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        openingBalance.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await customerProvider.createCustomer(
        name: name,
        email: email,
        phone: phone,
        address: address,
        status: status,
        proprietorName: proprietorName,
        openingBalance: openingBalance,
        levelType: levelType,
        level: level,
      );

      setState(() {
        isLoading = false;
      });

      if (customerProvider.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Customer Created", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        // Clear all fields
        _nameController.clear();
        _proprietorController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _statusController.clear();
        _opiningBanglaceController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(customerProvider.errorMessage)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill all required fields."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Create Customer",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildFieldLabel("Customer Name", textTheme, colorScheme),

              AddSalesFormfield(
                height: 40,
                label: "Enter Customer Name",
                controller: _nameController,
                //validator: _validateRequired,
              ),

              const SizedBox(
                height: 12,
              ),

              AddSalesFormfield(
                height: 40,
                label: "Enter Proprietor Name",
                controller: _proprietorController,
                //validator: _validateRequired,
              ),

              /// Price Level Selector
              PriceOptionSelectorCustomer(
                title: "Price Level",
                selectedPrice: _selectedPrice,
                onPriceChanged: (value) {
                  // setState(() {
                  //   _selectedPrice = value!;
                  // });
                  setState(() {
                    // Convert "Dealer Price" back to "dealer_price"
                    _selectedPrice =
                        value?.replaceAll(" ", "_").toLowerCase() ?? "";
                  });
                },
                isChecked: _isChecked,
                onCheckedChanged: (value) {
                  setState(() {
                    _isChecked = value;
                    if (!value)
                      _selectedPrice = ""; // Reset dropdown if unchecked
                  });
                },
              ),

              const SizedBox(
                height: 12,
              ),

              AddSalesFormfield(
                height: 40,
                label: "Enter Email",
                controller: _emailController,
                //validator: _validateEmail,
              ),

              const SizedBox(
                height: 12,
              ),

              AddSalesFormfield(
                height: 40,
                label: "Enter Phone",
                controller: _phoneController,
                //validator: _validatePhone,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(
                height: 12,
              ),

              AddSalesFormfield(
                height: 40,
                label: "Enter Address",
                controller: _addressController,
                //validator: _validateRequired,
              ),

              const SizedBox(
                height: 12,
              ),

              AddSalesFormfield(
                height: 40,
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
                  height: 40,
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
                  onPressed: _saveCustomer,

                  // () async {
                  //   if (_formKey.currentState!.validate()) {
                  //     setState(() {
                  //       // Show loading spinner if needed
                  //       isLoading = true;
                  //     });

                  //     // Call createCustomer and await the result
                  //     await customerProvider.createCustomer(
                  //       name: _nameController.text,
                  //       email: _emailController.text,
                  //       phone: _phoneController.text,
                  //       address: _addressController.text,
                  //       status: selectedStatus,
                  //       proprietorName: _proprietorController.text,
                  //       openingBalance: _opiningBanglaceController.text,
                  //       levelType: _isChecked ? _selectedPrice : "",
                  //       level: _isChecked ? "1" : "",
                  //     );

                  //     setState(() {
                  //       // Hide loading spinner after API call
                  //       isLoading = false;
                  //     });

                  //     if (customerProvider.errorMessage.isEmpty) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //           content: Text(
                  //             "Customer Created",
                  //             style: TextStyle(color: Colors.white),
                  //           ),
                  //           backgroundColor: Colors.green,
                  //         ),
                  //       );

                  //       // Clear the form fields
                  //       _nameController.clear();
                  //       _proprietorController.clear();
                  //       _emailController.clear();
                  //       _phoneController.clear();
                  //       _addressController.clear();
                  //       _statusController.clear();
                  //       _opiningBanglaceController.clear();

                  //       // Navigate to the HomeView page
                  //       Navigator.pushReplacement(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => HomeView()),
                  //       );
                  //     } else {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //             content: Text(customerProvider.errorMessage)),
                  //       );
                  //     }
                  //   }
                  // },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Save Customer",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
