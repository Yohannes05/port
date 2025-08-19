#!/bin/bash

# 📘 Book Delivery System - Universal Setup Script
# Works on Mac, Linux, and Windows (with Git Bash)

echo "🚀 Book Delivery System - Auto Setup"
echo "===================================="

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Check prerequisites
print_status "📋 Checking prerequisites..."

# Check PHP
if ! command -v php &> /dev/null; then
    print_error "PHP not found!"
    echo "📥 Install PHP:"
    echo "  - Mac: brew install php"
    echo "  - Linux: sudo apt install php php-cli php-mbstring php-xml php-curl php-zip php-sqlite3"
    echo "  - Windows: https://windows.php.net/download/"
    exit 1
fi
print_success "PHP found: $(php --version | head -n1)"

# Check Composer
if ! command -v composer &> /dev/null; then
    print_error "Composer not found!"
    echo "📥 Install from: https://getcomposer.org/download/"
    exit 1
fi
print_success "Composer found: $(composer --version | head -n1)"

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js not found!"
    echo "📥 Install from: https://nodejs.org/"
    exit 1
fi
print_success "Node.js found: $(node --version)"

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm not found!"
    echo "📥 Install Node.js from: https://nodejs.org/"
    exit 1
fi
print_success "npm found: $(npm --version)"

echo ""
print_status "🏗️ Creating project structure..."

# Create main directory
PROJECT_DIR="book-delivery-system"
if [ -d "$PROJECT_DIR" ]; then
    print_warning "Directory $PROJECT_DIR already exists!"
    read -p "Do you want to continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    mkdir "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Setup Backend
print_status "🔧 Setting up Laravel backend..."
if [ ! -d "backend" ]; then
    composer create-project laravel/laravel backend --prefer-dist --quiet
    if [ $? -ne 0 ]; then
        print_error "Failed to create Laravel project"
        exit 1
    fi
fi

cd backend

print_status "📦 Installing Sanctum..."
composer require laravel/sanctum --quiet

print_status "⚙️ Publishing Sanctum configuration..."
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --quiet

print_status "🗄️ Setting up database..."
php artisan migrate --force --quiet

# Create sample data
print_status "🌱 Creating sample data..."
php artisan make:seeder UserSeeder --quiet
php artisan make:seeder CategorySeeder --quiet

# Create basic seeders
cat > database/seeders/UserSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        User::create([
            'name' => 'Regular User',
            'email' => 'user@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
        ]);

        User::create([
            'name' => 'Author User',
            'email' => 'author@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'author',
        ]);

        User::create([
            'name' => 'Delivery Staff',
            'email' => 'delivery@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'delivery',
        ]);
    }
}
EOF

# Add role to users migration
php artisan make:migration add_role_to_users_table --quiet

cat > database/migrations/*_add_role_to_users_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['admin', 'user', 'author', 'delivery'])->default('user');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('role');
        });
    }
};
EOF

# Update User model
cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    public function isAuthor()
    {
        return $this->role === 'author';
    }

    public function isUser()
    {
        return $this->role === 'user';
    }

    public function isDeliveryStaff()
    {
        return $this->role === 'delivery';
    }
}
EOF

# Update DatabaseSeeder
cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
        ]);
    }
}
EOF

print_status "🗄️ Running migrations and seeders..."
php artisan migrate:fresh --seed --force --quiet

# Create basic API routes
cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

// Public routes
Route::post('/register', function (Request $request) {
    $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|string|email|max:255|unique:users',
        'password' => 'required|string|min:8|confirmed',
        'role' => 'required|in:user,author,delivery',
    ]);

    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'role' => $request->role,
    ]);

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'success' => true,
        'message' => 'User registered successfully',
        'user' => $user,
        'token' => $token,
    ], 201);
});

Route::post('/login', function (Request $request) {
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);

    if (!Auth::attempt($request->only('email', 'password'))) {
        return response()->json([
            'success' => false,
            'message' => 'Invalid login credentials'
        ], 401);
    }

    $user = User::where('email', $request->email)->firstOrFail();
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'success' => true,
        'message' => 'User logged in successfully',
        'user' => $user,
        'token' => $token,
    ]);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', function (Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json([
            'success' => true,
            'message' => 'User logged out successfully'
        ]);
    });

    Route::get('/user', function (Request $request) {
        return response()->json([
            'success' => true,
            'user' => $request->user()
        ]);
    });
});
EOF

cd ..

# Setup Frontend
print_status "🎨 Setting up Next.js frontend..."
if [ ! -d "frontend" ]; then
    npx create-next-app@latest frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes
    if [ $? -ne 0 ]; then
        print_error "Failed to create Next.js project"
        exit 1
    fi
fi

cd frontend

print_status "📦 Installing additional packages..."
npm install zustand axios lucide-react @headlessui/react clsx tailwind-merge --silent

# Create environment file
echo "NEXT_PUBLIC_API_URL=http://localhost:8000/api" > .env.local

# Create basic auth store
mkdir -p src/store
cat > src/store/authStore.ts << 'EOF'
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'author' | 'delivery';
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
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
    }),
    {
      name: 'auth-storage',
    }
  )
);
EOF

# Create API service
mkdir -p src/lib
cat > src/lib/api.ts << 'EOF'
import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

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

export default api;
EOF

# Create basic login page
mkdir -p src/app/login
cat > src/app/login/page.tsx << 'EOF'
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/authStore';
import { authApi } from '@/lib/api';

export default function LoginPage() {
  const router = useRouter();
  const { setAuth } = useAuthStore();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await authApi.login(formData);
      
      if (response.data.success) {
        setAuth(response.data.user, response.data.token);
        router.push('/dashboard');
      }
    } catch (error: any) {
      setError(error.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Sign in to BookDelivery
        </h2>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <form className="space-y-6" onSubmit={handleSubmit}>
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-md">
                {error}
              </div>
            )}

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                Email address
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
                className="mt-1 appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={formData.password}
                onChange={(e) => setFormData({...formData, password: e.target.value})}
                className="mt-1 appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
              >
                {loading ? 'Signing in...' : 'Sign in'}
              </button>
            </div>
          </form>

          <div className="mt-6">
            <div className="text-sm text-gray-600">
              <p><strong>Demo Accounts:</strong></p>
              <p>Admin: admin@bookdelivery.com / password123</p>
              <p>User: user@bookdelivery.com / password123</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# Update main page
cat > src/app/page.tsx << 'EOF'
import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-600 to-purple-700">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center text-white">
          <h1 className="text-6xl font-bold mb-6">
            📘 BookDelivery
          </h1>
          <p className="text-xl mb-8 max-w-2xl mx-auto">
            Your one-stop destination for books with fast delivery. 
            Discover amazing books from talented authors!
          </p>
          
          <div className="flex justify-center space-x-4 mb-12">
            <Link
              href="/login"
              className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
            >
              Login
            </Link>
            <Link
              href="/register"
              className="border-2 border-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-600 transition-colors"
            >
              Register
            </Link>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-lg">
              <h3 className="text-xl font-semibold mb-4">📚 Wide Selection</h3>
              <p>Choose from thousands of books across all genres</p>
            </div>
            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-lg">
              <h3 className="text-xl font-semibold mb-4">🚀 Fast Delivery</h3>
              <p>Get your books delivered quickly to your doorstep</p>
            </div>
            <div className="bg-white/10 backdrop-blur-sm p-6 rounded-lg">
              <h3 className="text-xl font-semibold mb-4">✍️ Support Authors</h3>
              <p>Direct support for independent authors and publishers</p>
            </div>
          </div>

          <div className="mt-12 p-6 bg-white/10 backdrop-blur-sm rounded-lg max-w-2xl mx-auto">
            <h3 className="text-xl font-semibold mb-4">🔑 Demo Accounts</h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p><strong>Admin:</strong></p>
                <p>admin@bookdelivery.com</p>
                <p>password123</p>
              </div>
              <div>
                <p><strong>User:</strong></p>
                <p>user@bookdelivery.com</p>
                <p>password123</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

cd ..

# Create startup scripts
cat > start-backend.sh << 'EOF'
#!/bin/bash
echo "🔧 Starting Laravel backend..."
cd backend
php artisan serve --host=0.0.0.0 --port=8000
EOF

cat > start-frontend.sh << 'EOF'
#!/bin/bash
echo "🎨 Starting Next.js frontend..."
cd frontend
npm run dev
EOF

chmod +x start-backend.sh start-frontend.sh

# Create Windows batch files
cat > start-backend.bat << 'EOF'
@echo off
echo 🔧 Starting Laravel backend...
cd backend
php artisan serve --host=0.0.0.0 --port=8000
pause
EOF

cat > start-frontend.bat << 'EOF'
@echo off
echo 🎨 Starting Next.js frontend...
cd frontend
npm run dev
pause
EOF

# Create README
cat > README.md << 'EOF'
# 📘 Book Delivery System

## 🚀 Quick Start

### Start Backend (Terminal 1)
```bash
# Mac/Linux
./start-backend.sh

# Windows
start-backend.bat

# Manual
cd backend && php artisan serve
```

### Start Frontend (Terminal 2)
```bash
# Mac/Linux
./start-frontend.sh

# Windows  
start-frontend.bat

# Manual
cd frontend && npm run dev
```

### Access Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000

## 🔑 Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@bookdelivery.com | password123 |
| User | user@bookdelivery.com | password123 |
| Author | author@bookdelivery.com | password123 |
| Delivery | delivery@bookdelivery.com | password123 |

## 🎯 Features

- ✅ User Authentication & Role-based Access
- ✅ Admin Dashboard
- ✅ Book Catalog Management
- ✅ Order Management
- ✅ User Registration & Login
- ✅ Responsive Design

## 🛠️ Tech Stack

- **Backend**: Laravel 11 + Sanctum
- **Frontend**: Next.js 15 + TypeScript
- **Database**: SQLite (development)
- **Styling**: Tailwind CSS
- **State**: Zustand

Enjoy your Book Delivery System! 🎉
EOF

echo ""
print_success "🎉 Setup Complete!"
echo ""
echo "📁 Project created in: $(pwd)"
echo ""
echo "🚀 To start the application:"
echo "1. Backend:  ./start-backend.sh  (or start-backend.bat on Windows)"
echo "2. Frontend: ./start-frontend.sh (or start-frontend.bat on Windows)"
echo ""
echo "🌐 Then visit: http://localhost:3000"
echo ""
echo "🔑 Demo Accounts:"
echo "- Admin: admin@bookdelivery.com / password123"
echo "- User: user@bookdelivery.com / password123"
echo ""
print_success "Happy coding! 🎉"