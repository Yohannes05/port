import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'author' | 'delivery';
  created_at: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
  isAdmin: () => boolean;
  isAuthor: () => boolean;
  isUser: () => boolean;
  isDeliveryStaff: () => boolean;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      setAuth: (user: User, token: string) =>
        set({
          user,
          token,
          isAuthenticated: true,
        }),
      logout: () =>
        set({
          user: null,
          token: null,
          isAuthenticated: false,
        }),
      isAdmin: () => get().user?.role === 'admin',
      isAuthor: () => get().user?.role === 'author',
      isUser: () => get().user?.role === 'user',
      isDeliveryStaff: () => get().user?.role === 'delivery',
    }),
    {
      name: 'auth-storage',
    }
  )
);