<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Fiction',
                'description' => 'Fictional books including novels, short stories, and fantasy'
            ],
            [
                'name' => 'Non-Fiction',
                'description' => 'Educational and informational books based on real facts'
            ],
            [
                'name' => 'Science',
                'description' => 'Books about scientific topics, research, and discoveries'
            ],
            [
                'name' => 'Technology',
                'description' => 'Books about programming, software development, and technology'
            ],
            [
                'name' => 'Business',
                'description' => 'Books about business, entrepreneurship, and management'
            ],
            [
                'name' => 'Self-Help',
                'description' => 'Books for personal development and self-improvement'
            ],
            [
                'name' => 'History',
                'description' => 'Books about historical events and periods'
            ],
            [
                'name' => 'Biography',
                'description' => 'Life stories of notable people'
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
