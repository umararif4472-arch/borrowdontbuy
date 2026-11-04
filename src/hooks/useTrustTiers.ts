import { useMemo } from 'react'
import type { TrustTierName, User } from '@/types'
import { useApp } from '@/context/AppContext'
import { buildTrustHistory, calculateTrustScore, tierForScore } from '@/utils/trustScore'

/**
 * Compute trust tiers for MANY users in one memoized pass (grids: item
 * cards, profile lending lists). Same pure calculator as useTrustScore —
 * just batched so lists don't recompute per card per render.
 *
 * Returns a map of userId → tierName; missing users are simply absent
 * (cards render without a badge — never a crash).
 */
export function useTrustTiers(users: readonly User[]): Record<string, TrustTierName> {
  const { state } = useApp()

  return useMemo(() => {
    const tiers: Record<string, TrustTierName> = {}
    for (const user of users) {
      const reviews = state.reviews.filter((r) => r.revieweeId === user.id)
      const score = calculateTrustScore(buildTrustHistory(user, reviews))
      tiers[user.id] = tierForScore(score.total).name
    }
    return tiers
  }, [users, state.reviews])
}
