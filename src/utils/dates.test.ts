import { beforeAll, afterAll, describe, expect, it, vi } from 'vitest'
import {
  dateInputToIso,
  daysBetween,
  dueInDays,
  formatDueLabel,
  isoToInputValue,
  localDateFromToday,
  periodsOverlap,
  relativeTime,
  toLocalDateIso,
  todayInputValue,
} from './dates'

// Freeze "now" so date math is deterministic in tests.
const NOW = new Date('2026-09-05T10:00:00')
const NOW_ISO = '2026-09-05T10:00:00.000Z'

beforeAll(() => {
  vi.useFakeTimers()
  vi.setSystemTime(NOW)
})

afterAll(() => {
  vi.useRealTimers()
})

describe('toLocalDateIso / dateInputToIso / isoToInputValue', () => {
  it('formats a Date as a local-midnight stamp', () => {
    expect(toLocalDateIso(new Date(2026, 8, 6))).toBe('2026-09-06T00:00:00')
  })

  it('round-trips date input values', () => {
    const iso = dateInputToIso('2026-09-10')
    expect(iso).toBe('2026-09-10T00:00:00')
    expect(isoToInputValue(iso!)).toBe('2026-09-10')
  })

  it('returns null for malformed date input instead of throwing', () => {
    expect(dateInputToIso('next tuesday')).toBeNull()
    expect(dateInputToIso('2026-13-45')).toBeNull() // invalid calendar date
    expect(dateInputToIso('')).toBeNull()
  })

  it('todayInputValue reflects the (frozen) current day', () => {
    expect(todayInputValue()).toBe('2026-09-05')
  })

  it('localDateFromToday offsets by whole days', () => {
    expect(localDateFromToday(1)).toBe('2026-09-06T00:00:00')
    expect(localDateFromToday(-7)).toBe('2026-08-29T00:00:00')
  })
})

describe('daysBetween / relativeTime / due labels', () => {
  it('counts whole days between calendar stamps', () => {
    expect(daysBetween('2026-09-01T00:00:00', '2026-09-04T00:00:00')).toBe(3)
    expect(daysBetween('2026-09-04T00:00:00', '2026-09-01T00:00:00')).toBe(-3)
  })

  it('formats relative times against a fixed now', () => {
    expect(relativeTime('2026-09-05T09:59:30.000Z', NOW_ISO)).toBe('just now')
    expect(relativeTime('2026-09-05T09:30:00.000Z', NOW_ISO)).toBe('30m ago')
    expect(relativeTime('2026-09-05T05:00:00.000Z', NOW_ISO)).toBe('5h ago')
    expect(relativeTime('2026-09-03T10:00:00.000Z', NOW_ISO)).toBe('2d ago')
  })

  it('labels due dates including today and overdue', () => {
    expect(dueInDays('2026-09-05T00:00:00')).toBe(0)
    expect(formatDueLabel('2026-09-05T00:00:00')).toBe('Due today')
    expect(formatDueLabel('2026-09-06T00:00:00')).toBe('Due tomorrow')
    expect(formatDueLabel('2026-09-09T00:00:00')).toBe('Due in 4 days')
    expect(formatDueLabel('2026-09-03T00:00:00')).toBe('Overdue by 2 days')
  })
})

describe('periodsOverlap', () => {
  it('detects shared-day overlaps inclusively', () => {
    expect(
      periodsOverlap(
        { start: '2026-09-06T00:00:00', end: '2026-09-08T00:00:00' },
        { start: '2026-09-08T00:00:00', end: '2026-09-10T00:00:00' },
      ),
    ).toBe(true)
  })

  it('passes for fully disjoint periods', () => {
    expect(
      periodsOverlap(
        { start: '2026-09-06T00:00:00', end: '2026-09-07T00:00:00' },
        { start: '2026-09-09T00:00:00', end: '2026-09-10T00:00:00' },
      ),
    ).toBe(false)
  })

  it('detects containment', () => {
    expect(
      periodsOverlap(
        { start: '2026-09-01T00:00:00', end: '2026-09-30T00:00:00' },
        { start: '2026-09-10T00:00:00', end: '2026-09-12T00:00:00' },
      ),
    ).toBe(true)
  })
})
