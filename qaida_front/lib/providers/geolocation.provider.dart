import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GeolocationProvider extends ChangeNotifier {
  Socket? socket;

  Future<Map<String, double>?> getLocationSafe() async {
    try {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'lat': position.latitude,
        'lon': position.longitude,
      };
    } catch (e) {
      if (kDebugMode) print('getLocationSafe error: $e');
      return null;
    }
  }

  void connectIfNeeded() {
    if (socket != null && socket!.connected) return;

    socket?.dispose();
    socket = io(
      'http://192.168.8.6:8080/geolocation',
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();
  }

  void sendLocation(String userId, double lat, double lon) {
    if (socket == null || !(socket!.connected)) return;

    socket!.emit('send-location', {
      "location": {"lat": lat, "lon": lon},
      "user_id": userId,
    });
  }

  void disposeSocket() {
    socket?.dispose();
    socket = null;
  }
}