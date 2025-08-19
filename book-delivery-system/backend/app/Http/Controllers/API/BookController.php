<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BookController extends Controller
{
    public function index(Request $request)
    {
        $query = Book::with(['author', 'category', 'reviews']);

        // Filter by status for public view
        if (!$request->user() || !$request->user()->isAdmin()) {
            $query->where('status', 'approved');
        }

        // Search functionality
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        // Filter by category
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Filter by author (for author's own books)
        if ($request->has('author_id')) {
            $query->where('author_id', $request->author_id);
        }

        // Sort options
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $books = $query->paginate(12);

        return response()->json([
            'success' => true,
            'books' => $books
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'image_url' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $book = Book::create([
            'title' => $request->title,
            'description' => $request->description,
            'author_id' => $request->user()->id,
            'price' => $request->price,
            'stock' => $request->stock,
            'category_id' => $request->category_id,
            'image_url' => $request->image_url,
            'status' => 'pending'
        ]);

        $book->load(['author', 'category']);

        return response()->json([
            'success' => true,
            'message' => 'Book created successfully',
            'book' => $book
        ], 201);
    }

    public function show(Book $book)
    {
        $book->load(['author', 'category', 'reviews.user']);

        return response()->json([
            'success' => true,
            'book' => $book
        ]);
    }

    public function update(Request $request, Book $book)
    {
        // Check if user can update this book
        if (!$request->user()->isAdmin() && $book->author_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to update this book'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'image_url' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $request->only(['title', 'description', 'price', 'stock', 'category_id', 'image_url']);
        
        // If not admin, reset status to pending when updated
        if (!$request->user()->isAdmin()) {
            $updateData['status'] = 'pending';
        }

        $book->update($updateData);
        $book->load(['author', 'category']);

        return response()->json([
            'success' => true,
            'message' => 'Book updated successfully',
            'book' => $book
        ]);
    }

    public function destroy(Request $request, Book $book)
    {
        // Check if user can delete this book
        if (!$request->user()->isAdmin() && $book->author_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to delete this book'
            ], 403);
        }

        // Check if book has orders
        if ($book->orderItems()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete book with existing orders'
            ], 400);
        }

        $book->delete();

        return response()->json([
            'success' => true,
            'message' => 'Book deleted successfully'
        ]);
    }

    public function updateStatus(Request $request, Book $book)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,approved,rejected',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $book->update(['status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Book status updated successfully',
            'book' => $book
        ]);
    }
}
