import { useEffect, useRef } from 'react'
import { useApp } from '@/context/AppContext'
import { useToast } from '@/context/ToastContext'
import { useTrustScore } from './useTrustScore'
import { TRUST_TIERS, tierByName, type TrustTier } from '@/utils/trustScore'

function tierRank(tier: TrustTier): number {
  return TRUST_TIERS.findIndex((t) => t.name === tier.name)
}

/**
 * Fires the VISIBLE tier-change moment: whenever the current user's tier
 * moves (either direction) as a consequence of returns/reviews flowing
 * through context, a toast celebrates (or commiserates). The tier itself
 * is never stored — this just watches the derived value change.
 */
export function useTierWatcher() {
  const { state } = useApp()
  const { push } = useToast()
  const { tier } = useTrustScore(state.currentUser?.id)

  const previous = useRef<TrustTier | null>(null)

  useEffect(() => {
    if (!tier) {
      // Signed out / hydrating — reset so the next sign-in doesn't toast.
      previous.current = null
      return
    }
    const prev = previous.current
    previous.current = tier

    if (!prev || prev.name === tier.name) return

    const wentUp = tierRank(tier) > tierRank(prev)
    if (wentUp) {
      push({
        tone: 'success',
        emoji: tier.emoji,
        title: `You leveled up: ${tier.name}!`,
        body: 'Your neighbors noticed. Keep the streak alive — every on-time return counts.',
        durationMs: 8000,
      })
    } else {
      push({
        tone: 'warning',
        emoji: '🍂',
        title: `Slipped to ${tier.name}`,
        body: 'Late returns chip away at the score. The next on-time return starts the climb back.',
        durationMs: 8000,
      })
    }
  }, [tier, push])

  // Expose for tests/preview components; the watcher itself renders nothing.
  return { tier: tier ? tierByName(tier.name) : null }
}
