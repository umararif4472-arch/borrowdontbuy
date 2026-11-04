import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/Button'

/** 404 with a little personality. */
export function NotFoundPage() {
  return (
    <div className="flex flex-col items-center gap-4 py-20 text-center">
      <span aria-hidden className="text-6xl">
        🧭
      </span>
      <h1 className="font-display text-2xl font-extrabold text-bark">
        This page wandered off the block
      </h1>
      <p className="max-w-sm text-sm text-bark-light">
        We looked up and down the street — nothing here. Maybe the address got typo&apos;d, or the
        neighbor moved.
      </p>
      <Link to="/browse">
        <Button>Back to the neighborhood</Button>
      </Link>
    </div>
  )
}
