'use client';

import React, { ReactNode } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/authStore';
import { useCartStore } from '@/store/cartStore';
import { 
  BookOpen, 
  ShoppingCart, 
  User, 
  LogOut, 
  Package, 
  Truck,
  BarChart3,
  Users,
  Home
} from 'lucide-react';

interface LayoutProps {
  children: ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const router = useRouter();
  const { user, isAuthenticated, logout, isAdmin, isAuthor, isDeliveryStaff } = useAuthStore();
  const { getTotalItems } = useCartStore();

  const handleLogout = async () => {
    try {
      logout();
      router.push('/');
    } catch (error) {
      console.error('Logout error:', error);
      logout();
      router.push('/');
    }
  };

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Books', href: '/books', icon: BookOpen },
  ];

  const userNavigation = [
    { name: 'Profile', href: '/profile', icon: User },
    { name: 'Orders', href: '/orders', icon: Package },
  ];

  const authorNavigation = [
    { name: 'My Books', href: '/author/books', icon: BookOpen },
    { name: 'Analytics', href: '/author/analytics', icon: BarChart3 },
  ];

  const adminNavigation = [
    { name: 'Dashboard', href: '/admin/dashboard', icon: BarChart3 },
    { name: 'Users', href: '/admin/users', icon: Users },
    { name: 'Books', href: '/admin/books', icon: BookOpen },
    { name: 'Orders', href: '/admin/orders', icon: Package },
  ];

  const deliveryNavigation = [
    { name: 'Deliveries', href: '/delivery/orders', icon: Truck },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex">
              <div className="flex-shrink-0 flex items-center">
                <Link href="/" className="text-2xl font-bold text-blue-600">
                  BookDelivery
                </Link>
              </div>
              <div className="hidden sm:ml-6 sm:flex sm:space-x-8">
                {navigation.map((item) => (
                  <Link
                    key={item.name}
                    href={item.href}
                    className="inline-flex items-center px-1 pt-1 text-sm font-medium text-gray-900 hover:text-blue-600"
                  >
                    <item.icon className="w-4 h-4 mr-2" />
                    {item.name}
                  </Link>
                ))}
              </div>
            </div>

            <div className="flex items-center space-x-4">
              {isAuthenticated ? (
                <>
                  {/* Cart Icon for Users */}
                  {user?.role === 'user' && (
                    <Link
                      href="/cart"
                      className="relative p-2 text-gray-600 hover:text-blue-600"
                    >
                      <ShoppingCart className="w-6 h-6" />
                      {getTotalItems() > 0 && (
                        <span className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs">
                          {getTotalItems()}
                        </span>
                      )}
                    </Link>
                  )}

                  {/* Role-specific Navigation */}
                  <div className="relative group">
                    <button className="flex items-center space-x-2 text-gray-700 hover:text-blue-600">
                      <User className="w-5 h-5" />
                      <span className="hidden sm:block">{user?.name}</span>
                    </button>
                    
                    <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                      <div className="py-1">
                        {/* User Navigation */}
                        {user?.role === 'user' && userNavigation.map((item) => (
                          <Link
                            key={item.name}
                            href={item.href}
                            className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          >
                            <item.icon className="w-4 h-4 mr-2" />
                            {item.name}
                          </Link>
                        ))}

                        {/* Author Navigation */}
                        {isAuthor() && authorNavigation.map((item) => (
                          <Link
                            key={item.name}
                            href={item.href}
                            className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          >
                            <item.icon className="w-4 h-4 mr-2" />
                            {item.name}
                          </Link>
                        ))}

                        {/* Admin Navigation */}
                        {isAdmin() && adminNavigation.map((item) => (
                          <Link
                            key={item.name}
                            href={item.href}
                            className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          >
                            <item.icon className="w-4 h-4 mr-2" />
                            {item.name}
                          </Link>
                        ))}

                        {/* Delivery Navigation */}
                        {isDeliveryStaff() && deliveryNavigation.map((item) => (
                          <Link
                            key={item.name}
                            href={item.href}
                            className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          >
                            <item.icon className="w-4 h-4 mr-2" />
                            {item.name}
                          </Link>
                        ))}

                        <hr className="my-1" />
                        <button
                          onClick={handleLogout}
                          className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                        >
                          <LogOut className="w-4 h-4 mr-2" />
                          Logout
                        </button>
                      </div>
                    </div>
                  </div>
                </>
              ) : (
                <div className="flex space-x-4">
                  <Link
                    href="/login"
                    className="text-gray-700 hover:text-blue-600 px-3 py-2 text-sm font-medium"
                  >
                    Login
                  </Link>
                  <Link
                    href="/register"
                    className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
                  >
                    Register
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {children}
      </main>

      <footer className="bg-gray-800 text-white mt-12">
        <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <h3 className="text-lg font-semibold mb-4">BookDelivery</h3>
              <p className="text-gray-300">
                Your one-stop destination for books with fast delivery.
              </p>
            </div>
            <div>
              <h4 className="text-md font-semibold mb-4">Quick Links</h4>
              <ul className="space-y-2">
                <li><Link href="/books" className="text-gray-300 hover:text-white">Browse Books</Link></li>
                <li><Link href="/categories" className="text-gray-300 hover:text-white">Categories</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="text-md font-semibold mb-4">For Authors</h4>
              <ul className="space-y-2">
                <li><Link href="/register" className="text-gray-300 hover:text-white">Join as Author</Link></li>
                <li><Link href="/author/books" className="text-gray-300 hover:text-white">Manage Books</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="text-md font-semibold mb-4">Support</h4>
              <ul className="space-y-2">
                <li><Link href="/contact" className="text-gray-300 hover:text-white">Contact Us</Link></li>
                <li><Link href="/help" className="text-gray-300 hover:text-white">Help Center</Link></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-700 mt-8 pt-8 text-center">
            <p className="text-gray-300">
              © 2024 BookDelivery. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}