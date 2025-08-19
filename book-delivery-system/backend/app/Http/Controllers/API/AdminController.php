<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Book;
use App\Models\Order;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    public function dashboard()
    {
        $stats = [
            'total_users' => User::where('role', 'user')->count(),
            'total_authors' => User::where('role', 'author')->count(),
            'total_delivery_staff' => User::where('role', 'delivery')->count(),
            'total_books' => Book::count(),
            'pending_books' => Book::where('status', 'pending')->count(),
            'approved_books' => Book::where('status', 'approved')->count(),
            'total_orders' => Order::count(),
            'pending_orders' => Order::where('status', 'pending')->count(),
            'processing_orders' => Order::where('status', 'processing')->count(),
            'shipped_orders' => Order::where('status', 'shipped')->count(),
            'delivered_orders' => Order::where('status', 'delivered')->count(),
            'total_revenue' => Order::where('status', 'delivered')->sum('total_price'),
            'total_categories' => Category::count(),
        ];

        // Recent orders
        $recentOrders = Order::with(['user', 'orderItems.book'])
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        // Popular books
        $popularBooks = Book::select('books.*')
            ->join('order_items', 'books.id', '=', 'order_items.book_id')
            ->with(['author', 'category'])
            ->groupBy('books.id')
            ->orderByRaw('SUM(order_items.quantity) DESC')
            ->limit(10)
            ->get();

        // Monthly revenue chart data
        $monthlyRevenue = Order::select(
                DB::raw('YEAR(created_at) as year'),
                DB::raw('MONTH(created_at) as month'),
                DB::raw('SUM(total_price) as revenue')
            )
            ->where('status', 'delivered')
            ->where('created_at', '>=', now()->subMonths(12))
            ->groupBy('year', 'month')
            ->orderBy('year', 'desc')
            ->orderBy('month', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'stats' => $stats,
            'recent_orders' => $recentOrders,
            'popular_books' => $popularBooks,
            'monthly_revenue' => $monthlyRevenue,
        ]);
    }

    public function users(Request $request)
    {
        $query = User::query();

        // Filter by role
        if ($request->has('role')) {
            $query->where('role', $request->role);
        }

        // Search by name or email
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $users = $query->orderBy('created_at', 'desc')->paginate(15);

        return response()->json([
            'success' => true,
            'users' => $users
        ]);
    }

    public function pendingBooks()
    {
        $books = Book::with(['author', 'category'])
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'books' => $books
        ]);
    }

    public function deliveryStaff()
    {
        $deliveryStaff = User::where('role', 'delivery')
            ->withCount(['deliveryOrders as active_orders' => function($query) {
                $query->whereIn('status', ['processing', 'shipped']);
            }])
            ->get();

        return response()->json([
            'success' => true,
            'delivery_staff' => $deliveryStaff
        ]);
    }

    public function analytics(Request $request)
    {
        $period = $request->get('period', '30'); // days

        $analytics = [
            'sales_trend' => Order::select(
                    DB::raw('DATE(created_at) as date'),
                    DB::raw('COUNT(*) as orders'),
                    DB::raw('SUM(total_price) as revenue')
                )
                ->where('status', 'delivered')
                ->where('created_at', '>=', now()->subDays($period))
                ->groupBy('date')
                ->orderBy('date')
                ->get(),

            'category_performance' => Category::select('categories.name')
                ->join('books', 'categories.id', '=', 'books.category_id')
                ->join('order_items', 'books.id', '=', 'order_items.book_id')
                ->join('orders', 'order_items.order_id', '=', 'orders.id')
                ->where('orders.status', 'delivered')
                ->where('orders.created_at', '>=', now()->subDays($period))
                ->groupBy('categories.id', 'categories.name')
                ->selectRaw('SUM(order_items.quantity) as total_sold')
                ->selectRaw('SUM(order_items.quantity * order_items.price) as total_revenue')
                ->orderBy('total_revenue', 'desc')
                ->get(),

            'top_authors' => User::select('users.name')
                ->where('users.role', 'author')
                ->join('books', 'users.id', '=', 'books.author_id')
                ->join('order_items', 'books.id', '=', 'order_items.book_id')
                ->join('orders', 'order_items.order_id', '=', 'orders.id')
                ->where('orders.status', 'delivered')
                ->where('orders.created_at', '>=', now()->subDays($period))
                ->groupBy('users.id', 'users.name')
                ->selectRaw('SUM(order_items.quantity) as books_sold')
                ->selectRaw('SUM(order_items.quantity * order_items.price) as total_earnings')
                ->orderBy('total_earnings', 'desc')
                ->limit(10)
                ->get(),
        ];

        return response()->json([
            'success' => true,
            'analytics' => $analytics
        ]);
    }
}
