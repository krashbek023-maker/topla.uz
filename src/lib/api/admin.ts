// ============================================
// Admin Panel API Client
// Connects to topla-backend admin endpoints
// ============================================

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

function getAdminToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('admin_token');
}

export function setAdminToken(token: string): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem('admin_token', token);
}

export function removeAdminToken(): void {
  if (typeof window === 'undefined') return;
  localStorage.removeItem('admin_token');
}

export function isAdminAuthenticated(): boolean {
  return !!getAdminToken();
}

async function adminRequest<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = getAdminToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> || {}),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  if (options.body instanceof FormData) {
    delete headers['Content-Type'];
  }

  const url = `${API_BASE}${endpoint}`;

  const response = await fetch(url, { ...options, headers });

  if (!response.ok) {
    let errorData: any;
    try { errorData = await response.json(); } catch { /* ignore */ }

    if (response.status === 401) {
      removeAdminToken();
      if (typeof window !== 'undefined') {
        window.location.href = '/admin/login';
      }
    }

    throw new Error(errorData?.message || `HTTP ${response.status}`);
  }

  const text = await response.text();
  if (!text) return {} as T;
  return JSON.parse(text);
}

// ============================================
// Auth
// ============================================
export async function adminLogin(email: string, password: string) {
  const res = await adminRequest<{ success: boolean; data: { token: string; admin: any } }>(
    '/auth/admin/login',
    { method: 'POST', body: JSON.stringify({ email, password }) },
  );
  if (res.data?.token) {
    setAdminToken(res.data.token);
  }
  return res.data;
}

// ============================================
// Dashboard
// ============================================
export async function fetchDashboardStats() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/dashboard');
  return res.data;
}

// ============================================
// Users
// ============================================
export async function fetchUsers(params?: { search?: string; role?: string; status?: string; page?: number }) {
  const query = new URLSearchParams();
  if (params?.search) query.set('search', params.search);
  if (params?.role) query.set('role', params.role);
  if (params?.status) query.set('status', params.status);
  if (params?.page) query.set('page', String(params.page));
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/users?${query}`);
  return res.data;
}

export async function updateUserStatus(id: string, isActive: boolean) {
  const res = await adminRequest<{ success: boolean }>(`/admin/users/${id}/status`, {
    method: 'PUT',
    body: JSON.stringify({ isActive }),
  });
  return res;
}

// ============================================
// Shops
// ============================================
export async function fetchShops(params?: { search?: string; status?: string; page?: number }) {
  const query = new URLSearchParams();
  if (params?.search) query.set('search', params.search);
  if (params?.status) query.set('status', params.status);
  if (params?.page) query.set('page', String(params.page));
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/shops?${query}`);
  return res.data;
}

export async function fetchShopDetail(id: string) {
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/shops/${id}`);
  return res.data;
}

export async function updateShopStatus(id: string, status: string) {
  return adminRequest(`/admin/shops/${id}/status`, {
    method: 'PUT',
    body: JSON.stringify({ status }),
  });
}

export async function updateShopCommission(id: string, commissionRate: number) {
  return adminRequest(`/admin/shops/${id}/commission`, {
    method: 'PUT',
    body: JSON.stringify({ commissionRate }),
  });
}

// ============================================
// Products
// ============================================
export async function fetchProducts(params?: { search?: string; status?: string; shopId?: string; page?: number }) {
  const query = new URLSearchParams();
  if (params?.search) query.set('search', params.search);
  if (params?.status) query.set('status', params.status);
  if (params?.shopId) query.set('shopId', params.shopId);
  if (params?.page) query.set('page', String(params.page));
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/products?${query}`);
  return res.data;
}

export async function blockProduct(id: string, reason: string) {
  return adminRequest(`/admin/products/${id}/block`, {
    method: 'PUT',
    body: JSON.stringify({ reason }),
  });
}

export async function unblockProduct(id: string) {
  return adminRequest(`/admin/products/${id}/unblock`, { method: 'PUT' });
}

export async function deleteProduct(id: string) {
  return adminRequest(`/admin/products/${id}`, { method: 'DELETE' });
}

// ============================================
// Orders
// ============================================
export async function fetchOrders(params?: { status?: string; page?: number }) {
  const query = new URLSearchParams();
  if (params?.status) query.set('status', params.status);
  if (params?.page) query.set('page', String(params.page));
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/orders?${query}`);
  return res.data;
}

export async function fetchOrderDetail(id: string) {
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/orders/${id}`);
  return res.data;
}

// ============================================
// Categories
// ============================================
export async function fetchCategories() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/categories');
  return res.data;
}

export async function createCategory(data: any) {
  return adminRequest('/admin/categories', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateCategory(id: string, data: any) {
  return adminRequest(`/admin/categories/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteCategory(id: string) {
  return adminRequest(`/admin/categories/${id}`, { method: 'DELETE' });
}

// Subcategories
export async function createSubcategory(categoryId: string, data: any) {
  return adminRequest(`/admin/categories/${categoryId}/subcategories`, {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateSubcategory(categoryId: string, subId: string, data: any) {
  return adminRequest(`/admin/categories/${categoryId}/subcategories/${subId}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteSubcategory(categoryId: string, subId: string) {
  return adminRequest(`/admin/categories/${categoryId}/subcategories/${subId}`, { method: 'DELETE' });
}

// ============================================
// Banners
// ============================================
export async function fetchBanners() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/banners');
  return res.data;
}

export async function createBanner(data: any) {
  return adminRequest('/admin/banners', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateBanner(id: string, data: any) {
  return adminRequest(`/admin/banners/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteBanner(id: string) {
  return adminRequest(`/admin/banners/${id}`, { method: 'DELETE' });
}

// ============================================
// Promo Codes
// ============================================
export async function fetchPromoCodes() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/promo-codes');
  return res.data;
}

export async function createPromoCode(data: any) {
  return adminRequest('/admin/promo-codes', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function deletePromoCode(id: string) {
  return adminRequest(`/admin/promo-codes/${id}`, { method: 'DELETE' });
}

// ============================================
// Delivery Zones
// ============================================
export async function fetchDeliveryZones() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/delivery-zones');
  return res.data;
}

export async function createDeliveryZone(data: any) {
  return adminRequest('/admin/delivery-zones', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function deleteDeliveryZone(id: string) {
  return adminRequest(`/admin/delivery-zones/${id}`, { method: 'DELETE' });
}

// ============================================
// Payouts
// ============================================
export async function fetchPayouts(params?: { status?: string; page?: number }) {
  const query = new URLSearchParams();
  if (params?.status) query.set('status', params.status);
  if (params?.page) query.set('page', String(params.page));
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/payouts?${query}`);
  return res.data;
}

export async function processPayout(id: string, data: { status: string; transactionId?: string; rejectionReason?: string }) {
  return adminRequest(`/admin/payouts/${id}/process`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

// ============================================
// Notifications
// ============================================
export async function broadcastNotification(data: { title: string; body: string; type?: string; targetRole?: string }) {
  return adminRequest('/admin/notifications/broadcast', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

// ============================================
// Reports
// ============================================
export async function fetchReports(period: string = 'month') {
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/reports?period=${period}`);
  return res.data;
}

// ============================================
// Logs
// ============================================
export async function fetchLogs(params?: { action?: string; entityType?: string; page?: number; limit?: number }) {
  const query = new URLSearchParams();
  if (params?.action) query.set('action', params.action);
  if (params?.entityType) query.set('entityType', params.entityType);
  if (params?.page) query.set('page', String(params.page));
  if (params?.limit) query.set('limit', String(params.limit));
  const res = await adminRequest<{ success: boolean; data: any }>(`/admin/logs?${query}`);
  return res.data;
}

// ============================================
// Settings
// ============================================
export async function fetchSettings() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/settings');
  return res.data;
}

export async function updateSettings(settings: Record<string, any>) {
  return adminRequest('/admin/settings', {
    method: 'PUT',
    body: JSON.stringify({ settings }),
  });
}

// ============================================
// Brands
// ============================================
export async function fetchBrands() {
  const res = await adminRequest<{ success: boolean; data: any }>('/admin/brands');
  return res.data;
}

export async function createBrand(data: any) {
  return adminRequest('/admin/brands', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateBrand(id: string, data: any) {
  return adminRequest(`/admin/brands/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteBrand(id: string) {
  return adminRequest(`/admin/brands/${id}`, { method: 'DELETE' });
}
