'use client';

import { useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { useQuery } from '@tanstack/react-query';
import {
  ArrowLeft, Share2, Heart, Star, ShoppingCart, Plus, Minus,
  Store, MessageCircle, ChevronRight, Truck, Shield, RotateCcw,
} from 'lucide-react';
import { shopApi } from '@/lib/api/shop';
import { formatPrice } from '@/lib/utils';
import { Button } from '@/components/ui/button';

export default function ProductDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [currentImage, setCurrentImage] = useState(0);
  const [qty, setQty] = useState(1);
  const [isFavorite, setIsFavorite] = useState(false);

  const { data: product, isLoading } = useQuery({
    queryKey: ['product', id],
    queryFn: () => shopApi.getProduct(id),
    enabled: !!id,
  });

  if (isLoading) {
    return (
      <div className="animate-pulse">
        <div className="aspect-square skeleton" />
        <div className="p-4 space-y-3">
          <div className="h-6 skeleton rounded w-3/4" />
          <div className="h-8 skeleton rounded w-1/2" />
          <div className="h-4 skeleton rounded w-full" />
          <div className="h-4 skeleton rounded w-2/3" />
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className="text-center py-20 px-4">
        <p className="text-4xl mb-3">😔</p>
        <p className="font-medium">Mahsulot topilmadi</p>
        <Button variant="outline" className="mt-4" onClick={() => router.back()}>Ortga qaytish</Button>
      </div>
    );
  }

  const images = product.images?.length ? product.images : [];
  const hasDiscount = product.compareAtPrice && product.compareAtPrice > product.price;
  const discountPercent = hasDiscount
    ? Math.round(((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100)
    : 0;

  return (
    <div className="pb-24">
      {/* Top bar */}
      <div className="sticky top-0 z-40 glass-nav px-4 py-3 flex items-center justify-between">
        <button onClick={() => router.back()} className="p-2 -ml-2 rounded-xl">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div className="flex items-center gap-2">
          <button className="p-2 rounded-xl glass">
            <Share2 className="w-5 h-5" />
          </button>
          <button
            className="p-2 rounded-xl glass"
            onClick={() => setIsFavorite(!isFavorite)}
          >
            <Heart className={`w-5 h-5 ${isFavorite ? 'fill-red-500 text-red-500' : ''}`} />
          </button>
        </div>
      </div>

      {/* Image gallery */}
      <div className="relative">
        <div className="aspect-square overflow-hidden">
          {images.length > 0 ? (
            <div
              className="flex transition-transform duration-300"
              style={{ transform: `translateX(-${currentImage * 100}%)` }}
            >
              {images.map((img, i) => (
                <div key={i} className="min-w-full aspect-square relative">
                  <Image src={img} alt={product.nameUz} fill className="object-cover" />
                </div>
              ))}
            </div>
          ) : (
            <div className="w-full h-full bg-muted flex items-center justify-center text-6xl">📦</div>
          )}
        </div>
        {images.length > 1 && (
          <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5">
            {images.map((_, i) => (
              <button
                key={i}
                onClick={() => setCurrentImage(i)}
                className={`w-2 h-2 rounded-full transition-all ${i === currentImage ? 'bg-primary w-5' : 'bg-white/70'}`}
              />
            ))}
          </div>
        )}
        {/* Thumbnail strip */}
        {images.length > 1 && (
          <div className="flex gap-2 px-4 mt-3 overflow-x-auto no-scrollbar">
            {images.map((img, i) => (
              <button
                key={i}
                onClick={() => setCurrentImage(i)}
                className={`w-14 h-14 rounded-lg overflow-hidden border-2 shrink-0 ${
                  i === currentImage ? 'border-primary' : 'border-transparent'
                }`}
              >
                <Image src={img} alt="" width={56} height={56} className="object-cover w-full h-full" />
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Product info */}
      <div className="px-4 mt-4 space-y-4">
        {/* Price */}
        <div>
          <div className="flex items-center gap-3">
            <span className="text-2xl font-bold">{formatPrice(product.price)}</span>
            {hasDiscount && (
              <>
                <span className="text-base text-muted-foreground line-through">
                  {formatPrice(product.compareAtPrice!)}
                </span>
                <span className="text-sm font-semibold text-red-500 bg-red-50 px-2 py-0.5 rounded-full">
                  -{discountPercent}%
                </span>
              </>
            )}
          </div>
        </div>

        {/* Title */}
        <h1 className="text-lg font-semibold leading-snug">{product.nameUz}</h1>

        {/* Rating */}
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1">
            {[1, 2, 3, 4, 5].map((s) => (
              <Star
                key={s}
                className={`w-4 h-4 ${
                  s <= Math.round(product.rating || 0)
                    ? 'rating-star fill-current'
                    : 'text-gray-300'
                }`}
              />
            ))}
          </div>
          <span className="text-sm text-muted-foreground">
            {product.rating?.toFixed(1) || '0.0'} • {product.salesCount || 0} sotildi • {product.viewCount || 0} ko&apos;rildi
          </span>
        </div>

        {/* Shop info */}
        {product.shop && (
          <Link
            href={`/shops/${product.shop.id}`}
            className="glass rounded-2xl p-3 flex items-center gap-3 hover-spring block"
          >
            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center overflow-hidden">
              {product.shop.logoUrl ? (
                <Image src={product.shop.logoUrl} alt="" width={40} height={40} className="object-cover" />
              ) : (
                <Store className="w-5 h-5 text-primary" />
              )}
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-medium text-sm">{product.shop.name}</p>
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Star className="w-3 h-3 rating-star fill-current" />
                {product.shop.rating?.toFixed(1) || '0.0'}
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground" />
          </Link>
        )}

        {/* Features */}
        <div className="grid grid-cols-3 gap-2">
          <div className="glass rounded-xl p-3 text-center">
            <Truck className="w-5 h-5 mx-auto text-primary mb-1" />
            <p className="text-[10px] text-muted-foreground">Yetkazib berish</p>
          </div>
          <div className="glass rounded-xl p-3 text-center">
            <Shield className="w-5 h-5 mx-auto text-green-500 mb-1" />
            <p className="text-[10px] text-muted-foreground">Kafolat</p>
          </div>
          <div className="glass rounded-xl p-3 text-center">
            <RotateCcw className="w-5 h-5 mx-auto text-orange-500 mb-1" />
            <p className="text-[10px] text-muted-foreground">Qaytarish</p>
          </div>
        </div>

        {/* Description */}
        {(product.descriptionUz || product.description) && (
          <div>
            <h3 className="font-semibold mb-2">Tavsif</h3>
            <div className="text-sm text-muted-foreground leading-relaxed whitespace-pre-line">
              {product.descriptionUz || product.description}
            </div>
          </div>
        )}

        {/* Specs */}
        <div className="glass rounded-2xl p-4 space-y-3">
          <h3 className="font-semibold text-sm">Xususiyatlar</h3>
          <div className="space-y-2 text-sm">
            {product.category && (
              <div className="flex justify-between">
                <span className="text-muted-foreground">Kategoriya</span>
                <span>{product.category.nameUz}</span>
              </div>
            )}
            {product.brand && (
              <div className="flex justify-between">
                <span className="text-muted-foreground">Brend</span>
                <span>{product.brand.name}</span>
              </div>
            )}
            {product.weight && (
              <div className="flex justify-between">
                <span className="text-muted-foreground">Og&apos;irlik</span>
                <span>{product.weight} g</span>
              </div>
            )}
            {product.sku && (
              <div className="flex justify-between">
                <span className="text-muted-foreground">SKU</span>
                <span>{product.sku}</span>
              </div>
            )}
            <div className="flex justify-between">
              <span className="text-muted-foreground">Mavjudlik</span>
              <span className={product.stock > 0 ? 'text-green-600' : 'text-red-500'}>
                {product.stock > 0 ? `${product.stock} dona` : 'Tugagan'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom bar — add to cart */}
      <div className="fixed bottom-16 left-0 right-0 z-40 glass-nav px-4 py-3">
        <div className="max-w-lg mx-auto flex items-center gap-3">
          {/* Qty selector */}
          <div className="qty-glass">
            <button onClick={() => setQty(Math.max(1, qty - 1))}>
              <Minus className="w-4 h-4" />
            </button>
            <span className="w-8 text-center text-sm font-medium">{qty}</span>
            <button onClick={() => setQty(qty + 1)}>
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {/* Chat seller */}
          <button className="p-3 rounded-xl glass">
            <MessageCircle className="w-5 h-5 text-primary" />
          </button>

          {/* Add to cart */}
          <button
            className="flex-1 liquid-btn flex items-center justify-center gap-2 !py-3"
            disabled={product.stock <= 0}
          >
            <ShoppingCart className="w-5 h-5" />
            <span>Savatga qo&apos;shish</span>
          </button>
        </div>
      </div>
    </div>
  );
}
