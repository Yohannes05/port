# 🏠 Book Delivery System - Local Setup Guide

## 📋 Prerequisites

Install these on your laptop first:

### 1. PHP (8.1+)
- **Windows**: https://windows.php.net/download/
- **Mac**: `brew install php`
- **Linux**: `sudo apt install php php-cli php-mbstring php-xml php-curl php-zip php-sqlite3`

### 2. Composer
- Download: https://getcomposer.org/download/

### 3. Node.js (18+)
- Download: https://nodejs.org/

### 4. Verify Installation
```bash
php --version
composer --version
node --version
npm --version
```

---

## 🚀 Quick Setup (Recommended)

### Option 1: Download Complete Project

1. **Download the project files** from the workspace
2. **Extract to your desired location** (e.g., Desktop/book-delivery-system)
3. **Follow the steps below**

### Option 2: Create from Scratch

```bash
# 1. Create project folder
mkdir book-delivery-system
cd book-delivery-system

# 2. Create Laravel backend
composer create-project laravel/laravel backend --prefer-dist

# 3. Create Next.js frontend
npx create-next-app@latest frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes
```

---

## 🔧 Backend Setup

```bash
# Navigate to backend
cd backend

# Install Sanctum
composer require laravel/sanctum

# Publish Sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Create database tables
php artisan migrate

# Start server
php artisan serve
```

**Backend will run at:** http://localhost:8000

---

## 🎨 Frontend Setup

```bash
# Navigate to frontend (open new terminal)
cd frontend

# Install dependencies
npm install zustand axios lucide-react @headlessui/react clsx tailwind-merge

# Create environment file
echo "NEXT_PUBLIC_API_URL=http://localhost:8000/api" > .env.local

# Start development server
npm run dev
```

**Frontend will run at:** http://localhost:3000

---

## 🎯 Essential Files to Create

### Backend Files Needed:

1. **Database Migrations** (in `backend/database/migrations/`)
2. **Models** (in `backend/app/Models/`)
3. **Controllers** (in `backend/app/Http/Controllers/API/`)
4. **Routes** (in `backend/routes/api.php`)
5. **Middleware** (in `backend/app/Http/Middleware/`)

### Frontend Files Needed:

1. **Store** (in `frontend/src/store/`)
2. **API Services** (in `frontend/src/lib/`)
3. **Components** (in `frontend/src/components/`)
4. **Pages** (in `frontend/src/app/`)

---

## 📁 Expected Folder Structure

```
book-delivery-system/
├── backend/              (Laravel API)
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
└── frontend/             (Next.js App)
    ├── src/
    ├── public/
    └── ...
```

---

## 🔑 Demo Accounts (After Setup)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@bookdelivery.com | password123 |
| Author | author@bookdelivery.com | password123 |
| User | user@bookdelivery.com | password123 |
| Delivery | delivery@bookdelivery.com | password123 |

---

## 🆘 Need Help?

If you need the complete code files, I can provide them step by step. Just let me know:

1. **Do you want to create from scratch?** (I'll guide you)
2. **Do you want the complete files?** (I'll create them for you)
3. **Having installation issues?** (I'll help troubleshoot)

Choose your preferred approach and I'll help you get it running! 🚀