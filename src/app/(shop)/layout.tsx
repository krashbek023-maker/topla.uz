'use client';

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { Home, Search, Grid3X3, ShoppingBag, User } from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
  { href: '/', icon: Home, label: 'Bosh sahifa' },
  { href: '/categories', icon: Grid3X3, label: 'Kategoriyalar' },
  { href: '/search', icon: Search, label: 'Qidirish' },
  { href: '/cart', icon: ShoppingBag, label: 'Savat' },
  { href: '/profile', icon: User, label: 'Profil' },
];

export default function ShopLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="min-h-screen gradient-bg pb-20">
      {/* Floating blobs background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="blob blob-1" />
        <div className="blob blob-2" />
        <div className="blob blob-3" />
      </div>

      {/* Main content */}
      <main className="relative z-10 max-w-lg mx-auto">
        {children}
      </main>

      {/* Bottom Navigation — glass effect */}
      <nav className="fixed bottom-0 left-0 right-0 z-50 bottom-nav-glass safe-area-bottom">
        <div className="max-w-lg mx-auto flex items-center justify-around h-16">
          {navItems.map((item) => {
            const isActive = item.href === '/'
              ? pathname === '/'
              : pathname.startsWith(item.href);
            const Icon = item.icon;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex flex-col items-center justify-center gap-0.5 w-16 h-full transition-all duration-300',
                  isActive
                    ? 'text-primary scale-110'
                    : 'text-muted-foreground hover:text-foreground'
                )}
              >
                <Icon className={cn('w-5 h-5', isActive && 'drop-shadow-md')} />
                <span className="text-[10px] font-medium">{item.label}</span>
                {isActive && (
                  <div className="absolute -top-0.5 w-8 h-1 rounded-full bg-primary" />
                )}
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
