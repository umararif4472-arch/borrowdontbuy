import { describe, expect, it } from 'vitest'
import { formatDistance, haversineKm, isWithinRadius } from './distance'

describe('haversineKm', () => {
  it('returns 0 for identical points', () => {
    expect(haversineKm({ lat: 45.5, lng: -122.6 }, { lat: 45.5, lng: -122.6 })).toBe(0)
  })

  it('measures ~111 km per degree of latitude', () => {
    const km = haversineKm({ lat: 45, lng: -122 }, { lat: 46, lng: -122 })
    expect(km).toBeGreaterThan(110)
    expect(km).toBeLessThan(112)
  })

  it('squeezes longitude by cos(lat) — shorter than latitude degrees', () => {
    const latDegree = haversineKm({ lat: 45, lng: -122 }, { lat: 46, lng: -122 })
    const lngDegree = haversineKm({ lat: 45, lng: -122 }, { lat: 45, lng: -121 })
    expect(lngDegree).toBeLessThan(latDegree)
    expect(lngDegree).toBeGreaterThan(70) // cos(45°) ≈ 0.707 → ~78 km
  })
})

describe('formatDistance', () => {
  it('formats meters under 1 km', () => {
    expect(formatDistance(0.4)).toBe('400 m')
    expect(formatDistance(0.852)).toBe('852 m')
  })
  it('formats one decimal between 1 and 10 km', () => {
    expect(formatDistance(2.34)).toBe('2.3 km')
  })
  it('rounds above 10 km', () => {
    expect(formatDistance(12.6)).toBe('13 km')
  })
})

describe('isWithinRadius', () => {
  it('respects the boundary inclusively', () => {
    const origin = { lat: 45.5, lng: -122.6 }
    const oneDegLatAway = { lat: 46.5, lng: -122.6 } // ~111 km
    expect(isWithinRadius(origin, origin, 0)).toBe(true)
    expect(isWithinRadius(origin, oneDegLatAway, 112)).toBe(true)
    expect(isWithinRadius(origin, oneDegLatAway, 110)).toBe(false)
  })
})
