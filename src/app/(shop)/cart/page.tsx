'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { ArrowLeft, Minus, Plus, Trash2, ShoppingBag } from 'lucide-react';
import { formatPrice } from '@/lib/utils';
import { Button } from '@/components/ui/button';

interface CartItem {
  id: string;
  productId: string;
  name: string;
  image: string;
  price: number;
  qty: number;
  stock: number;
  shopName?: string;
}

function getCart(): CartItem[] {
  if (typeof window === 'undefined') return [];
  const saved = localStorage.getItem('topla_cart');
  return saved ? JSON.parse(saved) : [];
}

function saveCart(items: CartItem[]) {
  localStorage.setItem('topla_cart', JSON.stringify(items));
}

export default function CartPage() {
  const [items, setItems] = useState<CartItem[]>([]);

  useEffect(() => {
    setItems(getCart());
  }, []);

  const updateQty = (id: string, delta: number) => {
    const updated = items.map((item) => {
      if (item.id !== id) return item;
      const newQty = Math.max(1, Math.min(item.stock, item.qty + delta));
      return { ...item, qty: newQty };
    });
    setItems(updated);
    saveCart(updated);
  };

  const removeItem = (id: string) => {
    const updated = items.filter((item) => item.id !== id);
    setItems(updated);
    saveCart(updated);
  };

  const clearCart = () => {
    setItems([]);
    saveCart([]);
  };

  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const deliveryFee = subtotal > 100000 ? 0 : 15000;
  const total = subtotal + deliveryFee;

  return (
    <div className="pb-6">
      {/* Header */}
      <div className="sticky top-0 z-40 glass-nav px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link href="/">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <h1 className="font-bold text-lg">Savat</h1>
          {items.length > 0 && (
            <span className="text-xs text-muted-foreground">({items.length})</span>
          )}
        </div>
        {items.length > 0 && (
          <button onClick={clearCart} className="text-xs text-destructive">
            Tozalash
          </button>
        )}
      </div>

      {items.length === 0 ? (
        <div className="text-center py-20 px-4">
          <ShoppingBag className="w-16 h-16 mx-auto text-muted-foreground/30 mb-4" />
          <h2 className="font-semibold text-lg mb-2">Savat bo&apos;sh</h2>
          <p className="text-sm text-muted-foreground mb-6">
            Mahsulotlarni qidiring va savatga qo&apos;shing
          </p>
          <Link href="/">
            <Button className="liquid-btn rounded-full">Xarid qilish</Button>
          </Link>
        </div>
      ) : (
        <>
          {/* Cart items */}
          <div className="px-4 mt-4 space-y-3">
            {items.map((item) => (
              <div key={item.id} className="glass rounded-2xl p-3 flex gap-3">
                <div className="w-20 h-20 rounded-xl overflow-hidden shrink-0 relative">
                  {item.image ? (
                    <Image src={item.image} alt={item.name} fill className="object-cover" />
                  ) : (
                    <div className="w-full h-full bg-muted flex items-center justify-center">📦</div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium line-clamp-2 leading-snug">{item.name}</p>
                  {item.shopName && (
                    <p className="text-[10px] text-muted-foreground mt-0.5">{item.shopName}</p>
                  )}
                  <p className="font-bold text-sm mt-1">{formatPrice(item.price)}</p>
                  <div className="flex items-center justify-between mt-2">
                    <div className="qty-glass">
                      <button onClick={() => updateQty(item.id, -1)}>
                        <Minus className="w-3.5 h-3.5" />
                      </button>
                      <span className="w-7 text-center text-xs font-medium">{item.qty}</span>
                      <button onClick={() => updateQty(item.id, 1)}>
                        <Plus className="w-3.5 h-3.5" />
                      </button>
                    </div>
                    <button
                      onClick={() => removeItem(item.id)}
                      className="p-2 rounded-lg hover:bg-destructive/10 transition-colors"
                    >
                      <Trash2 className="w-4 h-4 text-destructive" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Order summary */}
          <div className="px-4 mt-6">
            <div className="glass rounded-2xl p-4 space-y-3">
              <h3 className="font-semibold">Buyurtma xulosasi</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Mahsulotlar ({items.length})</span>
                  <span>{formatPrice(subtotal)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Yetkazib berish</span>
                  <span className={deliveryFee === 0 ? 'text-green-600 font-medium' : ''}>
                    {deliveryFee === 0 ? 'Bepul' : formatPrice(deliveryFee)}
                  </span>
                </div>
                {deliveryFee > 0 && (
                  <p className="text-xs text-muted-foreground">
                    {formatPrice(100000 - subtotal)} qo&apos;shsangiz yetkazish bepul!
                  </p>
                )}
                <div className="border-t pt-2 flex justify-between font-bold text-base">
                  <span>Jami</span>
                  <span>{formatPrice(total)}</span>
                </div>
              </div>
            </div>

            <Link href="/checkout">
              <button className="w-full mt-4 liquid-btn flex items-center justify-center gap-2 !py-4 text-base">
                Buyurtma berish
              </button>
            </Link>
          </div>
        </>
      )}
    </div>
  );
}
