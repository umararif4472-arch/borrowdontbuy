import { useCallback, useEffect, useState } from 'react'
import { useApp } from '@/context/AppContext'
import { messagesApi, toErrorMessage } from '@/services'

/** Chat thread for one borrow request: loads via service, sends via service,
 *  and syncs context so the thread survives navigation. */
export function useMessages(requestId: string | undefined) {
  const { state, dispatch } = useApp()
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!requestId) return
    let alive = true
    setLoading(true)
    setError(null)

    messagesApi
      .getMessagesForRequest(requestId)
      .then((messages) => {
        if (!alive) return
        dispatch({ type: 'MESSAGES_LOADED', requestId, messages })
        setLoading(false)
      })
      .catch((err: unknown) => {
        if (!alive) return
        setError(toErrorMessage(err))
        setLoading(false)
      })

    return () => {
      alive = false
    }
  }, [requestId, dispatch])

  const send = useCallback(
    async (body: string) => {
      if (!requestId || !state.currentUser) return
      const result = await messagesApi.sendMessage(requestId, state.currentUser.id, body)
      dispatch({ type: 'MESSAGE_APPENDED', message: result.message })
      if (result.notifications.length > 0) {
        dispatch({ type: 'NOTIFICATIONS_APPENDED', notifications: result.notifications })
      }
    },
    [requestId, state.currentUser, dispatch],
  )

  return {
    messages: requestId ? (state.messagesByRequest[requestId] ?? []) : [],
    loading,
    error,
    send,
  }
}
