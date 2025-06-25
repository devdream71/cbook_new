import 'package:flutter/material.dart';

class DemoText extends StatelessWidget {
  const DemoText({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        title: const Text(
          'cBook',
          style: TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // ← makes back icon white
        ),
        automaticallyImplyLeading: true,
      ),
      body: const Text("cBook"),
    );
  }
}
