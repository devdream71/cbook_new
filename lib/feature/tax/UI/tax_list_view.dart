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
       
      appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Tax List',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text('Delete tax "${tax.name}"?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                                ElevatedButton(
                                  child: const Text('Delete'),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    provider.deleteTax(tax.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
