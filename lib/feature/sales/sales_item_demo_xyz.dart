// import 'package:cbook_dt/common/custome_dropdown_two.dart';
// import 'package:flutter/material.dart';

// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Column(
//         children: [
//           CustomDropdownTwo(
//             hint: '',
//             width: 150,
//             height: 30,
          
//             items: itemProvider.items.map((item) = > item.name).toList(),
//             onChanged: (value){
              
//               controller.selectedItemName = selectedItemName;

//               itemProvider.items.forEach((e){
//                 if(selectedItemName == e.name){
//                   controller.selectedItemID = e.id.toString();
//                 }
//               })

//             },             
//           )
//         ],
//       ),
//     );
//   }
// }