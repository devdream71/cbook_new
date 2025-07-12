import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/tax/UI/add_new_tax.dart';
import 'package:cbook_dt/feature/tax/model/tax_model.dart';
import 'package:cbook_dt/feature/tax/provider/tax_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaxListView extends StatelessWidget {
  const TaxListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taxProvider = Provider.of<TaxProvider>(context, listen: false);

    // Fetch tax data when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taxProvider.fetchTaxes();
    });

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'Tax List',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          // Always visible: Add icon
          IconButton(
            icon: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: Colors.green)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTax(), //AddSupplierCustomer
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaxProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.taxList.isEmpty) {
            return const Center(child: Text("No taxes found."));
          }

          return ListView.builder(
            itemCount: provider.taxList.length,
            itemBuilder: (context, index) {
              final TaxModel tax = provider.taxList[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),

                //margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    tax.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Percent: ${tax.percent}%",
                        style: const TextStyle(fontSize: 12),
                      ),
                      // Text(
                      //     "Status: ${tax.status == 1 ? 'Active' : 'Inactive'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
