'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { Search, MapPin, ChevronRight, Star, Heart, Zap, TrendingUp } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { shopApi, type Banner, type Category, type ProductItem } from '@/lib/api/shop';
import { formatPrice } from '@/lib/utils';

// ============ BANNER CAROUSEL ============
function BannerCarousel({ banners }: { banners: Banner[] }) {
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    if (banners.length <= 1) return;
    const timer = setInterval(() => setCurrent((p) => (p + 1) % banners.length), 4000);
    return () => clearInterval(timer);
  }, [banners.length]);

  if (!banners.length) return null;

  return (
    <div className="relative overflow-hidden rounded-2xl mx-4">
      <div
        className="flex transition-transform duration-500 ease-out"
        style={{ transform: `translateX(-${current * 100}%)` }}
      >
        {banners.map((b) => (
          <div key={b.id} className="min-w-full aspect-[2/1] relative banner-glass">
            {b.imageUrl && (
              <Image src={b.imageUrl} alt={b.titleUz || ''} fill className="object-cover rounded-2xl" />
            )}
            {b.titleUz && (
              <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/60 to-transparent rounded-b-2xl">
                <p className="text-white font-bold text-lg">{b.titleUz}</p>
                {b.subtitleUz && <p className="text-white/80 text-sm">{b.subtitleUz}</p>}
              </div>
            )}
          </div>
        ))}
      </div>
      {banners.length > 1 && (
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-1.5">
          {banners.map((_, i) => (
            <button
              key={i}
              onClick={() => setCurrent(i)}
              className={`w-2 h-2 rounded-full transition-all ${i === current ? 'bg-white w-5' : 'bg-white/50'}`}
            />
          ))}
        </div>
      )}
    </div>
  );
}

// ============ CATEGORY ROW ============
function CategoryRow({ categories }: { categories: Category[] }) {
  if (!categories.length) return null;

  return (
    <div className="px-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="font-bold text-lg">Kategoriyalar</h2>
        <Link href="/categories" className="text-primary text-sm font-medium flex items-center gap-1">
          Barchasi <ChevronRight className="w-4 h-4" />
        </Link>
      </div>
      <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2">
        {categories.slice(0, 8).map((cat) => (
          <Link
            key={cat.id}
            href={`/categories/${cat.id}`}
            className="flex flex-col items-center gap-2 min-w-[72px]"
          >
            <div className="w-16 h-16 rounded-2xl glass flex items-center justify-center text-2xl hover-spring">
              {cat.icon || '📦'}
            </div>
            <span className="text-xs text-center font-medium leading-tight line-clamp-2 w-16">
              {cat.nameUz}
            </span>
          </Link>
        ))}
      </div>
    </div>
  );
}

// ============ PRODUCT CARD ============
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
          onClick={(e) => { e.preventDefault(); }}
        >
          <Heart className="w-4 h-4 text-muted-foreground" />
        </button>
        {product.flashSalePrice && (
          <div className="absolute bottom-2 left-2 bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full flex items-center gap-1">
            <Zap className="w-3 h-3" /> Flash Sale
          </div>
        )}
      </div>
      <div className="p-3">
        <p className="text-sm font-medium line-clamp-2 leading-snug mb-1.5">{product.nameUz}</p>
        <div className="flex items-center gap-1 mb-1.5">
          <Star className="w-3.5 h-3.5 rating-star fill-current" />
          <span className="text-xs text-muted-foreground">
            {product.rating?.toFixed(1) || '0.0'}
          </span>
          {product.salesCount > 0 && (
            <span className="text-xs text-muted-foreground">• {product.salesCount} sotildi</span>
          )}
        </div>
        <div className="flex items-end gap-2">
          <span className="font-bold text-base">{formatPrice(product.price)}</span>
          {hasDiscount && (
            <span className="text-xs text-muted-foreground line-through">
              {formatPrice(product.compareAtPrice!)}
            </span>
          )}
        </div>
        {product.shop && (
          <p className="text-[10px] text-muted-foreground mt-1 truncate">
            {product.shop.name}
          </p>
        )}
      </div>
    </Link>
  );
}

// ============ SECTION WITH PRODUCTS ============
function ProductSection({
  title,
  icon,
  products,
  href,
}: {
  title: string;
  icon: React.ReactNode;
  products: ProductItem[];
  href: string;
}) {
  if (!products.length) return null;

  return (
    <div className="px-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="font-bold text-lg flex items-center gap-2">
          {icon} {title}
        </h2>
        <Link href={href} className="text-primary text-sm font-medium flex items-center gap-1">
          Barchasi <ChevronRight className="w-4 h-4" />
        </Link>
      </div>
      <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2">
        {products.map((p) => (
          <div key={p.id} className="min-w-[160px] max-w-[160px]">
            <ProductCard product={p} />
          </div>
        ))}
      </div>
    </div>
  );
}

// ============ PRODUCT GRID ============
function ProductGrid({ title, products }: { title: string; products: ProductItem[] }) {
  if (!products.length) return null;

  return (
    <div className="px-4">
      <h2 className="font-bold text-lg mb-3 flex items-center gap-2">
        <TrendingUp className="w-5 h-5 text-primary" /> {title}
      </h2>
      <div className="grid grid-cols-2 gap-3">
        {products.map((p) => (
          <ProductCard key={p.id} product={p} />
        ))}
      </div>
    </div>
  );
}

// ============ SKELETON LOADERS ============
function HomeSkeleton() {
  return (
    <div className="space-y-6 pt-4 px-4 animate-pulse">
      <div className="h-10 skeleton w-full rounded-full" />
      <div className="h-40 skeleton rounded-2xl" />
      <div className="flex gap-3 overflow-hidden">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="flex flex-col items-center gap-2">
            <div className="w-16 h-16 skeleton rounded-2xl" />
            <div className="w-14 h-3 skeleton rounded" />
          </div>
        ))}
      </div>
      <div className="grid grid-cols-2 gap-3">
        {[...Array(4)].map((_, i) => (
          <div key={i} className="rounded-2xl overflow-hidden">
            <div className="aspect-square skeleton" />
            <div className="p-3 space-y-2">
              <div className="h-4 skeleton rounded w-3/4" />
              <div className="h-3 skeleton rounded w-1/2" />
              <div className="h-5 skeleton rounded w-2/3" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ============ HOME PAGE ============
export default function HomePage() {
  const { data: banners = [] } = useQuery({
    queryKey: ['banners'],
    queryFn: () => shopApi.getBanners(),
  });

  const { data: categories = [] } = useQuery({
    queryKey: ['categories'],
    queryFn: () => shopApi.getCategories(),
  });

  const { data: featuredData, isLoading } = useQuery({
    queryKey: ['featured-products'],
    queryFn: () => shopApi.getFeaturedProducts(10),
  });

  const { data: newData } = useQuery({
    queryKey: ['new-products'],
    queryFn: () => shopApi.getProducts({ sortBy: 'newest', limit: '20' }),
  });

  const { data: popularData } = useQuery({
    queryKey: ['popular-products'],
    queryFn: () => shopApi.getProducts({ sortBy: 'popular', limit: '20' }),
  });

  const featuredProducts = featuredData?.products ?? [];
  const newProducts = newData?.products ?? [];
  const popularProducts = popularData?.products ?? [];

  if (isLoading) return <HomeSkeleton />;

  return (
    <div className="space-y-6 pb-6">
      {/* Header — sticky search bar */}
      <div className="sticky top-0 z-40 pt-3 px-4 pb-2">
        <div className="flex items-center gap-3">
          <Link href="/" className="font-extrabold text-xl text-primary shrink-0">
            TOPLA
          </Link>
          <Link href="/search" className="flex-1">
            <div className="search-glass flex items-center gap-2 px-4 py-2.5">
              <Search className="w-4 h-4 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Mahsulot qidirish...</span>
            </div>
          </Link>
        </div>
        <div className="flex items-center gap-1 mt-2 text-xs text-muted-foreground">
          <MapPin className="w-3 h-3" />
          <span>Toshkent</span>
        </div>
      </div>

      {/* Banners */}
      <BannerCarousel banners={banners} />

      {/* Categories */}
      <CategoryRow categories={categories} />

      {/* Featured products — horizontal scroll */}
      <ProductSection
        title="Tavsiya etilgan"
        icon={<Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />}
        products={featuredProducts}
        href="/search?featured=true"
      />

      {/* New products — horizontal scroll */}
      <ProductSection
        title="Yangi mahsulotlar"
        icon={<Zap className="w-5 h-5 text-blue-500" />}
        products={newProducts.slice(0, 10)}
        href="/search?sortBy=newest"
      />

      {/* Popular products — grid */}
      <ProductGrid title="Mashhur mahsulotlar" products={popularProducts} />
    </div>
  );
}
