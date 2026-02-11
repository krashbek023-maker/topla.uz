'use client';

import Link from 'next/link';
import {
  User, ShoppingBag, Heart, MapPin, CreditCard, Settings,
  HelpCircle, LogOut, ChevronRight, Store,
} from 'lucide-react';

const menuItems = [
  { href: '/orders', icon: ShoppingBag, label: 'Buyurtmalarim', color: 'text-blue-500' },
  { href: '/favorites', icon: Heart, label: 'Sevimlilar', color: 'text-red-500' },
  { href: '/addresses', icon: MapPin, label: 'Manzillarim', color: 'text-green-500' },
  { href: '/payments', icon: CreditCard, label: "To'lov usullari", color: 'text-purple-500' },
];

const bottomItems = [
  { href: '/settings', icon: Settings, label: 'Sozlamalar' },
  { href: '/help', icon: HelpCircle, label: 'Yordam' },
  { href: '/vendor/login', icon: Store, label: 'Sotuvchi sifatida kirish' },
];

export default function ProfilePage() {
  return (
    <div className="pb-6">
      {/* Header */}
      <div className="px-4 pt-6 pb-4">
        <h1 className="font-bold text-2xl mb-1">Profil</h1>
        <p className="text-sm text-muted-foreground">Hisobingizni boshqaring</p>
      </div>

      {/* Auth card — not logged in */}
      <div className="px-4 mb-6">
        <div className="glass rounded-2xl p-5 text-center">
          <div className="w-16 h-16 rounded-full bg-primary/10 mx-auto flex items-center justify-center mb-3">
            <User className="w-8 h-8 text-primary" />
          </div>
          <h2 className="font-semibold mb-1">Hisobingizga kiring</h2>
          <p className="text-sm text-muted-foreground mb-4">
            Buyurtmalarni kuzatish va sevimlilarni saqlash uchun
          </p>
          <p className="text-xs text-muted-foreground">
            Kirish TOPLA mobil ilovasi orqali amalga oshiriladi
          </p>
        </div>
      </div>

      {/* Menu items */}
      <div className="px-4 space-y-2">
        {menuItems.map((item) => {
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className="glass rounded-2xl p-4 flex items-center gap-4 hover-spring block"
            >
              <div className={`w-10 h-10 rounded-xl bg-muted flex items-center justify-center ${item.color}`}>
                <Icon className="w-5 h-5" />
              </div>
              <span className="flex-1 font-medium text-sm">{item.label}</span>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </Link>
          );
        })}
      </div>

      {/* Bottom items */}
      <div className="px-4 mt-6 space-y-2">
        <div className="h-px bg-border mx-4" />
        {bottomItems.map((item) => {
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className="flex items-center gap-4 px-4 py-3 rounded-xl hover:bg-muted/50 transition-colors"
            >
              <Icon className="w-5 h-5 text-muted-foreground" />
              <span className="text-sm">{item.label}</span>
            </Link>
          );
        })}
        <button className="flex items-center gap-4 px-4 py-3 rounded-xl hover:bg-destructive/10 transition-colors w-full">
          <LogOut className="w-5 h-5 text-destructive" />
          <span className="text-sm text-destructive">Chiqish</span>
        </button>
      </div>
    </div>
  );
}
