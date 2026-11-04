/**
 * Shared primitive types used across every data model.
 *
 * All timestamps in the app are ISO 8601 strings. Two flavors are used
 * deliberately:
 *  - Moment stamps (createdAt, returnedAt, …): full UTC ISO strings.
 *  - Calendar stamps (borrow period start/end, dueAt): local-midnight ISO
 *    strings WITHOUT a "Z" suffix ("2026-09-06T00:00:00"), so that string
 *    comparison, inclusive-day math, and date inputs all stay consistent.
 */

/** A geographic coordinate. Mocked now; swap in real geolocation later. */
export interface LatLng {
  lat: number
  lng: number
}

/** ISO 8601 timestamp string (see file header for the two flavors). */
export type ISODateString = string
