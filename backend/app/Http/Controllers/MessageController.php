<?php

namespace App\Http\Controllers;

use App\Events\MessageSent;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function index(Request $request, Conversation $conversation): JsonResponse
    {
        app(ConversationController::class)->authorizeMember($request, $conversation);
        $messages = $conversation->messages()
            ->with(['sender:id,name,avatar_url', 'replyTo.sender:id,name'])
            ->latest()
            ->paginate(min($request->integer('per_page', 30), 100));
        return response()->json($messages);
    }

    public function store(Request $request, Conversation $conversation): JsonResponse
    {
        app(ConversationController::class)->authorizeMember($request, $conversation);
        $data = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
            'message_type' => ['nullable', 'in:text,image,file,system'],
            'metadata' => ['nullable', 'array'],
            'reply_to_id' => ['nullable', 'integer', 'exists:messages,id'],
        ]);

        if (!empty($data['reply_to_id'])) {
            abort_unless($conversation->messages()->whereKey($data['reply_to_id'])->exists(), 422, 'Reply target is not in this conversation.');
        }

        $message = $conversation->messages()->create([
            'sender_id' => $request->user()->id,
            'body' => trim($data['body']),
            'message_type' => $data['message_type'] ?? 'text',
            'metadata' => $data['metadata'] ?? null,
            'reply_to_id' => $data['reply_to_id'] ?? null,
        ])->load(['sender:id,name,avatar_url', 'replyTo.sender:id,name']);

        $conversation->touch();
        broadcast(new MessageSent($message));
        return response()->json($message, 201);
    }

    public function update(Request $request, Message $message): JsonResponse
    {
        abort_unless($message->sender_id === $request->user()->id, 403);
        $data = $request->validate(['body' => ['required', 'string', 'max:5000']]);
        $message->update(['body' => trim($data['body']), 'edited_at' => now()]);
        return response()->json($message->fresh()->load('sender:id,name,avatar_url'));
    }

    public function destroy(Request $request, Message $message): JsonResponse
    {
        abort_unless($message->sender_id === $request->user()->id, 403);
        $message->delete();
        return response()->json(['message' => 'Message deleted.']);
    }
}
