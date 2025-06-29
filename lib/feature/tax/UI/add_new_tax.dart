import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/tax/UI/tax_list_view.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewTax extends StatefulWidget {
  const AddNewTax({super.key});

  @override
  State<AddNewTax> createState() => _AddNewTaxState();
}

class _AddNewTaxState extends State<AddNewTax> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _percentanceController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.clear();
    _percentanceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Add New Tax',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              ///name
              AddSalesFormfield(
                labelText: "Enter Tax Name",
                height: 40,
                label: "",
                controller: _nameController,
                //validator: _validateRequired,
              ),

              ///percentance
              AddSalesFormfield(
                labelText: "Enter Tax Percentance",
                height: 40,
                label: "",
                controller: _percentanceController,
                //validator: _validateRequired,
              ),

              ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? userId = prefs.getInt('user_id')?.toString();

                    if (userId == null) {
                      debugPrint("User ID is null");
                      return;
                    }

                    final name = _nameController.text.trim();
                    final percent = _percentanceController.text.trim();

                    if (name.isNotEmpty && percent.isNotEmpty) {
                      final taxProvider =
                          Provider.of<TaxProvider>(context, listen: false);

                      Provider.of<TaxProvider>(context, listen: false)
                          .createTax(
                        userId: int.parse(userId),
                        name: name,
                        percent: percent,
                        status: 1,
                      );
                      //Navigator.pop(context); // Optionally pop after saving

                      taxProvider.fetchTaxes();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Successfully, Tax saved")),
                      );

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TaxListView()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                    }
                  },
                  child: const Text(
                    "Save tax",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          ),
        ));
  }
}
