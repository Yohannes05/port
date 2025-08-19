<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::with(['user', 'orderItems.book', 'deliveryStaff']);

        // Filter based on user role
        if ($request->user()->isUser()) {
            $query->where('user_id', $request->user()->id);
        } elseif ($request->user()->isDeliveryStaff()) {
            $query->where('delivery_staff_id', $request->user()->id);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $orders = $query->orderBy('created_at', 'desc')->paginate(10);

        return response()->json([
            'success' => true,
            'orders' => $orders
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'address' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.book_id' => 'required|exists:books,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            $totalPrice = 0;
            $orderItems = [];

            // Validate stock and calculate total
            foreach ($request->items as $item) {
                $book = Book::find($item['book_id']);
                
                if (!$book->isApproved()) {
                    throw new \Exception("Book '{$book->title}' is not available");
                }

                if ($book->stock < $item['quantity']) {
                    throw new \Exception("Insufficient stock for book '{$book->title}'");
                }

                $itemTotal = $book->price * $item['quantity'];
                $totalPrice += $itemTotal;

                $orderItems[] = [
                    'book_id' => $book->id,
                    'quantity' => $item['quantity'],
                    'price' => $book->price,
                    'book' => $book
                ];
            }

            // Create order
            $order = Order::create([
                'user_id' => $request->user()->id,
                'total_price' => $totalPrice,
                'address' => $request->address,
                'status' => 'pending'
            ]);

            // Create order items and update stock
            foreach ($orderItems as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'book_id' => $item['book_id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price']
                ]);

                // Reduce stock
                $item['book']->decrement('stock', $item['quantity']);
            }

            DB::commit();

            $order->load(['orderItems.book', 'user']);

            return response()->json([
                'success' => true,
                'message' => 'Order created successfully',
                'order' => $order
            ], 201);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    public function show(Request $request, Order $order)
    {
        // Check authorization
        if (!$request->user()->isAdmin() && 
            $order->user_id !== $request->user()->id && 
            $order->delivery_staff_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $order->load(['user', 'orderItems.book', 'deliveryStaff']);

        return response()->json([
            'success' => true,
            'order' => $order
        ]);
    }

    public function updateStatus(Request $request, Order $order)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,processing,shipped,delivered,cancelled',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check authorization based on status change
        $newStatus = $request->status;
        $user = $request->user();

        if ($newStatus === 'cancelled' && !$user->isAdmin() && $order->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Only order owner or admin can cancel orders'
            ], 403);
        }

        if (in_array($newStatus, ['processing']) && !$user->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Only admin can update to this status'
            ], 403);
        }

        if (in_array($newStatus, ['shipped', 'delivered']) && !$user->isAdmin() && !$user->isDeliveryStaff()) {
            return response()->json([
                'success' => false,
                'message' => 'Only admin or delivery staff can update delivery status'
            ], 403);
        }

        // Update order status
        $updateData = ['status' => $newStatus];

        if ($newStatus === 'shipped') {
            $updateData['shipped_at'] = now();
        } elseif ($newStatus === 'delivered') {
            $updateData['delivered_at'] = now();
        }

        $order->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Order status updated successfully',
            'order' => $order
        ]);
    }

    public function assignDelivery(Request $request, Order $order)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'delivery_staff_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        // Verify the user is delivery staff
        $deliveryStaff = \App\Models\User::find($request->delivery_staff_id);
        if (!$deliveryStaff->isDeliveryStaff()) {
            return response()->json([
                'success' => false,
                'message' => 'Selected user is not delivery staff'
            ], 400);
        }

        $order->update([
            'delivery_staff_id' => $request->delivery_staff_id,
            'status' => 'processing'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Delivery staff assigned successfully',
            'order' => $order->load(['deliveryStaff'])
        ]);
    }
}
