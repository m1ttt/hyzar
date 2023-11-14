import 'package:flutter/material.dart';

class PantallaUS extends StatelessWidget {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.amber[colorCodes[index]],
              child: ListTile(
                leading: Icon(Icons.album, size: 50),
                title: Text('Tarjeta ${entries[index]}'),
                subtitle: Text('Esta es la tarjeta número ${entries[index]}'),
              ),
            ),
          );
        });
  }
}
