import axios from 'axios';
import { useAuthStore } from '@/store/authStore';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
}

// Auth API
export const authApi = {
  register: (data: {
    name: string;
    email: string;
    password: string;
    password_confirmation: string;
    role: string;
  }) => api.post('/register', data),

  login: (data: { email: string; password: string }) =>
    api.post('/login', data),

  logout: () => api.post('/logout'),

  getUser: () => api.get('/user'),
};

// Books API
export const booksApi = {
  getBooks: (params?: {
    search?: string;
    category_id?: number;
    author_id?: number;
    sort_by?: string;
    sort_order?: string;
    page?: number;
  }) => api.get('/books', { params }),

  getBook: (id: number) => api.get(`/books/${id}`),

  createBook: (data: {
    title: string;
    description: string;
    price: number;
    stock: number;
    category_id: number;
    image_url?: string;
  }) => api.post('/books', data),

  updateBook: (id: number, data: {
    title: string;
    description: string;
    price: number;
    stock: number;
    category_id: number;
    image_url?: string;
  }) => api.put(`/books/${id}`, data),

  deleteBook: (id: number) => api.delete(`/books/${id}`),

  updateBookStatus: (id: number, status: string) =>
    api.put(`/admin/books/${id}/status`, { status }),
};

// Categories API
export const categoriesApi = {
  getCategories: () => api.get('/categories'),
  getCategory: (id: number) => api.get(`/categories/${id}`),
  createCategory: (data: { name: string; description?: string }) =>
    api.post('/categories', data),
  updateCategory: (id: number, data: { name: string; description?: string }) =>
    api.put(`/categories/${id}`, data),
  deleteCategory: (id: number) => api.delete(`/categories/${id}`),
};

// Orders API
export const ordersApi = {
  getOrders: (params?: { status?: string; page?: number }) =>
    api.get('/orders', { params }),

  getOrder: (id: number) => api.get(`/orders/${id}`),

  createOrder: (data: {
    address: string;
    items: Array<{ book_id: number; quantity: number }>;
  }) => api.post('/orders', data),

  updateOrderStatus: (id: number, status: string) =>
    api.put(`/orders/${id}/status`, { status }),

  assignDelivery: (id: number, delivery_staff_id: number) =>
    api.put(`/admin/orders/${id}/assign-delivery`, { delivery_staff_id }),
};

// Reviews API
export const reviewsApi = {
  getReviews: (params?: { book_id?: number; user_id?: number; page?: number }) =>
    api.get('/reviews', { params }),

  createReview: (data: {
    book_id: number;
    rating: number;
    comment?: string;
  }) => api.post('/reviews', data),

  updateReview: (id: number, data: { rating: number; comment?: string }) =>
    api.put(`/reviews/${id}`, data),

  deleteReview: (id: number) => api.delete(`/reviews/${id}`),
};

// Admin API
export const adminApi = {
  getDashboard: () => api.get('/admin/dashboard'),
  getAnalytics: (period?: number) => api.get('/admin/analytics', { params: { period } }),
  getUsers: (params?: { role?: string; search?: string; page?: number }) =>
    api.get('/admin/users', { params }),
  getPendingBooks: () => api.get('/admin/pending-books'),
  getDeliveryStaff: () => api.get('/admin/delivery-staff'),
};

export default api;