'use client';

import { useParams } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, Star, MapPin, Phone, ExternalLink, Heart } from 'lucide-react';
import { shopApi, type ProductItem } from '@/lib/api/shop';
import { formatPrice } from '@/lib/utils';

function ProductCard({ product }: { product: ProductItem }) {
  const hasDiscount = product.compareAtPrice && product.compareAtPrice > product.price;
  const discountPercent = hasDiscount
    ? Math.round(((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100)
    : 0;

  return (
    <Link href={`/products/${product.id}`} className="product-card block overflow-hidden">
      <div className="relative aspect-square img-zoom">
        {product.images?.[0] ? (
          <Image src={product.images[0]} alt={product.nameUz} fill className="object-cover" />
        ) : (
          <div className="w-full h-full bg-muted flex items-center justify-center text-3xl">📦</div>
        )}
        {discountPercent > 0 && <div className="discount-badge">-{discountPercent}%</div>}
        <button
          className="absolute top-3 right-3 w-8 h-8 rounded-full glass flex items-center justify-center"
          onClick={(e) => e.preventDefault()}
        >
          <Heart className="w-4 h-4 text-muted-foreground" />
        </button>
      </div>
      <div className="p-3">
        <p className="text-sm font-medium line-clamp-2 leading-snug mb-1">{product.nameUz}</p>
        <div className="flex items-end gap-2">
          <span className="font-bold">{formatPrice(product.price)}</span>
          {hasDiscount && (
            <span className="text-xs text-muted-foreground line-through">{formatPrice(product.compareAtPrice!)}</span>
          )}
        </div>
      </div>
    </Link>
  );
}

export default function ShopDetailPage() {
  const { id } = useParams<{ id: string }>();

  const { data: shop, isLoading } = useQuery({
    queryKey: ['shop', id],
    queryFn: () => shopApi.getShop(id),
    enabled: !!id,
  });

  const { data: productsData } = useQuery({
    queryKey: ['shop-products', id],
    queryFn: () => shopApi.getShopProducts(id, { limit: '40' }),
    enabled: !!id,
  });

  const products = productsData?.products ?? [];

  if (isLoading) {
    return (
      <div className="animate-pulse">
        <div className="h-40 skeleton" />
        <div className="px-4 -mt-10 space-y-3">
          <div className="w-20 h-20 skeleton rounded-full" />
          <div className="h-6 skeleton rounded w-1/2" />
          <div className="h-4 skeleton rounded w-3/4" />
        </div>
      </div>
    );
  }

  if (!shop) {
    return (
      <div className="text-center py-20">
        <p className="text-4xl mb-3">🏪</p>
        <p className="font-medium">Do&apos;kon topilmadi</p>
      </div>
    );
  }

  return (
    <div className="pb-6">
      {/* Banner */}
      <div className="relative h-40">
        {shop.bannerUrl ? (
          <Image src={shop.bannerUrl} alt="" fill className="object-cover" />
        ) : (
          <div className="w-full h-full bg-gradient-to-br from-primary/20 to-primary/5" />
        )}
        <Link href="/" className="absolute top-3 left-3 p-2 glass rounded-xl">
          <ArrowLeft className="w-5 h-5" />
        </Link>
      </div>

      {/* Shop info */}
      <div className="px-4 -mt-10 relative z-10">
        <div className="glass rounded-2xl p-4">
          <div className="flex items-start gap-4">
            <div className="w-16 h-16 rounded-full bg-white shadow-lg overflow-hidden shrink-0 -mt-8 border-4 border-white">
              {shop.logoUrl ? (
                <Image src={shop.logoUrl} alt="" width={64} height={64} className="object-cover" />
              ) : (
                <div className="w-full h-full bg-primary/10 flex items-center justify-center text-2xl">🏪</div>
              )}
            </div>
            <div className="flex-1 min-w-0 pt-2">
              <h1 className="font-bold text-lg">{shop.name}</h1>
              <div className="flex items-center gap-3 mt-1 text-sm text-muted-foreground">
                <span className="flex items-center gap-1">
                  <Star className="w-4 h-4 rating-star fill-current" />
                  {shop.rating?.toFixed(1) || '0.0'} ({shop.reviewCount})
                </span>
                <span className={shop.isOpen ? 'text-green-600' : 'text-red-500'}>
                  {shop.isOpen ? 'Ochiq' : "Yopiq"}
                </span>
              </div>
            </div>
          </div>

          {shop.description && (
            <p className="text-sm text-muted-foreground mt-3">{shop.description}</p>
          )}

          <div className="flex flex-wrap gap-2 mt-3">
            {shop.address && (
              <span className="flex items-center gap-1 text-xs text-muted-foreground">
                <MapPin className="w-3 h-3" /> {shop.address}
              </span>
            )}
            {shop.phone && (
              <a href={`tel:${shop.phone}`} className="flex items-center gap-1 text-xs text-primary">
                <Phone className="w-3 h-3" /> {shop.phone}
              </a>
            )}
            {shop.website && (
              <a href={shop.website} target="_blank" className="flex items-center gap-1 text-xs text-primary">
                <ExternalLink className="w-3 h-3" /> Sayt
              </a>
            )}
          </div>

          <div className="grid grid-cols-3 gap-2 mt-4 text-center text-xs">
            <div className="glass rounded-xl p-2">
              <p className="font-bold text-lg">{shop._count?.products || 0}</p>
              <p className="text-muted-foreground">Mahsulotlar</p>
            </div>
            <div className="glass rounded-xl p-2">
              <p className="font-bold text-lg">{shop.deliveryFee ? formatPrice(shop.deliveryFee) : 'Bepul'}</p>
              <p className="text-muted-foreground">Yetkazish</p>
            </div>
            <div className="glass rounded-xl p-2">
              <p className="font-bold text-lg">{shop.minOrderAmount ? formatPrice(shop.minOrderAmount) : '-'}</p>
              <p className="text-muted-foreground">Min. buyurtma</p>
            </div>
          </div>
        </div>
      </div>

      {/* Products */}
      <div className="px-4 mt-6">
        <h2 className="font-bold text-lg mb-3">Mahsulotlar</h2>
        {products.length === 0 ? (
          <p className="text-center text-muted-foreground py-10">Hozircha mahsulot yo&apos;q</p>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {products.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
