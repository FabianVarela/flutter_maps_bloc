import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:rxdart/rxdart.dart';

class DragMapBloc with GoogleApiKey implements BaseBloc {
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  /// Subjects or StreamControllers
  final BehaviorSubject<bool> _isFirstTime = BehaviorSubject<bool>();

  final BehaviorSubject<Map<MarkerId, Marker>> _markerList =
  BehaviorSubject<Map<MarkerId, Marker>>();

  final BehaviorSubject<DragMapData> _dragMapData =
  BehaviorSubject<DragMapData>();

  /// Observables
  Stream<bool> get isFirstTime => _isFirstTime.stream;

  Stream<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Stream<DragMapData> get dragMapData => _dragMapData.stream;

  /// Functions
  void getInitialPosition(LatLng latLng, String idMarker) {
    _isFirstTime.sink.add(true);

    final MarkerId markerId = MarkerId(idMarker);
    final LatLng position = latLng;

    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      draggable: false,
    );

    _markers[markerId] = marker;
    _markerList.sink.add(_markers);

    Future<dynamic>.delayed(
      Duration(seconds: 3),
          () => _isFirstTime.sink.add(false),
    );
  }

  void dragMarker(LatLng latLng, String idMarker) {
    final MarkerId markerId = MarkerId(idMarker);
    final Marker marker = _markers[markerId];
    final Marker updatedMarker = marker.copyWith(positionParam: latLng);

    _markers[markerId] = updatedMarker;
    _markerList.sink.add(_markers);
  }

  void getAddress(double lat, double lng) async {
    final GoogleMapsGeocoding geoCoding =
    GoogleMapsGeocoding(apiKey: getApiKey());

    final GeocodingResponse response =
    await geoCoding.searchByLocation(Location(lat, lng));

    if (response.results.isNotEmpty) {
      final String formattedAddress = response.results[0].formattedAddress;
      _dragMapData.sink.add(DragMapData(lat, lng, formattedAddress));

      print(formattedAddress);
    }
  }

  /// Override functions
  @override
  void dispose() {
    _markerList.close();
    _isFirstTime.close();
    _dragMapData.close();
  }
}

class DragMapData {
  double latitude;
  double longitude;
  String formattedAddress;

  DragMapData(this.latitude, this.longitude, this.formattedAddress);
}
