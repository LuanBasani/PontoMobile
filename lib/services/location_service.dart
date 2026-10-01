import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../core/constants/app_config.dart';

abstract interface class LocationReader {
  Future<Position> getCurrentPosition();
  double distanceToWorkplace(Position position);
}

class LocationService implements LocationReader {
  LocationService({required this.config});

  final AppConfig config;

  @override
  Future<Position> getCurrentPosition() async {
    if (!config.workplaceConfigured) {
      throw const LocationServiceException(
        'O local de trabalho ainda não foi configurado.',
      );
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceException(
          'Ative a localização do dispositivo e tente novamente.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          'A permissão de localização foi negada.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationServiceException(
          'A localização está bloqueada. Habilite a permissão nas configurações do aplicativo.',
        );
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on LocationServiceException {
      rethrow;
    } on TimeoutException {
      throw const LocationServiceException(
        'A localização demorou para responder. Verifique o GPS e tente novamente.',
      );
    } on LocationServiceDisabledException {
      throw const LocationServiceException(
        'Ative a localização do dispositivo e tente novamente.',
      );
    } on Exception {
      throw const LocationServiceException(
        'Não foi possível obter sua localização. Verifique o GPS e as permissões.',
      );
    }
  }

  @override
  double distanceToWorkplace(Position position) {
    final latitude = config.workLatitude;
    final longitude = config.workLongitude;
    if (latitude == null || longitude == null) {
      throw const LocationServiceException(
        'O local de trabalho ainda não foi configurado.',
      );
    }
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
