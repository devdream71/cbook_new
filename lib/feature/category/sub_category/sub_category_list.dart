import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/feature/category/model/category_list.dart';
import 'package:cbook_dt/feature/category/provider/category_provider.dart';
import 'package:cbook_dt/feature/category/sub_category/create_sub_category.dart';
import 'package:cbook_dt/feature/category/sub_category/edit_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemSubCategoryView extends StatefulWidget {
  @override
  _ItemSubCategoryViewState createState() => _ItemSubCategoryViewState();
}

class _ItemSubCategoryViewState extends State<ItemSubCategoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CategoryProvider>();
      await provider.fetchCategories();
      await provider.fetchSubCategories();
    });
  }

  void _confirmDelete(BuildContext context, int subcategoryId) async {
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
      await context.read<CategoryProvider>().deleteSubCategory(subcategoryId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category Delete successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String getCategoryName(BuildContext context, int categoryId) {
    final categories = context.read<CategoryProvider>().categories;
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => ItemCategoryModel(
        id: 0,
        userId: 0,
        name: "Unknown Category",
        status: 1,
        deletedAt: null,
        createdAt: '',
        updatedAt: '',
      ),
    );
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        //centerTitle: true,
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Item Subcategories",
          style: TextStyle(color: Colors.yellow, fontSize: 16),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateSubCategory()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
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
                  const Text(
                    'Add Sub Cat ',
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
            //             builder: (context) => const CreateSubCategory()),
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
            //       "Add Sub-Category",
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

                  if (provider.subcategories.isEmpty) {
                    return const Center(
                        child: Text(
                      "No subcategories found",
                      style: TextStyle(color: Colors.black),
                    ));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = provider.subcategories[index];
                      final categoryName =
                          getCategoryName(context, subcategory.itemCategoryId);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 15,
                            child: Text("${index + 1}"),
                          ),
                          contentPadding: const EdgeInsets.only(left: 16),
                          title: Text(
                            subcategory.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          //subtitle: Text("Category ID: ${subcategory.itemCategoryId}"),
                          subtitle: Text(
                            "Category: $categoryName",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87),
                          ),

                          trailing: PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            onSelected: (value) async {
                              if (value == 'Edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UpdateSubCategory(
                                        subcategoryId: subcategory.id),
                                  ),
                                );

                                debugPrint(
                                    "Edit Category ID: ${subcategory.id}");
                              } else if (value == 'delete') {
                                _confirmDelete(context, subcategory.id);
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
