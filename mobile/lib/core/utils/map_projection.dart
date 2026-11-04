import 'dart:math' as math;

import '../../data/models/user.dart';

/// Pixel-space point produced by [MapProjection.project].
class ProjectedPoint {
  final double x;
  final double y;
  const ProjectedPoint(this.x, this.y);
}

class MapBounds {
  final double width;
  final double height;
  final double padding;
  const MapBounds({
    required this.width,
    required this.height,
    required this.padding,
  });
}

/// Pure lat/lng -> pixel projection, ported 1:1 from web
/// src/utils/mapProjection.ts. Equirectangular with a longitude squeeze
/// (cos(lat)) and a uniform scale, so pin spacing and the radius ring are
/// proportional to real haversine distances at neighborhood scale.
class MapProjection {
  final double _maxLat;
  final double _minLng;
  final double _lngScale;
  final double _scale;
  final double _offsetX;
  final double _offsetY;
  final MapBounds _bounds;

  /// Radius of the distance-filter ring in pixels (null = no filter).
  final double? radiusPx;

  const MapProjection._(
    this._maxLat,
    this._minLng,
    this._lngScale,
    this._scale,
    this._offsetX,
    this._offsetY,
    this._bounds,
    this.radiusPx,
  );

  ProjectedPoint project(LatLng point) => ProjectedPoint(
    _bounds.padding + _offsetX + (point.lng - _minLng) * _lngScale * _scale,
    _bounds.padding + _offsetY + (_maxLat - point.lat) * _scale,
  );

  LatLng unproject(ProjectedPoint px) => LatLng(
    _maxLat - (px.y - _bounds.padding - _offsetY) / _scale,
    _minLng + (px.x - _bounds.padding - _offsetX) / (_lngScale * _scale),
  );
}

MapProjection createProjection(
  List<LatLng> points,
  LatLng? center,
  MapBounds bounds,
  double? radiusKm,
) {
  final all = <LatLng>[...points, ?center];
  if (all.isEmpty) all.add(const LatLng(45.52, -122.65));

  var minLat = all.map((p) => p.lat).reduce(math.min);
  var maxLat = all.map((p) => p.lat).reduce(math.max);
  var minLng = all.map((p) => p.lng).reduce(math.min);
  var maxLng = all.map((p) => p.lng).reduce(math.max);

  const minSpan = 0.005;
  if (maxLat - minLat < minSpan) {
    final mid = (maxLat + minLat) / 2;
    minLat = mid - minSpan / 2;
    maxLat = mid + minSpan / 2;
  }
  if (maxLng - minLng < minSpan) {
    final mid = (maxLng + minLng) / 2;
    minLng = mid - minSpan / 2;
    maxLng = mid + minSpan / 2;
  }

  final innerWidth = math.max(1.0, bounds.width - bounds.padding * 2);
  final innerHeight = math.max(1.0, bounds.height - bounds.padding * 2);

  final latMid = (maxLat + minLat) / 2;
  final lngScale = math.cos(latMid * math.pi / 180);

  final spanX = math.max((maxLng - minLng) * lngScale, 1e-9);
  final spanY = math.max(maxLat - minLat, 1e-9);

  final scale = math.min(innerWidth / spanX, innerHeight / spanY);
  final offsetX = (innerWidth - spanX * scale) / 2;
  final offsetY = (innerHeight - spanY * scale) / 2;

  // Vertically, 1 degree latitude ~ 111.19 km, and 1 degree = scale px.
  final pxPerKm = scale / 111.19;
  final radiusPx = radiusKm != null
      ? (radiusKm * pxPerKm).roundToDouble()
      : null;

  return MapProjection._(
    maxLat,
    minLng,
    lngScale,
    scale,
    offsetX,
    offsetY,
    bounds,
    radiusPx,
  );
}
