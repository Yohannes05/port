# 🚀 How to Run the Book Delivery System

## ✅ STEP-BY-STEP INSTRUCTIONS

### Step 1: Start the Backend (Laravel API)

```bash
# 1. Open a terminal and navigate to the backend folder
cd /workspace/book-delivery-system/backend

# 2. Start the Laravel server
php artisan serve --host=0.0.0.0 --port=8000
```

**✅ You should see:** 
```
Laravel development server started: http://0.0.0.0:8000
```

**🌐 Backend API is now running at:** `http://localhost:8000`

---

### Step 2: Start the Frontend (Next.js)

```bash
# 1. Open a NEW terminal and navigate to the frontend folder
cd /workspace/book-delivery-system/frontend

# 2. Start the Next.js development server
npm run dev
```

**✅ You should see:**
```
▲ Next.js 15.1.3
- Local:        http://localhost:3000
- Ready in 2.3s
```

**🌐 Frontend is now running at:** `http://localhost:3000`

---

## 🎯 What to Do Next

### 1. Open Your Browser
Go to: **http://localhost:3000**

### 2. Try These Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@bookdelivery.com | password123 |
| **Author** | author@bookdelivery.com | password123 |
| **User** | user@bookdelivery.com | password123 |
| **Delivery** | delivery@bookdelivery.com | password123 |

### 3. Explore These Features

**As Admin (admin@bookdelivery.com):**
- Go to `/admin/dashboard` after login
- Manage users, books, and orders
- View system analytics

**As Author (author@bookdelivery.com):**
- Go to `/author/dashboard` after login  
- Upload and manage books
- View sales data

**As User (user@bookdelivery.com):**
- Browse books at `/books`
- Add books to cart
- Place orders
- Leave reviews

**As Delivery Staff (delivery@bookdelivery.com):**
- View assigned deliveries
- Update delivery status

---

## 🔧 Troubleshooting

### If Backend Won't Start:
```bash
cd /workspace/book-delivery-system/backend
composer install
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
```

### If Frontend Won't Start:
```bash
cd /workspace/book-delivery-system/frontend
npm install
echo "NEXT_PUBLIC_API_URL=http://localhost:8000/api" > .env.local
npm run dev
```

### If You Get Port Errors:
- Use different ports: `--port=8001` for backend
- Update frontend `.env.local`: `NEXT_PUBLIC_API_URL=http://localhost:8001/api`

---

## 🎉 You're All Set!

Once both servers are running:
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000/api

The system includes:
- ✅ Complete user authentication
- ✅ Role-based dashboards  
- ✅ Book catalog with search
- ✅ Shopping cart & orders
- ✅ Review system
- ✅ Admin management panel
- ✅ Author book management
- ✅ Delivery tracking

**Happy exploring! 🚀**