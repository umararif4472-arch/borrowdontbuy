import { useState } from 'react'
import { cn } from '@/utils/cn'
import { categoryEmoji } from '@/utils/categoryMeta'

export interface ItemPhotoProps {
  src: string | undefined
  alt: string
  category: string
  className?: string
  /** Size class for the fallback emoji. */
  emojiClassName?: string
}

/**
 * Item photo with a warm category-emoji fallback tile when the photo is
 * missing or fails to load (zero-photo items are a real state — Leo's
 * camp stove ships with none).
 */
export function ItemPhoto({ src, alt, category, className, emojiClassName }: ItemPhotoProps) {
  const [failed, setFailed] = useState(false)

  if (!src || failed) {
    return (
      <div
        aria-label={`${alt} — no photo available`}
        role="img"
        className={cn(
          'flex items-center justify-center bg-gradient-to-br from-terracotta-50 to-moss-100',
          className,
        )}
      >
        <span aria-hidden className={cn('text-4xl', emojiClassName)}>
          {categoryEmoji(category)}
        </span>
      </div>
    )
  }

  return (
    <img
      src={src}
      alt={alt}
      loading="lazy"
      onError={() => setFailed(true)}
      className={cn('bg-terracotta-50 object-cover', className)}
    />
  )
}
