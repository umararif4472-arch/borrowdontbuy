import { describe, expect, it } from 'vitest'
import type { Item } from '@/types'
import { countByCategory, filterItems } from './filters'

function makeItem(overrides: Partial<Item>): Item {
  return {
    id: 'i-test',
    ownerId: 'u-maya',
    title: 'Cordless Drill',
    description: 'A drill.',
    category: 'Tools',
    condition: 'Good',
    photos: [],
    location: { lat: 45.5, lng: -122.6 },
    availability: 'available',
    borrowTerms: {
      maxDurationDays: 7,
      depositAmount: null,
      dailyFee: null,
      pickupPreference: 'either',
      pickupInstructions: 'Porch pickup',
    },
    createdAt: '2026-01-01T00:00:00.000Z',
    ...overrides,
  }
}

const ORIGIN = { lat: 45.5, lng: -122.6 }

// ~1.1 km north and ~4.4 km south of ORIGIN
const nearItem = makeItem({ id: 'near', location: { lat: 45.51, lng: -122.6 } })
const farItem = makeItem({ id: 'far', location: { lat: 45.46, lng: -122.6 } })
const tent = makeItem({
  id: 'tent',
  title: '6-Person Tent',
  description: 'Camping tent.',
  category: 'Outdoor & Camping',
  location: { lat: 45.51, lng: -122.6 },
})
const borrowedDrill = makeItem({ id: 'borrowed', availability: 'borrowed' })

const items = [nearItem, farItem, tent, borrowedDrill]

const baseFilters = { query: '', categories: [], maxDistanceKm: null, availability: 'all' as const }

describe('filterItems', () => {
  it('returns everything with default filters', () => {
    expect(filterItems(items, baseFilters, ORIGIN)).toHaveLength(4)
  })

  it('filters by category', () => {
    const result = filterItems(items, { ...baseFilters, categories: ['Tools'] }, ORIGIN)
    expect(result.every((item) => item.category === 'Tools')).toBe(true)
    expect(result).toHaveLength(3)
  })

  it('supports multiple categories', () => {
    const result = filterItems(
      items,
      { ...baseFilters, categories: ['Tools', 'Outdoor & Camping'] },
      ORIGIN,
    )
    expect(result).toHaveLength(4)
  })

  it('filters by availability', () => {
    const result = filterItems(items, { ...baseFilters, availability: 'borrowed' }, ORIGIN)
    expect(result).toHaveLength(1)
    expect(result[0].id).toBe('borrowed')
  })

  it('filters by radius around the origin', () => {
    const result = filterItems(items, { ...baseFilters, maxDistanceKm: 2 }, ORIGIN)
    expect(result.some((item) => item.id === 'near')).toBe(true)
    expect(result.some((item) => item.id === 'far')).toBe(false)
  })

  it('ignores radius when origin is null (no location yet)', () => {
    const result = filterItems(items, { ...baseFilters, maxDistanceKm: 2 }, null)
    expect(result).toHaveLength(4)
  })

  it('matches query against title, description, and category', () => {
    expect(filterItems(items, { ...baseFilters, query: 'tent' }, ORIGIN)).toHaveLength(1)
    expect(filterItems(items, { ...baseFilters, query: 'DRILL' }, ORIGIN)).toHaveLength(3) // title match, case-insensitive
    expect(filterItems(items, { ...baseFilters, query: 'camping' }, ORIGIN)).toHaveLength(1) // category match
    expect(filterItems(items, { ...baseFilters, query: 'unicycle' }, ORIGIN)).toHaveLength(0)
  })
})

describe('countByCategory', () => {
  it('counts items per category', () => {
    const counts = countByCategory(items)
    const tools = counts.find((c) => c.category === 'Tools')
    const outdoor = counts.find((c) => c.category === 'Outdoor & Camping')
    expect(tools?.count).toBe(3)
    expect(outdoor?.count).toBe(1)
  })
})
