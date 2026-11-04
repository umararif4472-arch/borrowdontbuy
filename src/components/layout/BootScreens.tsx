import { Button } from '@/components/ui/Button'
import { LoadingScreen } from '@/components/ui/Spinner'
import { LogoMark } from './Layout'

/** Splash while the app hydrates its data (real async delay from services). */
export function AppSplash() {
  return <LoadingScreen label="Meeting the neighbors…" />
}

/** Shown if hydration genuinely fails — with a real retry path. */
export function AppHydrationError({ message, onRetry }: { message: string; onRetry: () => void }) {
  return (
    <div className="flex min-h-dvh flex-col items-center justify-center gap-4 bg-cream px-6 text-center">
      <LogoMark />
      <div className="max-w-sm">
        <h1 className="font-display text-xl font-semibold text-bark">
          Hmm — we couldn&apos;t load the neighborhood.
        </h1>
        <p className="mt-2 text-sm text-bark-light">{message}</p>
      </div>
      <Button onClick={onRetry}>Try again</Button>
    </div>
  )
}
