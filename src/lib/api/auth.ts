import api, { setToken, removeToken } from './client';

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  fullName: string;
  firstName?: string;
  lastName?: string;
  phone: string;
  shopName: string;
  shopDescription?: string;
  shopPhone?: string;
  category?: string;
  city?: string;
  address?: string;
  businessType?: string;
  fulfillmentType?: 'FBS' | 'DBS';
  inn?: string;
}

export interface AuthResponse {
  token: string;
  user: {
    id: string;
    email: string;
    fullName?: string;
    firstName?: string;
    lastName?: string;
    role: string;
    phone: string;
    avatarUrl?: string;
  };
}

export interface VendorProfile {
  id: string;
  email: string;
  fullName?: string;
  firstName?: string;
  lastName?: string;
  phone: string;
  role: string;
  avatarUrl?: string;
  shop?: {
    id: string;
    name: string;
    status: string;
  };
}

export const authApi = {
  login: async (data: LoginRequest): Promise<AuthResponse> => {
    const response = await api.post<AuthResponse>('/auth/vendor/login', data);
    if (response.token) {
      setToken(response.token);
    }
    return response;
  },

  register: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await api.post<AuthResponse>('/auth/vendor/register', data);
    if (response.token) {
      setToken(response.token);
    }
    return response;
  },

  logout: () => {
    removeToken();
    if (typeof window !== 'undefined') {
      window.location.href = '/vendor/login';
    }
  },

  getProfile: () => api.get<VendorProfile>('/vendor/profile'),
};

export default authApi;
