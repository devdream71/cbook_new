import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/common/price_option_selector_customer.dart';
import 'package:cbook_dt/feature/customer_create/model/customer_create.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CustomerUpdate extends StatefulWidget {
  final CustomerData customer;

  const CustomerUpdate({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  _CustomerUpdateState createState() => _CustomerUpdateState();
}

class _CustomerUpdateState extends State<CustomerUpdate> {
  late TextEditingController nameController;
  late TextEditingController proprietorController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController idController;

  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Debugging: Ensure supplier data is passed correctly
    debugPrint("Supplier Data:");
    debugPrint("ID: ${widget.customer.id}"); // Make sure the ID is correct here
    debugPrint("Name: ${widget.customer.name}");
    debugPrint("Proprietor Name: ${widget.customer.proprietorName}");
    debugPrint("Email: ${widget.customer.level}");
    debugPrint("Email: ${widget.customer.levelType}");
    debugPrint("Email: ${widget.customer.email}");
    debugPrint("Phone: ${widget.customer.phone}");
    debugPrint("Address: ${widget.customer.address}");
    debugPrint("Status: ${widget.customer.status}");

    // Initialize controllers with the passed supplier data
    nameController = TextEditingController(text: widget.customer.name);
    proprietorController =
        TextEditingController(text: widget.customer.proprietorName);
    emailController = TextEditingController(text: widget.customer.email);
    phoneController = TextEditingController(text: widget.customer.phone);
    addressController = TextEditingController(text: widget.customer.address);
    idController = TextEditingController(text: widget.customer.id.toString());

    // Check if customer has a level (fixing the error)
    if (widget.customer.level != null && widget.customer.level! > 0) {
      _selectedPrice =
          widget.customer.levelType ?? ""; // Assign existing levelType
      _isChecked = true; // Check the checkbox if level exists
    } else {
      _selectedPrice = ""; // Reset dropdown if no level
      _isChecked = false; // Uncheck checkbox
    }
  }

  String _selectedPrice = "";
  bool _isChecked = false;

  @override
  void dispose() {
    nameController.dispose();
    proprietorController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    idController.dispose();
    super.dispose();
  }

  String selectedStatus = "1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddSalesFormfield(
              label: "Customer Name",
              controller: nameController,
              //validator: _validateRequired,
            ),

            AddSalesFormfield(
              label: "Proprietor Name",
              controller: proprietorController,
              //validator: _validateRequired,
            ),

            // Conditionally render the PriceOptionSelectorCustomer widget
            PriceOptionSelectorCustomer(
              title: "Price Level",
              selectedPrice: _selectedPrice,
              onPriceChanged: (value) {
                setState(() {
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

            AddSalesFormfield(
              label: "Email",
              controller: emailController,
              //validator: _validateRequired,
            ),

            AddSalesFormfield(
              label: "Phone",
              controller: phoneController,
              keyboardType: TextInputType.number,
              //validator: _validateRequired,
            ),

            AddSalesFormfield(
              label: "Address",
              controller: addressController,
              //validator: _validateRequired,
            ),

            const SizedBox(height: 20),

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
                onPressed: () async {
                  final customerProvider =
                      Provider.of<CustomerProvider>(context, listen: false);

                  int customerId = widget.customer.id;
                  if (customerId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid Customer ID"),
                      ),
                    );
                    return;
                  }

                  String level =
                      _isChecked ? "1" : "0"; // If checked, level is "1"
                  String levelType = _isChecked
                      ? _selectedPrice
                      : ""; // Assign only if level is 1

                  await customerProvider.updateCustomer(
                    context: context,
                    id: customerId.toString(),
                    name: nameController.text,
                    proprietorName: proprietorController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    status: selectedStatus,
                    level: level,
                    levelType: levelType,
                  );

                  if (customerProvider.errorMessage.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "Customer updated successfully",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Error: ${customerProvider.errorMessage}")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Customer",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
