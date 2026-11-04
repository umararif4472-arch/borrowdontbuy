import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { AppProvider } from '@/context/AppContext'
import { ToastProvider } from '@/context/ToastContext'
import App from './App'
import './index.css'

// AppProvider (global state, hydration) + ToastProvider (ephemeral UI
// moments like tier-ups) wrap the router and the app shell.
createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ToastProvider>
      <AppProvider>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </AppProvider>
    </ToastProvider>
  </StrictMode>,
)
