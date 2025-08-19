<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        // Create sample author
        User::create([
            'name' => 'John Author',
            'email' => 'author@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'author',
        ]);

        // Create sample delivery staff
        User::create([
            'name' => 'Delivery Staff',
            'email' => 'delivery@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'delivery',
        ]);

        // Create sample user
        User::create([
            'name' => 'Regular User',
            'email' => 'user@bookdelivery.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
        ]);
    }
}
