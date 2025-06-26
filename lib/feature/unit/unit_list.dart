import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/unit/add_unit.dart';
import 'package:cbook_dt/feature/unit/model/unit_response_model.dart';
import 'package:cbook_dt/feature/unit/provider/unit_provider.dart';
import 'package:cbook_dt/feature/unit/update_unit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnitListView extends StatefulWidget {
  const UnitListView({super.key});

  @override
  UnitListViewState createState() => UnitListViewState();
}

class UnitListViewState extends State<UnitListView> {
  @override
  void initState() {
    super.initState();
    // Provider.of<UnitDTProvider>(context, listen: false).fetchUnits();

    // Defer fetchUnits until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UnitDTProvider>(context, listen: false).fetchUnits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        //centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Units List',
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const AddUnit()));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    'Add Units ',
                    style: TextStyle(color: Colors.yellow, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SizedBox(
          //     //height: 100,
          //     width: double.maxFinite,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(builder: (context) => const AddUnit()),
          //         );
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: AppColors.primaryColor,
          //         padding:
          //             const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //       ),
          //       child: const Text(
          //         "Add Unit",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Consumer<UnitDTProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.units.length,
                  itemBuilder: (context, index) {
                    final unit = provider.units[index];

                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 16),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            radius: 15,
                            child: Text(
                              "${index + 1}", // Display index
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                          title: Text(
                            unit.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            "Symbol: ${unit.symbol}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editUnit(unit);
                              } else if (value == 'delete') {
                                _deleteUnit(unit);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.blue),
                                  title: Text("Edit"),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text("Delete"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editUnit(UnitResponseModel unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUnitPage(unit: unit),
      ),
    );
  }

  void _deleteUnit(UnitResponseModel unit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
            "Are you sure you want to delete ${unit.name}?",
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // ❌ Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<UnitDTProvider>(context, listen: false)
                    .deleteUnit(unit.id, context);
                setState(() {}); // ✅ Ensure UI rebuilds after deletion
                Navigator.pop(context); // ✅ Close dialog
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
