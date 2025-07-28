import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final VoidCallback onTap;
  final String? Function(DateTime?)? validator;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.label,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final error = validator?.call(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            selectedDate == null
                ? label
                :DateFormat('yyyy-MM-dd').format(selectedDate!),
          ),
          trailing: Icon(Icons.calendar_today),
          onTap: onTap,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
