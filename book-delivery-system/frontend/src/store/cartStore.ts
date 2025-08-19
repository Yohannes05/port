import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface Book {
  id: number;
  title: string;
  description: string;
  price: number;
  stock: number;
  image_url?: string;
  author: {
    id: number;
    name: string;
  };
  category: {
    id: number;
    name: string;
  };
}

export interface CartItem {
  book: Book;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  addToCart: (book: Book, quantity?: number) => void;
  removeFromCart: (bookId: number) => void;
  updateQuantity: (bookId: number, quantity: number) => void;
  clearCart: () => void;
  getTotalItems: () => number;
  getTotalPrice: () => number;
  getCartItem: (bookId: number) => CartItem | undefined;
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      addToCart: (book: Book, quantity = 1) =>
        set((state) => {
          const existingItem = state.items.find(item => item.book.id === book.id);
          
          if (existingItem) {
            return {
              items: state.items.map(item =>
                item.book.id === book.id
                  ? { ...item, quantity: Math.min(item.quantity + quantity, book.stock) }
                  : item
              )
            };
          }
          
          return {
            items: [...state.items, { book, quantity: Math.min(quantity, book.stock) }]
          };
        }),
      removeFromCart: (bookId: number) =>
        set((state) => ({
          items: state.items.filter(item => item.book.id !== bookId)
        })),
      updateQuantity: (bookId: number, quantity: number) =>
        set((state) => {
          if (quantity <= 0) {
            return {
              items: state.items.filter(item => item.book.id !== bookId)
            };
          }
          
          return {
            items: state.items.map(item =>
              item.book.id === bookId
                ? { ...item, quantity: Math.min(quantity, item.book.stock) }
                : item
            )
          };
        }),
      clearCart: () => set({ items: [] }),
      getTotalItems: () => get().items.reduce((total, item) => total + item.quantity, 0),
      getTotalPrice: () => get().items.reduce((total, item) => total + (item.book.price * item.quantity), 0),
      getCartItem: (bookId: number) => get().items.find(item => item.book.id === bookId),
    }),
    {
      name: 'cart-storage',
    }
  )
);