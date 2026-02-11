'use client';

import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';
import { ChevronRight, ArrowLeft } from 'lucide-react';
import { shopApi, type Category } from '@/lib/api/shop';

export default function CategoriesPage() {
  const { data: categories = [], isLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: () => shopApi.getCategories(),
  });

  return (
    <div className="pb-6">
      {/* Header */}
      <div className="sticky top-0 z-40 glass-nav px-4 py-3 flex items-center gap-3">
        <Link href="/">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <h1 className="font-bold text-lg">Kategoriyalar</h1>
      </div>

      {/* Category list */}
      <div className="px-4 mt-4 space-y-3">
        {isLoading ? (
          [...Array(8)].map((_, i) => (
            <div key={i} className="glass rounded-2xl p-4 flex items-center gap-4 animate-pulse">
              <div className="w-12 h-12 skeleton rounded-xl" />
              <div className="flex-1 space-y-2">
                <div className="h-4 skeleton rounded w-1/2" />
                <div className="h-3 skeleton rounded w-1/3" />
              </div>
            </div>
          ))
        ) : (
          categories.map((cat: Category) => (
            <Link
              key={cat.id}
              href={`/categories/${cat.id}`}
              className="glass rounded-2xl p-4 flex items-center gap-4 hover-spring block"
            >
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-2xl">
                {cat.icon || '📦'}
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold">{cat.nameUz}</h3>
                {cat._count?.products !== undefined && (
                  <p className="text-xs text-muted-foreground">{cat._count.products} ta mahsulot</p>
                )}
                {cat.subcategories && cat.subcategories.length > 0 && (
                  <p className="text-xs text-muted-foreground mt-0.5">
                    {cat.subcategories.map((s) => s.nameUz).slice(0, 3).join(', ')}
                    {cat.subcategories.length > 3 && '...'}
                  </p>
                )}
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground" />
            </Link>
          ))
        )}
      </div>
    </div>
  );
}
