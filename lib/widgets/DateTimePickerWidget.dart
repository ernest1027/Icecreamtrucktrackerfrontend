import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class DateTimePickerWidget extends StatelessWidget {
  DateTime date;
  Function setDate;

  String text;
  DateTimePickerWidget(this.date, this.setDate, this.text) {}

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        DatePicker.showDateTimePicker(context, onChanged: (date) {},
            onConfirm: (date) {
          setDate(date);
        }, currentTime: DateTime.now(), locale: LocaleType.en);
      },
      child: Text(
        '${text}: ${TimeOfDay.fromDateTime(date).format(context)}',
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
