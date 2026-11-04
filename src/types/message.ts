import type { ISODateString } from './common'

/** A single chat message in the thread attached to a borrow request. */
export interface Message {
  id: string
  requestId: string
  senderId: string
  body: string
  createdAt: ISODateString
}
