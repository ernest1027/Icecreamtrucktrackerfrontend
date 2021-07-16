import 'package:flutter/material.dart';
import 'package:ice_cream_truck_app/classes/DatabaseApiProvider.dart';
import 'package:ice_cream_truck_app/screens/AddMarkerPage.dart';
import 'package:ice_cream_truck_app/widgets/ScheduleTile.dart';

class ListScheduledPage extends StatefulWidget {
  static const String id = 'listScheduledPage';

  const ListScheduledPage({Key? key}) : super(key: key);

  @override
  _ListScheduledPageState createState() => _ListScheduledPageState();
}

class _ListScheduledPageState extends State<ListScheduledPage> {
  var getAllScheduledLocations = DatabaseApiProvider.getAllScheduledLocations;
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String driverId = arguments['driverId'] == '' ? 1 : arguments['driverId'];
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Scheduled locations"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AddMarkerPage.id,
                  arguments: {'driverId': driverId},
                ).then((value) => refresh());
              },
            ),
          ],
        ),
        body: FutureBuilder<List>(
            future: getAllScheduledLocations(driverId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ScheduleTile(snapshot.data![index], refresh);
                    });
              }
              return CircularProgressIndicator();
            }));
  }

  void refresh() {
    setState(() {
      this.getAllScheduledLocations =
          DatabaseApiProvider.getAllScheduledLocations;
    });
  }
}
