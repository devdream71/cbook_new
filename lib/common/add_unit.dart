import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/custome_dropdown_two.dart';
import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
import 'package:cbook_dt/feature/sales/widget/add_sales_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class SelectUnitBottomSheet extends StatefulWidget {
  final String? selectedUnit;
  final String? selectedUnit2;
  final Function(String?) onUnit1Changed;
  final Function(String?) onUnit2Changed;
  final TextEditingController conversionRateController;

  const SelectUnitBottomSheet({
    super.key,
    required this.selectedUnit,
    required this.selectedUnit2,
    required this.onUnit1Changed,
    required this.onUnit2Changed,
    required this.conversionRateController,
  });

  @override
  _SelectUnitBottomSheetState createState() => _SelectUnitBottomSheetState();
}

class _SelectUnitBottomSheetState extends State<SelectUnitBottomSheet> {
  String? _selectedUnit1;
  String? _selectedUnit2;

  @override
  void initState() {
    super.initState();
    _selectedUnit1 = widget.selectedUnit;
    _selectedUnit2 = widget.selectedUnit2;

    Future.microtask(
        () => Provider.of<UnitProvider>(context, listen: false).fetchUnits());
  }

  @override
  Widget build(BuildContext context) {
    final unitProvider = Provider.of<UnitProvider>(context);
    final saleController = Provider.of<SalesController>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unit Adjustment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontSize: 12),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white60,
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (unitProvider.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!unitProvider.isLoading) ...[
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Base Unit',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: CustomDropdownTwo(
                          items: unitProvider.units
                              .map((unit) => unit.symbol)
                              .toList(),
                          hint: '',
                          width: double.infinity,
                          height: 40,
                          selectedItem: _selectedUnit1,
                          onChanged: (value) {
                            final selectedUnit = unitProvider.units.firstWhere(
                              (unit) => unit.symbol == value,
                              orElse: () => unitProvider.units.first,
                            );

                            setState(() {
                              _selectedUnit1 = value;
                              _selectedUnit2 = null;
                            });

                            saleController.selectedUnitID = selectedUnit.id;
                            widget.onUnit1Changed(value);
                            widget.onUnit2Changed(null);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secondary Unit',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: CustomDropdownTwo(
                          items: unitProvider.units
                              .map((unit) => unit.symbol)
                              .where((symbol) => symbol != _selectedUnit1)
                              .toList(),
                          hint: '',
                          width: double.infinity,
                          height: 40,
                          selectedItem: _selectedUnit2,
                          onChanged: (value) {
                            final selectedUnit = unitProvider.units.firstWhere(
                              (unit) => unit.symbol == value,
                              orElse: () => unitProvider.units.first,
                            );

                            setState(() {
                              _selectedUnit2 = value;
                            });

                            saleController.selectedUnit2ID = selectedUnit.id;
                            widget.onUnit2Changed(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                ],
              ),
              if (_selectedUnit2 != null &&
                  _selectedUnit2 != _selectedUnit1) ...[
                const Text(
                  "Conversion Qty",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("1 $_selectedUnit1 =",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 150,
                      child: AddSalesFormfield(
                        controller: widget.conversionRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          saleController.conversionRate = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_selectedUnit2 ?? "",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedUnit1 == _selectedUnit2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Base unit and secondary unit can't be the same",
                        ),
                      ),
                    );
                    return;
                  }

                  final controller =
                      Provider.of<SalesController>(context, listen: false);

                  final baseUnitID = controller.selectedUnitID;
                  final secondaryUnitID = controller.selectedUnit2ID;
                  final conversionRate = widget.conversionRateController.text;

                  debugPrint("Base Unit ID: $baseUnitID");
                  debugPrint("Secondary Unit ID: $secondaryUnitID");
                  debugPrint("Conversion Rate: $conversionRate");

                  debugPrint("Base Unit Symbol: $_selectedUnit1");
                  debugPrint("Secondary Unit Symbol: $_selectedUnit2");

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


//// unit and secondary unit working but same id not working
// class SelectUnitBottomSheet extends StatefulWidget {
//   final String? selectedUnit;
//   final String? selectedUnit2;
//   final Function(String?) onUnit1Changed;
//   final Function(String?) onUnit2Changed;
//   final TextEditingController conversionRateController;

//   const SelectUnitBottomSheet({
//     Key? key,
//     required this.selectedUnit,
//     required this.selectedUnit2,
//     required this.onUnit1Changed,
//     required this.onUnit2Changed,
//     required this.conversionRateController,
//   }) : super(key: key);

//   @override
//   _SelectUnitBottomSheetState createState() => _SelectUnitBottomSheetState();
// }

// class _SelectUnitBottomSheetState extends State<SelectUnitBottomSheet> {
//   String? _selectedUnit1;
//   String? _selectedUnit2;

//   @override
//   void initState() {
//     super.initState();
//     _selectedUnit1 = widget.selectedUnit;
//     _selectedUnit2 = widget.selectedUnit2;

//     Future.microtask(
//         () => Provider.of<UnitProvider>(context, listen: false).fetchUnits());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final unitProvider = Provider.of<UnitProvider>(context);
//     final saleController = Provider.of<SalesController>(context);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Unit Adjustment',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                       fontSize: 12),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const CircleAvatar(
//                     radius: 15,
//                     backgroundColor: Colors.white60,
//                     child: Icon(
//                       Icons.close,
//                       color: Colors.red,
//                       size: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             if (unitProvider.isLoading)
//               const Center(child: CircularProgressIndicator()),
//             if (!unitProvider.isLoading) ...[
//               Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Base Unit',
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                       const SizedBox(height: 8),
//                       SizedBox(
//                         width: 150,
//                         child: CustomDropdownTwo(
//                           items: unitProvider.units
//                               .map((unit) => "${unit.symbol}")
//                               .toList(),
//                           hint: '',
//                           width: double.infinity,

//                           height: 50,
//                           selectedItem: _selectedUnit1,
//                           onChanged: (value) {
//                             final selectedUnit = unitProvider.units.firstWhere(
//                               (unit) =>
//                                   "${unit.symbol}" == value,
//                               orElse: () => unitProvider.units.first,
//                             );

//                             setState(() {
//                               _selectedUnit1 = value;
//                               _selectedUnit2 = null;
//                             });

//                             saleController.selectedUnitID = selectedUnit.id;
//                             widget.onUnit1Changed(value);
//                             widget.onUnit2Changed(null);
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                   const SizedBox(width: 8),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Secondary Unit',
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                       const SizedBox(height: 8),
//                       SizedBox(
//                         width: 150,
//                         child: CustomDropdownTwo(
//                           items: unitProvider.units
//                               .map((unit) => "${unit.symbol}")
//                               .toList(),
//                           hint: '',
//                           width: double.infinity,
//                           height: 40,
//                           selectedItem: _selectedUnit2,
//                           onChanged: (value) {
//                             final selectedUnit = unitProvider.units.firstWhere(
//                               (unit) =>
//                                   "${unit.symbol}" == value,
//                               orElse: () => unitProvider.units.first,
//                             );

//                             setState(() {
//                               _selectedUnit2 = value;
//                             });

//                             saleController.selectedUnit2ID = selectedUnit.id;
//                             widget.onUnit2Changed(value);
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   )
//                 ],
//               ),
//               if (_selectedUnit2 != null &&
//                   _selectedUnit2 != _selectedUnit1) ...[
//                 const Text(
//                   "Conversion Qty",
//                   style: TextStyle(fontSize: 15, color: Colors.black),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Text("1 $_selectedUnit1 =",
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 14)),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 150,
//                       child: AddSalesFormfield(
//                         controller: widget.conversionRateController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (value) {
//                           saleController.conversionRate = value;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(_selectedUnit2 ?? "",
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 14)),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ],
//             SizedBox(
//               width: double.maxFinite,
//               child: ElevatedButton(
//                 onPressed: () {
//                   final controller =
//                       Provider.of<SalesController>(context, listen: false);

//                   final baseUnitID = controller.selectedUnitID;
//                   final secondaryUnitID = controller.selectedUnit2ID;
//                   final conversionRate = widget.conversionRateController.text;

//                   debugPrint("Base Unit ID: $baseUnitID");
//                   debugPrint("Secondary Unit ID: $secondaryUnitID");
//                   debugPrint("Conversion Rate: $conversionRate");

//                   debugPrint("Base Unit Symbol: $_selectedUnit1");
//                   debugPrint("Secondary Unit Symbol: $_selectedUnit2");

//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Save'),
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }




// class SelectUnitBottomSheet extends StatefulWidget {
//   final String? selectedUnit;
//   final String? selectedUnit2;
//   final Function(String?) onUnit1Changed;
//   final Function(String?) onUnit2Changed;
//   final TextEditingController conversionRateController;

//   const SelectUnitBottomSheet({
//     Key? key,
//     required this.selectedUnit,
//     required this.selectedUnit2,
//     required this.onUnit1Changed,
//     required this.onUnit2Changed,
//     required this.conversionRateController,
//   }) : super(key: key);

//   @override
//   _SelectUnitBottomSheetState createState() => _SelectUnitBottomSheetState();
// }

// class _SelectUnitBottomSheetState extends State<SelectUnitBottomSheet> {
//   String? _selectedUnit1;
//   String? _selectedUnit2;

//   @override
//   void initState() {
//     super.initState();
//     _selectedUnit1 = widget.selectedUnit;
//     _selectedUnit2 = widget.selectedUnit2;

//     // Fetch units when the widget is initialized
//     Future.microtask(
//         () => Provider.of<UnitProvider>(context, listen: false).fetchUnits());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final unitProvider = Provider.of<UnitProvider>(context);
//     final saleController = Provider.of<SalesController>(context);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Unit Adjustment',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                       fontSize: 12),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const CircleAvatar(
//                     radius: 15,
//                     backgroundColor: Colors.white60,
//                     child: Icon(
//                       Icons.close,
//                       color: Colors.red,
//                       size: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             if (unitProvider.isLoading)
//               const Center(child: CircularProgressIndicator()),
//             if (!unitProvider.isLoading) ...[
//               /// **Base Unit Dropdown**
//               ///
//               ///

//               Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Base Unit',
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                       const SizedBox(height: 8),
//                       SizedBox(
//                         width: 150,
//                         child: CustomDropdownTwo(
//                           items: unitProvider.units
//                               .map((unit) => "${unit.symbol}")
//                               .toList(),
//                           hint: '', //Select Base Unit
//                           width: double.infinity,
//                           height: 40,
//                           selectedItem: _selectedUnit1,

//                           onChanged: (value) {
//                             final selectedUnit = unitProvider.units.firstWhere(
//                               (unit) =>
//                                   "${unit.name}, (${unit.symbol})" == value,
//                               orElse: () => unitProvider.units.first,
//                             );

//                             // Reset secondary unit when a new base unit is selected
//                             setState(() {
//                               _selectedUnit1 = value;
//                               _selectedUnit2 =
//                                   null; // Clear secondary unit when base unit is selected
//                             });

//                             // Update controllers and pass changes to the parent
//                             saleController.selectedUnitID = selectedUnit.id;
//                             widget.onUnit1Changed(value);
//                             widget.onUnit2Changed(
//                                 null); // Set secondary unit to null
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                   const SizedBox(
//                     width: 8,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// **Secondary Unit Dropdown (Defaults to Base Unit)**
//                       Text(
//                         'Secondary Unit',
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                       const SizedBox(height: 8),

//                       SizedBox(
//                         width: 150,
//                         child: CustomDropdownTwo(
//                           items: unitProvider.units
//                               .map((unit) => "${unit.symbol}")
//                               .toList(),
//                           hint: '', //Select Secondary Unit
//                           width: double.infinity,
//                           height: 40,
//                           selectedItem: _selectedUnit2,
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedUnit2 = value;
//                             });

//                             final selectedUnit = unitProvider.units.firstWhere(
//                               (unit) =>
//                                   "${unit.name}, (${unit.symbol})" == value,
//                               orElse: () => unitProvider.units.first,
//                             );

//                             saleController.selectedUnit2ID = selectedUnit.id;
//                             widget.onUnit2Changed(value);
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   )
//                 ],
//               ),

//               /// **Conversion Rate Input (Only if Secondary Unit is Different and Selected)**
//               if (_selectedUnit2 != null &&
//                   _selectedUnit2 != _selectedUnit1) ...[
//                 const Text(
//                   "Conversion Qty",
//                   style: TextStyle(fontSize: 15, color: Colors.black),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Text("1 $_selectedUnit1 =",
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 14)),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 150,
//                       child: AddSalesFormfield(
//                         controller: widget.conversionRateController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           // hintText: "Enter conversion qty",
//                         ),
//                         onChanged: (value) {
//                           saleController.conversionRate = value;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(_selectedUnit2 ?? "",
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 14)),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ],
//             SizedBox(
//               width: double.maxFinite,
//               child: ElevatedButton(
//                 onPressed: () {

                  

//                    final controller = Provider.of<SalesController>(context, listen: false);

//   final baseUnitID = controller.selectedUnitID;
//   final secondaryUnitID = controller.selectedUnit2ID;
//   final conversionRate = widget.conversionRateController.text;

//   debugPrint("Base Unit ID: $baseUnitID");
//   debugPrint("Secondary Unit ID: $secondaryUnitID");
//   debugPrint("Conversion Rate: $conversionRate");

//   // Optional: You can also print the unit symbols
//   debugPrint("Base Unit Symbol: $_selectedUnit1");
//   debugPrint("Secondary Unit Symbol: $_selectedUnit2");



//                   //print();




//                   debugPrint(
//                       "Conversion Rate: ${widget.conversionRateController.text}");
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Save'),
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:cbook_dt/app_const/app_colors.dart';
// import 'package:cbook_dt/common/custome_dropdown_two.dart';
// import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
// import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SelectUnitBottomSheet extends StatefulWidget {
//   final String? selectedUnit;
//   final String? selectedUnit2;
//   final Function(String?) onUnit1Changed;
//   final Function(String?) onUnit2Changed;
//   final TextEditingController conversionRateController;

//   const SelectUnitBottomSheet({
//     Key? key,
//     required this.selectedUnit,
//     required this.selectedUnit2,
//     required this.onUnit1Changed,
//     required this.onUnit2Changed,
//     required this.conversionRateController,
//   }) : super(key: key);

//   @override
//   _SelectUnitBottomSheetState createState() => _SelectUnitBottomSheetState();
// }

// class _SelectUnitBottomSheetState extends State<SelectUnitBottomSheet> {

//   String? _selectedUnit1;
//   String? _selectedUnit2;

//   @override
//   void initState() {
//     super.initState();
//     _selectedUnit1 = widget.selectedUnit;
//     _selectedUnit2 = widget.selectedUnit2;

//     // Fetch units when the widget is initialized
//     Future.microtask(
//         () => Provider.of<UnitProvider>(context, listen: false).fetchUnits());
//   }

//   @override
//   Widget build(BuildContext context) {

//     final unitProvider = Provider.of<UnitProvider>(context);
//     final saleController = Provider.of<SalesController>(context);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Unit Adjustment',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                       fontSize: 12),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const CircleAvatar(
//                     radius: 15,
//                     backgroundColor: Colors.white60,
//                     child: Icon(
//                       Icons.close,
//                       color: Colors.red,
//                       size: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             if (unitProvider.isLoading)
//               const Center(child: CircularProgressIndicator()),

//             if (!unitProvider.isLoading) ...[
//               /// **Base Unit Dropdown**
//               Text(
//                 'Base Unit',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),

//               ///===>base unit ===>
//               CustomDropdownTwo(
//                 items: unitProvider.units
//                     .map((unit) =>
//                         "${unit.symbol}") //"${unit.name}, (${unit.symbol})")
//                     .toList(),
//                 hint: '', //Select Base Unit
//                 width: double.infinity,
//                 height: 40,
//                 selectedItem: _selectedUnit1,

//                 ///===>old working code.
//                 onChanged: (value) {
//                   final selectedUnit = unitProvider.units.firstWhere(
//                     (unit) => "${unit.name}, (${unit.symbol})" == value,
//                     orElse: () => unitProvider.units.first,
//                   );

//                   // print(selectedUnit.toString());
//                   print(
//                       "Selected Unit: ${selectedUnit.name}, Symbol: ${selectedUnit.symbol}");

//                   saleController.selectedUnitID = selectedUnit.id;

//                   setState(() {
//                     _selectedUnit1 = value;
//                     _selectedUnit2 = value; // Default secondary unit to base unit
//                   });

//                   widget.onUnit1Changed(value);
//                   widget.onUnit2Changed(value);
//                 },

//               ),

//               const SizedBox(height: 20),

//               /// **Secondary Unit Dropdown (Defaults to Base Unit)**
//               Text(
//                 'Secondary Unit',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),

//               ////===>Selected unit  ///old working code.
//               CustomDropdownTwo(
//                 items: unitProvider.units
//                     .map((unit) =>
//                         "${unit.symbol}") //${unit.name}, (${unit.symbol})
//                     .toList(),
//                 hint: '', //Select Secondary Unit
//                 width: double.infinity,
//                 height: 40,
//                 selectedItem: _selectedUnit2,
//                 // value: _selectedUnit2,
//                 //  selectedValue: _selectedUnit2,

//                 //selectedItem: _selectedUnit2,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedUnit2 = value;
//                   });

//                   final selectedUnit = unitProvider.units.firstWhere(
//                     (unit) => "${unit.name}, (${unit.symbol})" == value,
//                     orElse: () => unitProvider.units.first,
//                   );

//                   print(selectedUnit.toString());

//                   saleController.selectedUnit2ID = selectedUnit.id;
//                   widget.onUnit2Changed(value);
//                 },
//               ),

//               const SizedBox(height: 20),

//               /// **Conversion Rate Input (Only if Secondary Unit is Different)**
//               if (_selectedUnit2 != _selectedUnit1) ...[
//                 const Text(
//                   "Conversion Rate",
//                   style: TextStyle(fontSize: 15, color: Colors.black),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Text("1 $_selectedUnit1 =",
//                         style: const TextStyle(color: Colors.black, fontSize: 14),),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         style: const TextStyle(color: Colors.black, fontSize: 11),
//                         controller: widget.conversionRateController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintText: "Enter conversion rate",
//                         ),
//                         onChanged: (value) {
//                           saleController.conversionRate = value;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(_selectedUnit2 ?? "",
//                         style: const TextStyle(color: Colors.black, fontSize: 14),),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ],

//             //const  Spacer(),
//             /// **Save Button**
//             SizedBox(
//               width: double.maxFinite,
//               child: ElevatedButton(
//                 onPressed: () {
//                   debugPrint(
//                       "Conversion Rate: ${widget.conversionRateController.text}");
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Save'),
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }

///old working code.
///
// import 'package:cbook_dt/app_const/app_colors.dart';
// import 'package:cbook_dt/common/custome_dropdown_two.dart';
// import 'package:cbook_dt/feature/item/provider/unit_provider.dart';
// import 'package:cbook_dt/feature/sales/controller/sales_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SelectUnitBottomSheet extends StatefulWidget {
//   final String? selectedUnit;
//   final String? selectedUnit2;
//   final Function(String?) onUnit1Changed;
//   final Function(String?) onUnit2Changed;
//   final TextEditingController conversionRateController;

//   const SelectUnitBottomSheet({
//     Key? key,
//     required this.selectedUnit,
//     required this.selectedUnit2,
//     required this.onUnit1Changed,
//     required this.onUnit2Changed,
//     required this.conversionRateController,
//   }) : super(key: key);

//   @override
//   _SelectUnitBottomSheetState createState() => _SelectUnitBottomSheetState();
// }

// class _SelectUnitBottomSheetState extends State<SelectUnitBottomSheet> {

//   String? _selectedUnit1;
//   String? _selectedUnit2;

//   @override
//   void initState() {
//     super.initState();
//     _selectedUnit1 = widget.selectedUnit;
//     _selectedUnit2 = widget.selectedUnit2;

//     // Fetch units when the widget is initialized
//     Future.microtask(
//         () => Provider.of<UnitProvider>(context, listen: false).fetchUnits());
//   }

//   @override
//   Widget build(BuildContext context) {

//     final unitProvider = Provider.of<UnitProvider>(context);
//     final saleController = Provider.of<SalesController>(context);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Unit Adjustment',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                       fontSize: 12),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const CircleAvatar(
//                     radius: 15,
//                     backgroundColor: Colors.white60,
//                     child: Icon(
//                       Icons.close,
//                       color: Colors.red,
//                       size: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             if (unitProvider.isLoading)
//               const Center(child: CircularProgressIndicator()),

//             if (!unitProvider.isLoading) ...[
//               /// **Base Unit Dropdown**
//               Text(
//                 'Base Unit',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),

//               ///===>base unit ===>
//               CustomDropdownTwo(
//                 items: unitProvider.units
//                     .map((unit) =>
//                         "${unit.symbol}") //"${unit.name}, (${unit.symbol})")
//                     .toList(),
//                 hint: '', //Select Base Unit
//                 width: double.infinity,
//                 height: 40,
//                 selectedItem: _selectedUnit1,

//                 ///===>old working code.
//                 onChanged: (value) {
//                   final selectedUnit = unitProvider.units.firstWhere(
//                     (unit) => "${unit.name}, (${unit.symbol})" == value,
//                     orElse: () => unitProvider.units.first,
//                   );

//                   // print(selectedUnit.toString());
//                   print(
//                       "Selected Unit: ${selectedUnit.name}, Symbol: ${selectedUnit.symbol}");

//                   saleController.selectedUnitID = selectedUnit.id;

//                   setState(() {
//                     _selectedUnit1 = value;
//                     _selectedUnit2 = value; // Default secondary unit to base unit
//                   });

//                   widget.onUnit1Changed(value);
//                   widget.onUnit2Changed(value);
//                 },

//         //                onChanged: (value) {
//         //   final selectedUnit = unitProvider.units.firstWhere(
//         //     (unit) => unit.symbol == value,
//         //     orElse: () => unitProvider.units.first,
//         //   );

//         //   saleController.selectedUnitID = selectedUnit.id;

//         //   setState(() {
//         //     _selectedUnit1 = value;

//         //     // ✅ If the secondary unit is null or accidentally set to the same as base, reset it
//         //     if (_selectedUnit2 == null || _selectedUnit2 == value) {
//         //       final secondaryOptions = unitProvider.units
//         //           .where((unit) => unit.symbol != value)
//         //           .map((unit) => unit.symbol)
//         //           .toList();

//         //       // Auto-select the first available different secondary unit
//         //       _selectedUnit2 = secondaryOptions.isNotEmpty ? secondaryOptions.first : null;
//         //       widget.onUnit2Changed(_selectedUnit2);
//         //     }
//         //   });

//         //   widget.onUnit1Changed(value);
//         // }
//               ),

//               const SizedBox(height: 20),

//               /// **Secondary Unit Dropdown (Defaults to Base Unit)**
//               Text(
//                 'Secondary Unit',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 8),

//               ////===>Selected unit  ///old working code.
//               CustomDropdownTwo(
//                 items: unitProvider.units
//                     .map((unit) =>
//                         "${unit.symbol}") //${unit.name}, (${unit.symbol})
//                     .toList(),
//                 hint: '', //Select Secondary Unit
//                 width: double.infinity,
//                 height: 40,
//                 selectedItem: _selectedUnit2,
//                 // value: _selectedUnit2,
//                 //  selectedValue: _selectedUnit2,

//                 //selectedItem: _selectedUnit2,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedUnit2 = value;
//                   });

//                   final selectedUnit = unitProvider.units.firstWhere(
//                     (unit) => "${unit.name}, (${unit.symbol})" == value,
//                     orElse: () => unitProvider.units.first,
//                   );

//                   print(selectedUnit.toString());

//                   saleController.selectedUnit2ID = selectedUnit.id;
//                   widget.onUnit2Changed(value);
//                 },
//               ),

//         //              CustomDropdownTwo(
//         //   items: unitProvider.units
//         //       .where((unit) => unit.symbol != _selectedUnit1)
//         //       .map((unit) => unit.symbol)
//         //       .toList(),
//         //   hint: '',
//         //   width: double.infinity,
//         //   height: 40,
//         //   selectedItem: _selectedUnit2,
//         //   onChanged: (value) {
//         //     setState(() {
//         //       _selectedUnit2 = value;
//         //     });

//         //     final selectedUnit = unitProvider.units.firstWhere(
//         //       (unit) => unit.symbol == value,
//         //       orElse: () => unitProvider.units.first,
//         //     );

//         //     saleController.selectedUnit2ID = selectedUnit.id;
//         //     widget.onUnit2Changed(value);
//         //   },
//         // ),

//               const SizedBox(height: 20),

//               /// **Conversion Rate Input (Only if Secondary Unit is Different)**
//               if (_selectedUnit2 != _selectedUnit1) ...[
//                 const Text(
//                   "Conversion Rate",
//                   style: TextStyle(fontSize: 15, color: Colors.black),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Text("1 $_selectedUnit1 =",
//                         style: const TextStyle(color: Colors.black, fontSize: 14),),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         style: const TextStyle(color: Colors.black, fontSize: 11),
//                         controller: widget.conversionRateController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintText: "Enter conversion rate",
//                         ),
//                         onChanged: (value) {
//                           saleController.conversionRate = value;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(_selectedUnit2 ?? "",
//                         style: const TextStyle(color: Colors.black, fontSize: 14),),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ],

//             //const  Spacer(),
//             /// **Save Button**
//             SizedBox(
//               width: double.maxFinite,
//               child: ElevatedButton(
//                 onPressed: () {
//                   debugPrint(
//                       "Conversion Rate: ${widget.conversionRateController.text}");
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Save'),
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }
