import 'package:flutter/material.dart';
import 'package:ice_cream_truck_app/screens/EditMarkerPage.dart';

class ScheduleTile extends StatelessWidget {
  Map data;
  Function refresh;
  ScheduleTile(this.data, this.refresh);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          textStyle: TextStyle(fontSize: 20, color: Color(0xFF000000)),
          primary: Color(0xFFD77FA1),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            EditMarkerPage.id,
            arguments: {'data': data},
          ).then((value) => refresh());
        },
        child: Column(
          children: [
            // Text(data["description"] == null
            //     ? "Unknown location name"
            //     : data["description"]),
            Text(
                "Start time: ${DateTime.parse(this.data["startTime"]).toLocal()} "),
            Text(
                "End time: ${DateTime.parse(this.data["endTime"]).toLocal()} "),
          ],
        ),
      ),
    );
  }
}
