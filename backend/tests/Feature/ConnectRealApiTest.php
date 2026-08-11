<?php

namespace Tests\Feature;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ConnectRealApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_and_fetch_only_their_conversations(): void
    {
        $user = User::factory()->create(['email' => 'user@example.com', 'password' => 'password123']);
        $other = User::factory()->create(['email' => 'other@example.com']);
        $conversation = Conversation::create(['type' => 'direct', 'title' => 'Private room', 'created_by' => $user->id]);
        $conversation->members()->sync([$user->id]);
        $hidden = Conversation::create(['type' => 'direct', 'title' => 'Hidden room', 'created_by' => $other->id]);
        $hidden->members()->sync([$other->id]);

        $login = $this->postJson('/api/v1/auth/login', ['email' => 'user@example.com', 'password' => 'password123']);
        $login->assertOk()->assertJsonStructure(['token', 'user']);

        $this->withHeader('Authorization', 'Bearer ' . $login->json('token'))
            ->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('data.0.title', 'Private room');
    }

    public function test_only_conversation_members_can_send_a_message(): void
    {
        $member = User::factory()->create();
        $stranger = User::factory()->create();
        $conversation = Conversation::create(['type' => 'group', 'title' => 'Team', 'created_by' => $member->id]);
        $conversation->members()->sync([$member->id]);

        $this->actingAs($stranger)
            ->postJson("/api/v1/conversations/{$conversation->id}/messages", ['body' => 'Not allowed'])
            ->assertForbidden();

        $this->actingAs($member)
            ->postJson("/api/v1/conversations/{$conversation->id}/messages", ['body' => 'Hello live room'])
            ->assertCreated()
            ->assertJsonPath('body', 'Hello live room');

        $this->assertDatabaseHas('messages', ['conversation_id' => $conversation->id, 'body' => 'Hello live room']);
        $this->assertCount(1, Message::where('conversation_id', $conversation->id)->get());
    }
}
