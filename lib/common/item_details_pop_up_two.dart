import 'package:flutter/material.dart';

class ItemDetailsPopUpTwo extends StatelessWidget {
  final String leftTest;
  final String rightText;
  final String last;
  final FontWeight? fontWeight;
  const ItemDetailsPopUpTwo(
      {super.key,
      required this.leftTest,
      required this.rightText,
      this.fontWeight,
      required this.last});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //color: Colors.blue,
              child: SizedBox(
                width: 85,
                child: Text(leftTest,
                    style: TextStyle(
                        fontWeight: fontWeight,
                        color: Colors.black,
                        fontSize: 12)),
              ),
            ),
            Container(
              //color: Colors.green,
              child: SizedBox(
                width: 70,
                child: Text(" $rightText",
                    style: TextStyle(
                        fontWeight: fontWeight,
                        color: Colors.black,
                        fontSize: 12)),
              ),
            ),
            Container(
              //color: Colors.red,
              child: SizedBox(
                width: 70,
                child: Text(" $last",
                    style: TextStyle(
                        fontWeight: fontWeight,
                        color: Colors.black,
                        fontSize: 12)),
              ),
            ),
            SizedBox(height: 3),
          ]),
    );
  }
}
