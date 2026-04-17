// import 'package:dgis_map_kit/dgis_map_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:qaida/providers/place.provider.dart';

// class PlaceMap extends StatelessWidget {
//   const PlaceMap({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final place = context.watch<PlaceProvider>().place;
//     final location = place?['location_id'];
//     return SizedBox(
//       height: 500,
//       width: double.infinity,
//       child: DGisMap(
//         token: '1da1a3a7-a804-43d8-92d9-c4ad7ae50848',
//         initialCameraPosition: CameraPosition(
//           position: Position(
//             lat: location['lat'],
//             long: location['lon'],
//           ),
//           zoom: 15,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PlaceMap extends StatelessWidget {
  const PlaceMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Карта временно недоступна',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}