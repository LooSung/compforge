import type { ReactNode } from 'react';
import { AppProviders } from './providers';
import './globals.css';

export const metadata = {
  title: 'Todos',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AppProviders>{children}</AppProviders>
      </body>
    </html>
  );
}
