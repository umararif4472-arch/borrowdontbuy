import type { ISODateString, LatLng } from './common'

/**
 * Canonical category list. This is both a type (ItemCategory) and a runtime
 * constant so filters, forms, and validation all share one source of truth.
 */
export const ITEM_CATEGORIES = [
  'Tools',
  'Outdoor & Camping',
  'Party & Events',
  'Kitchen',
  'Electronics',
  'Sports',
  'Kids & Baby',
  'Other',
] as const

export type ItemCategory = (typeof ITEM_CATEGORIES)[number]

export type ItemAvailability = 'available' | 'borrowed' | 'unavailable'

export type PickupPreference = 'pickup' | 'drop-off' | 'either'

/** The rules the owner sets for each lend. */
export interface BorrowTerms {
  maxDurationDays: number
  /** Optional refundable deposit, in whole dollars. null = none. */
  depositAmount: number | null
  /** Optional daily fee, in whole dollars. null = free to borrow. */
  dailyFee: number | null
  pickupPreference: PickupPreference
  pickupInstructions: string
}

export interface Item {
  id: string
  ownerId: string
  title: string
  description: string
  category: ItemCategory
  /** Free-text condition notes ("Well loved but runs great"). */
  condition: string
  /** Photo URLs. May be empty — UI renders a friendly category tile instead. */
  photos: string[]
  location: LatLng
  availability: ItemAvailability
  borrowTerms: BorrowTerms
  createdAt: ISODateString
}

/**
 * Filter shape shared by the browse UI (client-side filtering through
 * useFilteredItems) and the item service (mock "server-side" filtering).
 */
export interface ItemFilters {
  query: string
  /** Empty array means "all categories". */
  categories: ItemCategory[]
  /** null means "any distance". */
  maxDistanceKm: number | null
  availability: ItemAvailability | 'all'
}
