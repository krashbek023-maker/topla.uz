'use client';

import { useState, useEffect, useRef, Suspense } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useSearchParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, Search as SearchIcon, X, Star, Heart, Clock, TrendingUp } from 'lucide-react';
import { shopApi, type ProductItem } from '@/lib/api/shop';
import { formatPrice } from '@/lib/utils';

const trendingSearches = ['telefon', 'krossovka', 'sumka', 'soat', 'naushnik', 'kiyim'];

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
        <div className="flex items-center gap-1 mb-1">
          <Star className="w-3.5 h-3.5 rating-star fill-current" />
          <span className="text-xs text-muted-foreground">{product.rating?.toFixed(1) || '0.0'}</span>
        </div>
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

export default function SearchPage() {
  return (
    <Suspense fallback={<div className="flex items-center justify-center min-h-screen"><div className="shimmer w-8 h-8 rounded-full" /></div>}>
      <SearchContent />
    </Suspense>
  );
}

function SearchContent() {
  const searchParams = useSearchParams();
  const initialQuery = searchParams.get('q') || '';
  const [query, setQuery] = useState(initialQuery);
  const [debouncedQuery, setDebouncedQuery] = useState(initialQuery);
  const inputRef = useRef<HTMLInputElement>(null);

  // Recent searches from localStorage
  const [recentSearches, setRecentSearches] = useState<string[]>([]);

  useEffect(() => {
    const saved = localStorage.getItem('recent_searches');
    if (saved) setRecentSearches(JSON.parse(saved));
    inputRef.current?.focus();
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), 400);
    return () => clearTimeout(timer);
  }, [query]);

  const { data, isLoading } = useQuery({
    queryKey: ['search-products', debouncedQuery],
    queryFn: () => shopApi.searchProducts(debouncedQuery, 40),
    enabled: debouncedQuery.length >= 2,
  });

  const products = data?.products ?? [];

  const saveSearch = (term: string) => {
    const updated = [term, ...recentSearches.filter((s) => s !== term)].slice(0, 10);
    setRecentSearches(updated);
    localStorage.setItem('recent_searches', JSON.stringify(updated));
  };

  const handleSearch = (term: string) => {
    setQuery(term);
    setDebouncedQuery(term);
    if (term.length >= 2) saveSearch(term);
  };

  const clearRecent = () => {
    setRecentSearches([]);
    localStorage.removeItem('recent_searches');
  };

  const showEmpty = debouncedQuery.length >= 2 && !isLoading && products.length === 0;
  const showDefault = debouncedQuery.length < 2;

  return (
    <div className="pb-6">
      {/* Search header */}
      <div className="sticky top-0 z-40 glass-nav px-4 py-3">
        <div className="flex items-center gap-3">
          <Link href="/">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div className="flex-1 search-glass flex items-center gap-2 px-4 py-2.5">
            <SearchIcon className="w-4 h-4 text-muted-foreground shrink-0" />
            <input
              ref={inputRef}
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && query.length >= 2) saveSearch(query);
              }}
              placeholder="Mahsulot qidirish..."
              className="flex-1 bg-transparent text-sm outline-none"
            />
            {query && (
              <button onClick={() => { setQuery(''); inputRef.current?.focus(); }}>
                <X className="w-4 h-4 text-muted-foreground" />
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="px-4 mt-4">
        {showDefault && (
          <div className="space-y-6">
            {/* Recent searches */}
            {recentSearches.length > 0 && (
              <div>
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-semibold text-sm flex items-center gap-2">
                    <Clock className="w-4 h-4" /> So&apos;nggi qidiruvlar
                  </h3>
                  <button onClick={clearRecent} className="text-xs text-muted-foreground">Tozalash</button>
                </div>
                <div className="flex flex-wrap gap-2">
                  {recentSearches.map((term) => (
                    <button
                      key={term}
                      onClick={() => handleSearch(term)}
                      className="category-pill text-xs"
                    >
                      {term}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Trending */}
            <div>
              <h3 className="font-semibold text-sm flex items-center gap-2 mb-3">
                <TrendingUp className="w-4 h-4 text-primary" /> Trend qidiruvlar
              </h3>
              <div className="flex flex-wrap gap-2">
                {trendingSearches.map((term) => (
                  <button
                    key={term}
                    onClick={() => handleSearch(term)}
                    className="category-pill text-xs"
                  >
                    {term}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {isLoading && debouncedQuery.length >= 2 && (
          <div className="grid grid-cols-2 gap-3">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="rounded-2xl overflow-hidden animate-pulse">
                <div className="aspect-square skeleton" />
                <div className="p-3 space-y-2">
                  <div className="h-4 skeleton rounded w-3/4" />
                  <div className="h-5 skeleton rounded w-2/3" />
                </div>
              </div>
            ))}
          </div>
        )}

        {showEmpty && (
          <div className="text-center py-20">
            <p className="text-4xl mb-3">🔍</p>
            <p className="font-medium mb-1">&quot;{debouncedQuery}&quot; bo&apos;yicha natija topilmadi</p>
            <p className="text-sm text-muted-foreground">Boshqa so&apos;z bilan qidirib ko&apos;ring</p>
          </div>
        )}

        {!showDefault && products.length > 0 && (
          <div>
            <p className="text-sm text-muted-foreground mb-3">{data?.pagination?.total ?? 0} ta natija</p>
            <div className="grid grid-cols-2 gap-3">
              {products.map((p) => (
                <ProductCard key={p.id} product={p} />
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
