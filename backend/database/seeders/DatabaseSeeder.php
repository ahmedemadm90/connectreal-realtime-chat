<?php

namespace Database\Seeders;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $ahmed = User::updateOrCreate(
            ['email' => 'ahmed@connectreal.test'],
            ['name' => 'Ahmed Emad', 'password' => Hash::make('password'), 'avatar_url' => null, 'last_seen_at' => now()]
        );
        $sara = User::updateOrCreate(
            ['email' => 'sara@connectreal.test'],
            ['name' => 'Sara Hassan', 'password' => Hash::make('password'), 'avatar_url' => null, 'last_seen_at' => now()->subMinutes(3)]
        );

        $conversation = Conversation::firstOrCreate(
            ['title' => 'Product Launch Room'],
            ['type' => 'group', 'created_by' => $ahmed->id]
        );
        $conversation->members()->syncWithoutDetaching([
            $ahmed->id => ['role' => 'admin'],
            $sara->id => ['role' => 'member'],
        ]);

        if ($conversation->messages()->doesntExist()) {
            Message::create([
                'conversation_id' => $conversation->id,
                'sender_id' => $sara->id,
                'body' => 'Welcome to ConnectReal. This message is persisted in the database.',
                'message_type' => 'text',
            ]);
            Message::create([
                'conversation_id' => $conversation->id,
                'sender_id' => $ahmed->id,
                'body' => 'And new messages are broadcast live over a private channel.',
                'message_type' => 'text',
            ]);
        }
    }
}
