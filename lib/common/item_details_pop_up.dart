import 'package:flutter/material.dart';

class ItemDetailsPopUp extends StatelessWidget {
  final String leftTest;
  final String rightText;
  const ItemDetailsPopUp(
      {super.key, required this.leftTest, required this.rightText});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        SizedBox(
          width: 180,
          child: Text(leftTest,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12)),
        ),
        Text(": $rightText",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 12)),
        SizedBox(height: 3),
      ]),
    );
  }
}
 
