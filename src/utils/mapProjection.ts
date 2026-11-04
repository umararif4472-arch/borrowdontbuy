import type { LatLng } from '@/types'

/**
 * Pure lat/lng → pixel projection for the custom SVG map on /browse.
 *
 * The map is "real" in geometry: distances between pins are proportional to
 * real haversine distances, so the radius-filter ring and pin spacing are
 * truthful, not decorative. An equirectangular projection with a longitude
 * squeeze (cos(lat)) is accurate enough at neighborhood scale.
 */
export interface MapBounds {
  width: number
  height: number
  /** Padding in the same pixel units as width/height. */
  padding: number
}

export interface ProjectedPoint {
  x: number
  y: number
}

export interface MapProjection {
  /** Project a coordinate into pixel space. */
  project: (point: LatLng) => ProjectedPoint
  /** Convert a pixel position back to a coordinate (for click-to-position). */
  unproject: (point: ProjectedPoint) => LatLng
  /** Radius of the distance-filter ring in pixels (null = no filter). */
  radiusPx: number | null
}

/**
 * Build a projection that maps `points` (plus an optional `center` that is
 * always included) into a width×height box, centered and with uniform scale.
 * Falls back to a default viewport when there is no data, so an empty map
 * still renders sensibly.
 */
export function createProjection(
  points: readonly LatLng[],
  center: LatLng | null,
  bounds: MapBounds,
  radiusKm: number | null,
): MapProjection {
  const all = center ? [...points, center] : [...points]
  if (all.length === 0) all.push({ lat: 45.52, lng: -122.65 })

  let minLat = Math.min(...all.map((p) => p.lat))
  let maxLat = Math.max(...all.map((p) => p.lat))
  let minLng = Math.min(...all.map((p) => p.lng))
  let maxLng = Math.max(...all.map((p) => p.lng))

  // Guarantee a minimum span so a single point doesn't blow up the scale.
  const MIN_SPAN = 0.005
  if (maxLat - minLat < MIN_SPAN) {
    const mid = (maxLat + minLat) / 2
    minLat = mid - MIN_SPAN / 2
    maxLat = mid + MIN_SPAN / 2
  }
  if (maxLng - minLng < MIN_SPAN) {
    const mid = (maxLng + minLng) / 2
    minLng = mid - MIN_SPAN / 2
    maxLng = mid + MIN_SPAN / 2
  }

  const innerWidth = Math.max(1, bounds.width - bounds.padding * 2)
  const innerHeight = Math.max(1, bounds.height - bounds.padding * 2)

  const latMid = (maxLat + minLat) / 2
  const lngScale = Math.cos((latMid * Math.PI) / 180) // squeeze longitude

  const spanX = Math.max((maxLng - minLng) * lngScale, 1e-9) // squeezed degrees
  const spanY = Math.max(maxLat - minLat, 1e-9)

  // Uniform scale (px per squeezed degree) so geography isn't stretched,
  // with content centered in the box.
  const scale = Math.min(innerWidth / spanX, innerHeight / spanY)
  const offsetX = (innerWidth - spanX * scale) / 2
  const offsetY = (innerHeight - spanY * scale) / 2

  const project = (point: LatLng): ProjectedPoint => ({
    x: bounds.padding + offsetX + (point.lng - minLng) * lngScale * scale,
    y: bounds.padding + offsetY + (maxLat - point.lat) * scale,
  })

  const unproject = (px: ProjectedPoint): LatLng => ({
    lng: minLng + (px.x - bounds.padding - offsetX) / (lngScale * scale),
    lat: maxLat - (px.y - bounds.padding - offsetY) / scale,
  })

  // Vertically, 1° latitude ≈ 111.19 km, and 1° = `scale` px.
  const pxPerKm = scale / 111.19
  const radiusPx = radiusKm != null ? Math.round(radiusKm * pxPerKm) : null

  return { project, unproject, radiusPx }
}
