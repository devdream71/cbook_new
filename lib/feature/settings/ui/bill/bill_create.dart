import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:flutter/material.dart';

class BillCreate extends StatelessWidget {
  const BillCreate({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.sfWhite,
        appBar: AppBar(
          
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            'Bill Create',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
        ),
        body: const Column(
          children: [],
        ));
  }
}
