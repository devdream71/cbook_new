import 'package:flutter/material.dart';

class IncomeReport extends StatelessWidget {
  const IncomeReport({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Income Report',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Column(
          children: [],
        ));
  }
}
