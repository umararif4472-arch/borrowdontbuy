import type { Message } from '@/types'
import { isoHoursAgo } from '@/utils/dates'

/** Two seeded chat threads tied to Maya's live requests. */
export function seedMessages(): Message[] {
  return [
    // Thread: Maya's pending kayak request (with Tom).
    {
      id: 'msg-1',
      requestId: 'req-out-kayak',
      senderId: 'u-tom',
      body: 'Hey Maya! Saw your kayak request — Saturday\u2019s forecast is 70° and glassy. Approving now, just bring the snacks you mentioned.',
      createdAt: isoHoursAgo(24),
    },
    {
      id: 'msg-2',
      requestId: 'req-out-kayak',
      senderId: 'u-maya',
      body: 'Deal! Do I need anything for the roof? I drive a sedan.',
      createdAt: isoHoursAgo(23),
    },
    {
      id: 'msg-3',
      requestId: 'req-out-kayak',
      senderId: 'u-tom',
      body: 'Sedan\u2019s fine — I\u2019ll pack the soft straps and show you the tie-down. I\u2019m home all Saturday morning.',
      createdAt: isoHoursAgo(22),
    },
    // Thread: the active karaoke borrow (with Joan).
    {
      id: 'msg-4',
      requestId: 'req-active-karaoke',
      senderId: 'u-joan',
      body: 'Approved! It\u2019s on the porch — songbook\u2019s in the side pocket. Mic 2 squeaks if you shake it; that\u2019s normal.',
      createdAt: isoHoursAgo(24 * 3),
    },
    {
      id: 'msg-5',
      requestId: 'req-active-karaoke',
      senderId: 'u-maya',
      body: 'Ha! Noted. The block party starts at 6 — you\u2019re officially invited.',
      createdAt: isoHoursAgo(24 * 3 - 1),
    },
    {
      id: 'msg-6',
      requestId: 'req-active-karaoke',
      senderId: 'u-joan',
      body: 'Wouldn\u2019t miss it. Have it back by Sunday evening and we stay friends.',
      createdAt: isoHoursAgo(24 * 2),
    },
  ]
}
