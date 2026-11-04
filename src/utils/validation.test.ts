import { describe, expect, it } from 'vitest'
import { borrowDurationFromInputs, validateBorrowPeriod, validateNote } from './validation'

// Frozen "today": 2026-09-05.
const NOW = new Date('2026-09-05T10:00:00')

describe('validateBorrowPeriod', () => {
  it('accepts a valid future range within the duration limit', () => {
    const result = validateBorrowPeriod('2026-09-06', '2026-09-08', 7, NOW)
    expect(result.valid).toBe(true)
    expect(result.errors).toEqual({})
  })

  it('requires both dates', () => {
    const result = validateBorrowPeriod('', '2026-09-08', 7, NOW)
    expect(result.valid).toBe(false)
    expect(result.errors.start).toBe('Pick a start date.')
  })

  it('rejects start dates in the past', () => {
    const result = validateBorrowPeriod('2026-09-04', '2026-09-08', 7, NOW)
    expect(result.valid).toBe(false)
    expect(result.errors.start).toMatch(/past/)
  })

  it('allows borrowing starting today', () => {
    const result = validateBorrowPeriod('2026-09-05', '2026-09-06', 7, NOW)
    expect(result.valid).toBe(true)
  })

  it('rejects end dates on or before the start date', () => {
    const sameDay = validateBorrowPeriod('2026-09-06', '2026-09-06', 7, NOW)
    expect(sameDay.valid).toBe(false)
    expect(sameDay.errors.end).toMatch('after the start date')

    const reversed = validateBorrowPeriod('2026-09-08', '2026-09-06', 7, NOW)
    expect(reversed.valid).toBe(false)
    expect(reversed.errors.end).toMatch('after the start date')
  })

  it('flags ranges that exceed the item max duration (inclusive count)', () => {
    // Sep 6–12 inclusive = 7 days: OK for a 7-day limit.
    expect(validateBorrowPeriod('2026-09-06', '2026-09-12', 7, NOW).valid).toBe(true)
    // Sep 6–13 inclusive = 8 days: too long.
    const result = validateBorrowPeriod('2026-09-06', '2026-09-13', 7, NOW)
    expect(result.valid).toBe(false)
    expect(result.errors.duration).toMatch('8 days')
  })
})

describe('borrowDurationFromInputs', () => {
  it('counts borrow days inclusively', () => {
    expect(borrowDurationFromInputs('2026-09-06', '2026-09-08')).toBe(3)
    expect(borrowDurationFromInputs('2026-09-06', '2026-09-06')).toBe(1)
  })

  it('returns null for invalid or reversed ranges', () => {
    expect(borrowDurationFromInputs('nope', '2026-09-08')).toBeNull()
    expect(borrowDurationFromInputs('2026-09-08', '2026-09-06')).toBeNull()
  })
})

describe('validateNote', () => {
  it('allows empty and short notes', () => {
    expect(validateNote('')).toBeUndefined()
    expect(validateNote('Patio cleaning!')).toBeUndefined()
  })

  it('rejects notes over 500 characters', () => {
    expect(validateNote('x'.repeat(501))).toMatch(/500 characters/)
  })
})
