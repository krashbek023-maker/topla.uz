'use client';

import { useState } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, SlidersHorizontal, Star, Heart, ChevronDown } from 'lucide-react';
import { shopApi, type ProductItem } from '@/lib/api/shop';
import { formatPrice } from '@/lib/utils';

const sortOptions = [
  { value: 'newest', label: 'Yangi' },
  { value: 'popular', label: 'Mashhur' },
  { value: 'price_asc', label: 'Arzon→Qimmat' },
  { value: 'price_desc', label: 'Qimmat→Arzon' },
  { value: 'rating', label: 'Reyting' },
];

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

export default function CategoryDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [sortBy, setSortBy] = useState('newest');
  const [page, setPage] = useState(1);
  const [showSort, setShowSort] = useState(false);
  const [subcategoryId, setSubcategoryId] = useState<string | null>(null);

  const { data: categories = [] } = useQuery({
    queryKey: ['categories'],
    queryFn: () => shopApi.getCategories(),
  });

  const category = categories.find((c) => c.id === id);

  const params: Record<string, string> = {
    categoryId: id,
    sortBy,
    page: String(page),
    limit: '20',
  };
  if (subcategoryId) params.subcategoryId = subcategoryId;

  const { data, isLoading } = useQuery({
    queryKey: ['category-products', id, sortBy, page, subcategoryId],
    queryFn: () => shopApi.getProducts(params),
    enabled: !!id,
  });

  const products = data?.products ?? [];
  const pagination = data?.pagination;

  return (
    <div className="pb-6">
      {/* Header */}
      <div className="sticky top-0 z-40 glass-nav px-4 py-3">
        <div className="flex items-center gap-3">
          <Link href="/categories">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <h1 className="font-bold text-lg flex-1 truncate">
            {category?.icon} {category?.nameUz || 'Kategoriya'}
          </h1>
          <button
            onClick={() => setShowSort(!showSort)}
            className="p-2 rounded-xl glass"
          >
            <SlidersHorizontal className="w-4 h-4" />
          </button>
        </div>

        {/* Subcategory pills */}
        {category?.subcategories && category.subcategories.length > 0 && (
          <div className="flex gap-2 mt-3 overflow-x-auto no-scrollbar">
            <button
              onClick={() => setSubcategoryId(null)}
              className={`category-pill text-xs whitespace-nowrap ${!subcategoryId ? 'active' : ''}`}
            >
              Barchasi
            </button>
            {category.subcategories.map((sub) => (
              <button
                key={sub.id}
                onClick={() => setSubcategoryId(sub.id === subcategoryId ? null : sub.id)}
                className={`category-pill text-xs whitespace-nowrap ${sub.id === subcategoryId ? 'active' : ''}`}
              >
                {sub.nameUz}
              </button>
            ))}
          </div>
        )}

        {/* Sort dropdown */}
        {showSort && (
          <div className="mt-2 glass rounded-xl p-2 space-y-1">
            {sortOptions.map((opt) => (
              <button
                key={opt.value}
                onClick={() => { setSortBy(opt.value); setShowSort(false); setPage(1); }}
                className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-colors ${
                  sortBy === opt.value ? 'bg-primary text-white' : 'hover:bg-muted'
                }`}
              >
                {opt.label}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Products grid */}
      <div className="px-4 mt-4">
        {isLoading ? (
          <div className="grid grid-cols-2 gap-3">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="rounded-2xl overflow-hidden animate-pulse">
                <div className="aspect-square skeleton" />
                <div className="p-3 space-y-2">
                  <div className="h-4 skeleton rounded w-3/4" />
                  <div className="h-3 skeleton rounded w-1/2" />
                  <div className="h-5 skeleton rounded w-2/3" />
                </div>
              </div>
            ))}
          </div>
        ) : products.length === 0 ? (
          <div className="text-center py-20">
            <p className="text-4xl mb-3">📦</p>
            <p className="text-muted-foreground">Mahsulot topilmadi</p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-2 gap-3">
              {products.map((p) => (
                <ProductCard key={p.id} product={p} />
              ))}
            </div>

            {/* Load more */}
            {pagination && pagination.page < pagination.totalPages && (
              <button
                onClick={() => setPage((p) => p + 1)}
                className="w-full mt-4 py-3 glass rounded-xl text-sm font-medium text-primary flex items-center justify-center gap-1"
              >
                Ko&apos;proq ko&apos;rsatish <ChevronDown className="w-4 h-4" />
              </button>
            )}
          </>
        )}
      </div>
    </div>
  );
}
