import type { User } from '@/types'
import { ApiError } from './errors'
import { clone, findUser, simulateLatency, getStore } from './store'

/**
 * Mock auth. When a real backend arrives, swap these for session/JWT calls —
 * the component-facing surface stays identical.
 */

/** Who the prototype is "logged in" as. */
export const CURRENT_USER_ID = 'u-maya'

export async function getSessionUser(): Promise<User> {
  await simulateLatency(200, 400)
  const user = getStore().users.find((u) => u.id === CURRENT_USER_ID)
  if (!user) {
    throw new ApiError('unknown', 'No active session — could not load your profile.')
  }
  return clone(user)
}

// Re-exported for convenience so callers can do `authApi.CURRENT_USER_ID`.
export { findUser }
