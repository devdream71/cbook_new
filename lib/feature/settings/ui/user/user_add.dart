import 'dart:io';

import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:cbook_dt/feature/settings/provider/setting_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserAdd extends StatefulWidget {
  const UserAdd({
    Key? key,
  }) : super(key: key);

  @override
  State<UserAdd> createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  String selectedStatus = "1";

  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Provider.of<SettingUserProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Add User",
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: [
              ///name , nick name
              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Item Name",
                      controller: controller.nameCOntroller,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Nick Name",
                      controller: controller.nickController,
                    ),
                  ),
                ],
              ),

              ///mobile , email
              Row(
                children: [
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Mobile Number",
                      controller: controller.nickController,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Email",
                      controller: controller.nickController,
                    ),
                  ),
                ],
              ),

              ///addresss
              AddSalesFormfield(
                label: "Address",
                controller: controller.nickController,
              ),

              ////date

              ////status
              Row(
                children: [
                  ///title, designation
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Title/designation",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: const ["A", "B"], // Display labels
                            hint: '', // Select Status
                            width: double.infinity,
                            height: 30,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = (value == "Active")
                                    ? "1"
                                    : "0"; // ✅ Save 1 or 0
                              });
                              debugPrint(selectedStatus);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),

                  ///bill persion
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Bill Person",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: const ["A", "B"], // Display labels
                            hint: '', // Select Status
                            width: double.infinity,
                            height: 30,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = (value == "Active")
                                    ? "1"
                                    : "0"; // ✅ Save 1 or 0
                              });
                              debugPrint(selectedStatus);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              ////status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                            items: const [
                              "Active",
                              "Inactive"
                            ], // Display labels
                            hint: '', // Select Status
                            width: double.infinity,
                            height: 30,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = (value == "Active")
                                    ? "1"
                                    : "0"; // ✅ Save 1 or 0
                              });
                              debugPrint(selectedStatus);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Default Bill Person",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomDropdownTwo(
                            items: const ["A", "B"], // Display labels
                            hint: '', // Select Status
                            width: double.infinity,
                            height: 30,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = (value == "Active")
                                    ? "1"
                                    : "0"; // ✅ Save 1 or 0
                              });
                              debugPrint(selectedStatus);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Date",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Container(
                          height: 30,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Background color
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                            border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.5), // Border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.1), // Light shadow
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1), // Shadow position
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => controller.pickDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                hintText: "Bill Date",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 10,
                                ),
                                border: InputBorder
                                    .none, // Remove default underline
                              ),
                              child: Text(
                                controller.formattedDate.isNotEmpty
                                    ? controller.formattedDate
                                    : "No Date Provided",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: AddSalesFormfield(
                      label: "Password",
                      controller: controller.nickController,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: _imageFile != null
                              ? FileImage(File(_imageFile!.path))
                              : const AssetImage("assets/image/cbook_logo.png"),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          _showImageSourceActionSheet(context);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "***Nick Name must be 8 carecteres (AA or 123)",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text("Save User",
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              ///
            ],
          ),
        ));
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
