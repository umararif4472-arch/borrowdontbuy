import { useCallback, useMemo } from 'react'
import { useApp } from '@/context/AppContext'
import { notificationsApi } from '@/services'

/** The current user's notification inbox + unread badge count. */
export function useNotifications() {
  const { state, dispatch } = useApp()
  const currentUser = state.currentUser

  const notifications = useMemo(
    () =>
      state.notifications
        .filter((n) => n.userId === currentUser?.id)
        .sort((a, b) => Date.parse(b.createdAt) - Date.parse(a.createdAt)),
    [state.notifications, currentUser],
  )

  const unreadCount = useMemo(
    () => notifications.filter((n) => !n.read).length,
    [notifications],
  )

  const markAllRead = useCallback(async () => {
    if (!currentUser) return
    const updated = await notificationsApi.markAllNotificationsRead(currentUser.id)
    dispatch({ type: 'NOTIFICATIONS_SET', notifications: updated })
  }, [currentUser, dispatch])

  const markRead = useCallback(
    async (notificationId: string) => {
      if (!currentUser) return
      const updated = await notificationsApi.markNotificationRead(notificationId, currentUser.id)
      dispatch({ type: 'NOTIFICATIONS_SET', notifications: updated })
    },
    [currentUser, dispatch],
  )

  return { notifications, unreadCount, markAllRead, markRead }
}
