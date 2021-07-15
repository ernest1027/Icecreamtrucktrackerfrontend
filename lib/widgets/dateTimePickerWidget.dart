import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class dateTimePickerWidget extends StatelessWidget {
  DateTime date;
  Function setDate;
  dateTimePickerWidget(this.date, this.setDate) {}

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        DatePicker.showTimePicker(context,
            showSecondsColumn: false, onChanged: (date) {}, onConfirm: (date) {
          setDate(date);
        }, currentTime: DateTime.now(), locale: LocaleType.en);
      },
      child: Text(
        'Selected time : ${date.hour}:${date.minute}',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
