import { useCallback, useEffect, useState } from 'react'
import { useApp } from '@/context/AppContext'
import { itemsApi, toErrorMessage } from '@/services'

/**
 * Item data access — stale-while-revalidate style:
 *  - First mount: fetch through the service (real async path) and sync the
 *    result into context, showing skeletons while loading.
 *  - Remounts: serve cached items from context instantly and refresh in the
 *    background. New listings created anywhere in the app appear because
 *    context stays synced.
 */
export function useItems() {
  const { state, dispatch } = useApp()
  const [fetching, setFetching] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [nonce, setNonce] = useState(0)

  useEffect(() => {
    let alive = true
    setFetching(true)
    setError(null)

    itemsApi
      .getItems()
      .then((items) => {
        if (!alive) return
        dispatch({ type: 'ITEMS_SET', items })
        setFetching(false)
      })
      .catch((err: unknown) => {
        if (!alive) return
        setError(toErrorMessage(err))
        setFetching(false)
      })

    return () => {
      alive = false
    }
  }, [dispatch, nonce])

  const reload = useCallback(() => setNonce((n) => n + 1), [])

  return {
    items: state.items,
    loading: fetching && state.items.length === 0,
    error,
    reload,
  }
}
