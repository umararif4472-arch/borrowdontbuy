import { describe, expect, it } from 'vitest'
import { createProjection } from './mapProjection'
import { haversineKm } from './distance'

const BOUNDS = { width: 800, height: 600, padding: 40 }

describe('createProjection', () => {
  it('places the center point inside the padded box', () => {
    const center = { lat: 45.5, lng: -122.65 }
    const points = [
      { lat: 45.52, lng: -122.62 },
      { lat: 45.47, lng: -122.68 },
    ]
    const projection = createProjection(points, center, BOUNDS, null)
    const { x, y } = projection.project(center)
    expect(x).toBeGreaterThanOrEqual(BOUNDS.padding)
    expect(x).toBeLessThanOrEqual(BOUNDS.width - BOUNDS.padding)
    expect(y).toBeGreaterThanOrEqual(BOUNDS.padding)
    expect(y).toBeLessThanOrEqual(BOUNDS.height - BOUNDS.padding)
  })

  it('puts north above south and west left of east', () => {
    const north = { lat: 45.52, lng: -122.65 }
    const south = { lat: 45.48, lng: -122.65 }
    const west = { lat: 45.5, lng: -122.69 }
    const east = { lat: 45.5, lng: -122.61 }
    const projection = createProjection([north, south, west, east], null, BOUNDS, null)
    expect(projection.project(north).y).toBeLessThan(projection.project(south).y)
    expect(projection.project(west).x).toBeLessThan(projection.project(east).x)
  })

  it('keeps pin spacing proportional to real-world distance (uniform scale)', () => {
    const a = { lat: 45.5, lng: -122.65 }
    const b = { ...a, lat: a.lat + 0.01 } // ~1.1 km north
    const c = { ...a, lat: a.lat + 0.02 } // ~2.2 km north
    const projection = createProjection([a, b, c], null, BOUNDS, null)
    const pa = projection.project(a)
    const pb = projection.project(b)
    const pc = projection.project(c)
    // Screen y grows downward, so northward moves subtract — compare as
    // positive "pixels toward north" values.
    const ab = pa.y - pb.y
    const bc = pb.y - pc.y
    expect(ab).toBeGreaterThan(0)
    // Equal real-world deltas → equal pixel deltas (±0.5px tolerance).
    expect(Math.abs(ab - bc)).toBeLessThan(0.5)
  })

  it('round-trips project → unproject back to the original coordinate', () => {
    const points = [
      { lat: 45.51, lng: -122.64 },
      { lat: 45.49, lng: -122.66 },
    ]
    const projection = createProjection(points, { lat: 45.5, lng: -122.65 }, BOUNDS, null)
    for (const point of points) {
      const px = projection.project(point)
      const back = projection.unproject(px)
      expect(back.lat).toBeCloseTo(point.lat, 8)
      expect(back.lng).toBeCloseTo(point.lng, 8)
    }
  })

  it('scales the radius ring with the map so it matches real km', () => {
    // Two points 0.02° lat apart (~2.22 km). With a 5 km radius filter, the
    // ring should equal 5 × the map's pixels-per-km.
    const a = { lat: 45.5, lng: -122.65 }
    const b = { ...a, lat: a.lat + 0.02 }
    const projection = createProjection([a, b], null, BOUNDS, 5)
    const pa = projection.project(a)
    const pb = projection.project(b)
    const pxPerKm = Math.abs(pb.y - pa.y) / haversineKm(a, b)
    expect(projection.radiusPx).not.toBeNull()
    expect(projection.radiusPx!).toBeCloseTo(5 * pxPerKm, 0)
  })

  it('handles an empty world gracefully (no throw, sane output)', () => {
    const projection = createProjection([], null, BOUNDS, null)
    const { x, y } = projection.project({ lat: 45.52, lng: -122.65 })
    expect(Number.isFinite(x)).toBe(true)
    expect(Number.isFinite(y)).toBe(true)
  })
})
