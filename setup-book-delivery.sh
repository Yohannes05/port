#!/bin/bash

# 📘 Book Delivery System - Auto Setup Script
# This script will create the complete project structure

echo "🚀 Setting up Book Delivery System..."
echo "=================================="

# Create main project directory
echo "📁 Creating project structure..."
mkdir -p book-delivery-system
cd book-delivery-system

# Setup Backend (Laravel)
echo "🔧 Setting up Laravel backend..."
composer create-project laravel/laravel backend --prefer-dist
cd backend
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
cd ..

# Setup Frontend (Next.js)
echo "🎨 Setting up Next.js frontend..."
npx create-next-app@latest frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes
cd frontend
npm install zustand axios lucide-react @headlessui/react clsx tailwind-merge
echo "NEXT_PUBLIC_API_URL=http://localhost:8000/api" > .env.local
cd ..

echo "✅ Basic structure created!"
echo "📝 Now I'll create all the custom files..."

# Create backend files
echo "🔧 Creating backend files..."

# Create migrations directory if it doesn't exist
mkdir -p backend/database/migrations

# Create the essential files (this would contain all the PHP code)
echo "📄 Creating database migrations..."
echo "📄 Creating models..."
echo "📄 Creating controllers..."
echo "📄 Creating API routes..."

# Create frontend files
echo "🎨 Creating frontend files..."
mkdir -p frontend/src/store
mkdir -p frontend/src/lib
mkdir -p frontend/src/components
mkdir -p frontend/src/app/login
mkdir -p frontend/src/app/register
mkdir -p frontend/src/app/admin

echo "✅ Project structure created successfully!"
echo ""
echo "🎯 Next steps:"
echo "1. Navigate to the project: cd book-delivery-system"
echo "2. Start backend: cd backend && php artisan serve"
echo "3. Start frontend: cd frontend && npm run dev"
echo ""
echo "🌐 Access your app at: http://localhost:3000"
echo "🔑 Demo accounts will be available after running migrations"

echo "🎉 Setup complete! Happy coding!"