'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Layout from '@/components/Layout';
import { booksApi, categoriesApi } from '@/lib/api';
import { Book } from '@/store/cartStore';
import { formatPrice } from '@/lib/utils';
import { BookOpen, ShoppingCart, Star, TrendingUp } from 'lucide-react';

interface Category {
  id: number;
  name: string;
  description: string;
  books_count: number;
}

export default function Home() {
  const [featuredBooks, setFeaturedBooks] = useState<Book[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [booksResponse, categoriesResponse] = await Promise.all([
          booksApi.getBooks({ sort_by: 'created_at', sort_order: 'desc' }),
          categoriesApi.getCategories(),
        ]);

        if (booksResponse.data.success) {
          setFeaturedBooks(booksResponse.data.books.data.slice(0, 6));
        }

        if (categoriesResponse.data.success) {
          setCategories(categoriesResponse.data.categories);
        }
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-12">
        {/* Hero Section */}
        <section className="bg-gradient-to-r from-blue-600 to-purple-700 text-white rounded-lg p-12 text-center">
          <h1 className="text-5xl font-bold mb-4">
            Welcome to BookDelivery
          </h1>
          <p className="text-xl mb-8 max-w-2xl mx-auto">
            Discover amazing books from talented authors and get them delivered to your doorstep
          </p>
          <div className="flex justify-center space-x-4">
            <Link
              href="/books"
              className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
            >
              Browse Books
            </Link>
            <Link
              href="/register"
              className="border-2 border-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-600 transition-colors"
            >
              Join as Author
            </Link>
          </div>
        </section>

        {/* Stats Section */}
        <section className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-white p-6 rounded-lg shadow-md text-center">
            <BookOpen className="w-12 h-12 text-blue-600 mx-auto mb-4" />
            <h3 className="text-2xl font-bold text-gray-900">
              {featuredBooks.length}+
            </h3>
            <p className="text-gray-600">Books Available</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md text-center">
            <Star className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
            <h3 className="text-2xl font-bold text-gray-900">4.8/5</h3>
            <p className="text-gray-600">Average Rating</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md text-center">
            <TrendingUp className="w-12 h-12 text-green-600 mx-auto mb-4" />
            <h3 className="text-2xl font-bold text-gray-900">Fast</h3>
            <p className="text-gray-600">Delivery Service</p>
          </div>
        </section>

        {/* Featured Books */}
        <section>
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-3xl font-bold text-gray-900">Featured Books</h2>
            <Link
              href="/books"
              className="text-blue-600 hover:text-blue-800 font-semibold"
            >
              View All Books →
            </Link>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {featuredBooks.map((book) => (
              <div
                key={book.id}
                className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
              >
                {book.image_url && (
                  <img
                    src={book.image_url}
                    alt={book.title}
                    className="w-full h-48 object-cover"
                  />
                )}
                <div className="p-6">
                  <h3 className="text-xl font-semibold mb-2 text-gray-900">
                    {book.title}
                  </h3>
                  <p className="text-gray-600 mb-2">by {book.author.name}</p>
                  <p className="text-gray-700 text-sm mb-4 line-clamp-2">
                    {book.description}
                  </p>
                  <div className="flex justify-between items-center">
                    <span className="text-2xl font-bold text-blue-600">
                      {formatPrice(book.price)}
                    </span>
                    <Link
                      href={`/books/${book.id}`}
                      className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      View Details
                    </Link>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Categories */}
        <section>
          <h2 className="text-3xl font-bold text-gray-900 mb-8">
            Browse by Category
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {categories.map((category) => (
              <Link
                key={category.id}
                href={`/books?category=${category.id}`}
                className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow text-center"
              >
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  {category.name}
                </h3>
                <p className="text-gray-600 text-sm mb-4">
                  {category.description}
                </p>
                <span className="text-blue-600 font-semibold">
                  {category.books_count || 0} books
                </span>
              </Link>
            ))}
          </div>
        </section>

        {/* CTA Section */}
        <section className="bg-gray-100 rounded-lg p-12 text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Ready to Start Reading?
          </h2>
          <p className="text-lg text-gray-700 mb-8">
            Join thousands of readers who trust BookDelivery for their reading needs
          </p>
          <Link
            href="/register"
            className="bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors inline-flex items-center"
          >
            <ShoppingCart className="w-5 h-5 mr-2" />
            Get Started Today
          </Link>
        </section>
      </div>
    </Layout>
  );
}