import 'package:cbook_dt/feature/category/category_update.dart';
import 'package:cbook_dt/feature/category/create_category.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemCategoryView extends StatefulWidget {
  @override
  _ItemCategoryViewState createState() => _ItemCategoryViewState();
}

class _ItemCategoryViewState extends State<ItemCategoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  void _confirmDelete(BuildContext context, int categoryId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this category?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await context.read<CategoryProvider>().deleteCategory(categoryId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category Delete successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
     
     

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
          "Item Categories",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateCategory()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: const Row(
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
                    'Add Categories',
                    style: TextStyle(color: Colors.yellow, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const CreateCategory()),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor,
            //       padding:
            //           const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     child: const Text(
            //       "Add Category",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.categories.isEmpty) {
                    return const Center(child: Text("No categories found"));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 16),
                          leading: CircleAvatar(
                            radius: 15,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(category.name,
                              style: const TextStyle(fontSize: 12)),
                          trailing: PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            onSelected: (value) async {
                              if (value == 'Edit') {
                                // Implement Edit Functionality
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateCategory(categoryId: category.id),
                                  ),
                                );
                                debugPrint("Edit Category ID: ${category.id}");
                              } else if (value == 'delete') {
                                _confirmDelete(context, category.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.blue),
                                  title: Text('Edit'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
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
      ),
    );
  }
}
