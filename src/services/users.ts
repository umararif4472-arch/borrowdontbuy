import type { User } from '@/types'
import { clone, simulateLatency, getStore } from './store'

/** User service. Mock now; each function maps 1:1 to a future HTTP route. */

export async function getUsers(): Promise<User[]> {
  await simulateLatency()
  return clone(getStore().users)
}

export async function getUserById(userId: string): Promise<User | null> {
  await simulateLatency()
  const user = getStore().users.find((u) => u.id === userId)
  return user ? clone(user) : null
}
