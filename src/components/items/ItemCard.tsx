import { Link } from 'react-router-dom'
import type { Item, TrustTierName, User } from '@/types'
import { cn } from '@/utils/cn'
import { formatDistance } from '@/utils/distance'
import { Avatar } from '@/components/ui/Avatar'
import { Badge, availabilityTone } from '@/components/ui/Badge'
import { TrustBadge } from '@/components/ui/Trust'
import { ItemPhoto } from './ItemPhoto'

export interface ItemCardProps {
  item: Item
  owner: User | undefined
  /** The owner's CURRENT trust tier, computed by the caller (useTrustScore). */
  ownerTier: TrustTierName | null
  /** Distance from the viewer (null when location is unknown). */
  distanceKm: number | null
  className?: string
}

const AVAILABILITY_LABEL: Record<Item['availability'], string> = {
  available: 'Available',
  borrowed: 'Borrowed',
  unavailable: 'Unavailable',
}

/** Grid card for browse + landing live feed + profiles. */
export function ItemCard({ item, owner, ownerTier, distanceKm, className }: ItemCardProps) {
  return (
    <article
      className={cn(
        'group flex flex-col overflow-hidden rounded-3xl border border-bark/10 bg-white shadow-sm transition-all',
        'hover:-translate-y-0.5 hover:shadow-md focus-within:-translate-y-0.5',
        className,
      )}
    >
      <Link
        to={`/item/${item.id}`}
        className="relative block focus-visible:outline-2 focus-visible:outline-offset-[-2px] focus-visible:outline-terracotta-600"
      >
        <ItemPhoto
          src={item.photos[0]}
          alt={item.title}
          category={item.category}
          className="aspect-[4/3] w-full"
        />
        <Badge
          tone={availabilityTone(item.availability)}
          dot
          className="absolute left-3 top-3 shadow-sm"
        >
          {AVAILABILITY_LABEL[item.availability]}
        </Badge>
        {distanceKm != null && (
          <span className="absolute bottom-3 right-3 rounded-full bg-bark/75 px-2 py-0.5 text-xs font-semibold text-cream backdrop-blur-sm">
            {formatDistance(distanceKm)}
          </span>
        )}
      </Link>

      <div className="flex flex-1 flex-col gap-2.5 p-4">
        <Link
          to={`/item/${item.id}`}
          className="font-display text-base font-semibold leading-snug text-bark transition-colors hover:text-terracotta-700 focus-visible:outline-2 focus-visible:outline-terracotta-600"
        >
          {item.title}
        </Link>
        <p className="text-xs font-medium text-bark-light">{item.category}</p>

        <div className="mt-auto flex items-center justify-between gap-2 pt-1">
          {owner ? (
            <Link
              to={`/profile/${owner.id}`}
              className="flex min-w-0 items-center gap-2 rounded-full focus-visible:outline-2 focus-visible:outline-terracotta-600"
              aria-label={`View ${owner.name}'s profile`}
            >
              <Avatar name={owner.name} src={owner.avatarUrl} size="xs" />
              <span className="max-w-24 truncate text-xs font-medium text-bark-light hover:text-terracotta-700">
                {owner.name}
              </span>
            </Link>
          ) : (
            <span className="text-xs text-bark-light">Neighbor</span>
          )}
          {owner && ownerTier && <TrustBadge tierName={ownerTier} />}
        </div>

        <p className="text-xs font-semibold text-moss-700">
          {item.borrowTerms.dailyFee != null
            ? `$${item.borrowTerms.dailyFee}/day`
            : 'Free to borrow'}
          {item.borrowTerms.depositAmount != null && item.borrowTerms.dailyFee == null
            ? ` · $${item.borrowTerms.depositAmount} deposit`
            : ''}
        </p>
      </div>
    </article>
  )
}
