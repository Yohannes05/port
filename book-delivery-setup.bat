@echo off
REM 📘 Book Delivery System - Windows Setup Script
echo 🚀 Book Delivery System - Auto Setup for Windows
echo ================================================

echo 📋 Checking prerequisites...

REM Check PHP
php --version >nul 2>&1
if errorlevel 1 (
    echo ❌ PHP not found! Please install PHP first.
    echo 📥 Download from: https://windows.php.net/download/
    pause
    exit /b 1
)
echo ✅ PHP found

REM Check Composer
composer --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Composer not found! Please install Composer first.
    echo 📥 Download from: https://getcomposer.org/download/
    pause
    exit /b 1
)
echo ✅ Composer found

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found! Please install Node.js first.
    echo 📥 Download from: https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Node.js found

echo.
echo 🏗️ Creating project structure...

REM Create main directory
if not exist "book-delivery-system" mkdir book-delivery-system
cd book-delivery-system

echo 🔧 Setting up Laravel backend...
composer create-project laravel/laravel backend --prefer-dist --quiet

cd backend
echo 📦 Installing Sanctum...
composer require laravel/sanctum --quiet
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --quiet

echo 🗄️ Setting up database...
php artisan migrate --quiet
php artisan db:seed --quiet

cd ..

echo 🎨 Setting up Next.js frontend...
call npx create-next-app@latest frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes

cd frontend
echo 📦 Installing additional packages...
call npm install zustand axios lucide-react @headlessui/react clsx tailwind-merge --silent

echo NEXT_PUBLIC_API_URL=http://localhost:8000/api > .env.local

cd ..

echo.
echo ✅ Setup complete!
echo.
echo 🎯 To start the application:
echo 1. Backend: cd backend ^&^& php artisan serve
echo 2. Frontend: cd frontend ^&^& npm run dev
echo.
echo 🌐 Then visit: http://localhost:3000
echo.
echo 🔑 Demo Accounts:
echo - Admin: admin@bookdelivery.com / password123
echo - User: user@bookdelivery.com / password123
echo.
pause