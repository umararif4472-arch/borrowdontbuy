import { useEffect, useState } from 'react'

/**
 * A ticking "now" so time-derived states (overdue, due-soon) flip live in
 * the UI without any user action. Re-renders at most once a minute — enough
 * precision for day-level due dates, cheap enough to leave mounted.
 */
export function useNow(intervalMs = 30_000): Date {
  const [now, setNow] = useState(() => new Date())

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), intervalMs)
    return () => clearInterval(timer)
  }, [intervalMs])

  return now
}
