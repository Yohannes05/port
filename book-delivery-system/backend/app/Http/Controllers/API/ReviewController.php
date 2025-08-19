<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    public function index(Request $request)
    {
        $query = Review::with(['user', 'book']);

        // Filter by book
        if ($request->has('book_id')) {
            $query->where('book_id', $request->book_id);
        }

        // Filter by user (for user's own reviews)
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        $reviews = $query->orderBy('created_at', 'desc')->paginate(10);

        return response()->json([
            'success' => true,
            'reviews' => $reviews
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'book_id' => 'required|exists:books,id',
            'rating' => 'required|integer|between:1,5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check if user has already reviewed this book
        $existingReview = Review::where('user_id', $request->user()->id)
                               ->where('book_id', $request->book_id)
                               ->first();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => 'You have already reviewed this book'
            ], 400);
        }

        // Optionally check if user has purchased this book
        $hasPurchased = $request->user()
            ->orders()
            ->whereHas('orderItems', function($query) use ($request) {
                $query->where('book_id', $request->book_id);
            })
            ->exists();

        if (!$hasPurchased) {
            return response()->json([
                'success' => false,
                'message' => 'You can only review books you have purchased'
            ], 400);
        }

        $review = Review::create([
            'user_id' => $request->user()->id,
            'book_id' => $request->book_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        $review->load(['user', 'book']);

        return response()->json([
            'success' => true,
            'message' => 'Review created successfully',
            'review' => $review
        ], 201);
    }

    public function show(Review $review)
    {
        $review->load(['user', 'book']);

        return response()->json([
            'success' => true,
            'review' => $review
        ]);
    }

    public function update(Request $request, Review $review)
    {
        // Check if user owns this review
        if ($review->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to update this review'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|between:1,5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $review->update($request->only(['rating', 'comment']));
        $review->load(['user', 'book']);

        return response()->json([
            'success' => true,
            'message' => 'Review updated successfully',
            'review' => $review
        ]);
    }

    public function destroy(Request $request, Review $review)
    {
        // Check if user owns this review or is admin
        if ($review->user_id !== $request->user()->id && !$request->user()->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to delete this review'
            ], 403);
        }

        $review->delete();

        return response()->json([
            'success' => true,
            'message' => 'Review deleted successfully'
        ]);
    }
}
