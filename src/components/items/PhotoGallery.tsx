import { useState } from 'react'
import { cn } from '@/utils/cn'
import { ItemPhoto } from './ItemPhoto'

export interface PhotoGalleryProps {
  photos: string[]
  alt: string
  category: string
}

/**
 * Photo gallery with real keyboard navigation (thumbnail buttons),
 * graceful with 0, 1, or N photos.
 */
export function PhotoGallery({ photos, alt, category }: PhotoGalleryProps) {
  const [selected, setSelected] = useState(0)
  const hasMultiple = photos.length > 1
  const activeIndex = Math.min(selected, Math.max(0, photos.length - 1))

  const main = photos.length > 0 ? photos[activeIndex] : undefined

  if (photos.length === 0) {
    return (
      <ItemPhoto
        src={undefined}
        alt={alt}
        category={category}
        className="aspect-[4/3] w-full rounded-3xl border border-bark/10"
        emojiClassName="text-6xl"
      />
    )
  }

  return (
    <figure className="flex flex-col gap-3">
      <ItemPhoto
        src={main}
        alt={`${alt} — photo ${activeIndex + 1} of ${photos.length}`}
        category={category}
        className="aspect-[4/3] w-full rounded-3xl border border-bark/10"
      />
      {hasMultiple && (
        <div
          role="group"
          aria-label="Photo thumbnails"
          className="flex gap-2 overflow-x-auto no-scrollbar"
        >
          {photos.map((photo, index) => (
            <button
              key={photo}
              type="button"
              onClick={() => setSelected(index)}
              aria-pressed={index === activeIndex}
              aria-label={`Show photo ${index + 1}`}
              className={cn(
                'shrink-0 overflow-hidden rounded-2xl border-2 transition-all focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-terracotta-600',
                index === activeIndex
                  ? 'border-terracotta-600 shadow-sm'
                  : 'border-transparent opacity-70 hover:opacity-100',
              )}
            >
              <ItemPhoto src={photo} alt="" category={category} className="h-16 w-20" />
            </button>
          ))}
        </div>
      )}
    </figure>
  )
}
