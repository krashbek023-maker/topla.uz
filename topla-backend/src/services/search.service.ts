// ============================================
// Meilisearch Integration Service
// Product search with fuzzy matching
// ============================================

import { env } from '../config/env.js';

const MEILI_URL = process.env.MEILISEARCH_URL || 'http://localhost:7700';
const MEILI_KEY = process.env.MEILISEARCH_API_KEY || '';
const INDEX_NAME = 'products';

interface MeiliProduct {
  id: string;
  nameUz: string;
  nameRu: string;
  descriptionUz: string;
  descriptionRu: string;
  name: string;
  price: number;
  originalPrice: number | null;
  images: string[];
  thumbnailUrl: string | null;
  categoryId: string | null;
  categoryNameUz: string;
  categoryNameRu: string;
  subcategoryId: string | null;
  brandId: string | null;
  brandName: string;
  colorId: string | null;
  shopId: string;
  shopName: string;
  rating: number;
  salesCount: number;
  qualityScore: number;
  stock: number;
  status: string;
  createdAt: string;
}

interface SearchResult {
  hits: MeiliProduct[];
  estimatedTotalHits: number;
  limit: number;
  offset: number;
  processingTimeMs: number;
}

// ============================================
// Helper: fetch from Meilisearch
// ============================================
async function meiliRequest(path: string, method = 'GET', body?: any): Promise<any> {
  try {
    const response = await fetch(`${MEILI_URL}${path}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(MEILI_KEY ? { Authorization: `Bearer ${MEILI_KEY}` } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const text = await response.text();
      console.error(`Meilisearch error: ${response.status} ${text}`);
      return null;
    }

    return response.json();
  } catch (error) {
    console.error('Meilisearch connection error:', error);
    return null;
  }
}

// ============================================
// Initialize index with settings
// ============================================
export async function initMeilisearch(): Promise<void> {
  try {
    // Create index
    await meiliRequest(`/indexes/${INDEX_NAME}`, 'POST', {
      uid: INDEX_NAME,
      primaryKey: 'id',
    });

    // Configure searchable attributes
    await meiliRequest(`/indexes/${INDEX_NAME}/settings`, 'PATCH', {
      searchableAttributes: [
        'nameUz',
        'nameRu',
        'name',
        'descriptionUz',
        'descriptionRu',
        'categoryNameUz',
        'categoryNameRu',
        'brandName',
        'shopName',
      ],
      filterableAttributes: [
        'categoryId',
        'subcategoryId',
        'brandId',
        'colorId',
        'shopId',
        'status',
        'price',
        'rating',
        'qualityScore',
        'stock',
      ],
      sortableAttributes: [
        'price',
        'rating',
        'salesCount',
        'qualityScore',
        'createdAt',
      ],
      rankingRules: [
        'words',
        'typo',
        'proximity',
        'attribute',
        'sort',
        'exactness',
        'qualityScore:desc',
        'salesCount:desc',
      ],
      typoTolerance: {
        enabled: true,
        minWordSizeForTypos: { oneTypo: 3, twoTypos: 6 },
      },
    });

    console.log('✅ Meilisearch initialized');
  } catch (error) {
    console.warn('⚠️ Meilisearch not available, search will use database fallback');
  }
}

// ============================================
// Index a single product
// ============================================
export async function indexProduct(product: any): Promise<void> {
  const doc = buildMeiliDocument(product);
  await meiliRequest(`/indexes/${INDEX_NAME}/documents`, 'POST', [doc]);
}

// ============================================
// Index multiple products
// ============================================
export async function indexProducts(products: any[]): Promise<void> {
  if (products.length === 0) return;
  const docs = products.map(buildMeiliDocument);
  await meiliRequest(`/indexes/${INDEX_NAME}/documents`, 'POST', docs);
}

// ============================================
// Remove product from index
// ============================================
export async function removeProductFromIndex(productId: string): Promise<void> {
  await meiliRequest(`/indexes/${INDEX_NAME}/documents/${productId}`, 'DELETE');
}

// ============================================
// Search products
// ============================================
export async function searchProducts(params: {
  query: string;
  filter?: string[];
  sort?: string[];
  limit?: number;
  offset?: number;
}): Promise<SearchResult | null> {
  const result = await meiliRequest(`/indexes/${INDEX_NAME}/search`, 'POST', {
    q: params.query,
    filter: params.filter,
    sort: params.sort,
    limit: params.limit || 20,
    offset: params.offset || 0,
    attributesToRetrieve: [
      'id', 'nameUz', 'nameRu', 'name', 'price', 'originalPrice',
      'images', 'thumbnailUrl', 'shopId', 'shopName', 'categoryId',
      'categoryNameUz', 'categoryNameRu', 'brandName', 'rating',
      'salesCount', 'qualityScore', 'stock', 'status',
    ],
  });

  return result;
}

// ============================================
// Build Meilisearch document from Prisma product
// ============================================
export function buildMeiliDocument(product: any): MeiliProduct {
  return {
    id: product.id,
    nameUz: product.nameUz || product.name || '',
    nameRu: product.nameRu || '',
    descriptionUz: product.descriptionUz || product.description || '',
    descriptionRu: product.descriptionRu || '',
    name: product.name || product.nameUz || '',
    price: parseFloat(product.price) || 0,
    originalPrice: product.originalPrice ? parseFloat(product.originalPrice) : null,
    images: product.images || [],
    thumbnailUrl: product.thumbnailUrl || (product.images?.[0] || null),
    categoryId: product.categoryId,
    categoryNameUz: product.category?.nameUz || '',
    categoryNameRu: product.category?.nameRu || '',
    subcategoryId: product.subcategoryId,
    brandId: product.brandId,
    brandName: product.brand?.name || '',
    colorId: product.colorId,
    shopId: product.shopId,
    shopName: product.shop?.name || '',
    rating: product.rating || 0,
    salesCount: product.salesCount || 0,
    qualityScore: product.qualityScore || 0,
    stock: product.stock || 0,
    status: product.status || 'active',
    createdAt: product.createdAt?.toISOString?.() || new Date().toISOString(),
  };
}
