import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerForm extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  DatePickerForm({required this.controller,this.hintText=''});
  @override
  _DatePickerFormState createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {
  // final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(hintText: widget.hintText,
        contentPadding: EdgeInsets.only(left: 15),
        // labelText: 'Select Date',
        enabledBorder: OutlineInputBorder(
          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 119, 119, 119), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 119, 119, 119), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        prefixIcon: Icon(Icons.calendar_month_sharp),
        // suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        String? selectedDate = await selectDate(context);
        if (selectedDate != null) {
          setState(() {
            widget.controller.text = selectedDate;
          });
        }
      },
    );
  }
}

Future<String?> selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    return DateFormat('dd/MM/yyyy').format(pickedDate);
  }
  return null;
}
