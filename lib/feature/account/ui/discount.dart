import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Discount extends StatefulWidget {
  const Discount({super.key});

  @override
  State<Discount> createState() => _DiscountState();
}

class _DiscountState extends State<Discount> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    DateTime selectedStartDate = DateTime.now();
    // Default to current date
    DateTime selectedEndDate = DateTime.now();
    // Default to current date
    String? selectedDropdownValue;

    Future<void> _selectDate(BuildContext context, DateTime initialDate,
        Function(DateTime) onDateSelected) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        onDateSelected(picked);
      }
    }

    // List of forms with metadata

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: const Column(
            children: [
              Text(
                'Discount',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Discount",
              style: TextStyle(color: Colors.white),
            )
          ],
        ));
  }
}
