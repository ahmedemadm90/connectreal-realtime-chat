<?php

namespace App\Http\Controllers;

use App\Models\Conversation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ConversationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $conversations = $request->user()->memberships()
            ->with(['conversation.members:id,name,avatar_url,last_seen_at', 'conversation.messages' => fn ($query) => $query->latest()->limit(1)])
            ->latest('updated_at')
            ->get()
            ->pluck('conversation')
            ->filter()
            ->values();

        return response()->json(['data' => $conversations]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', 'in:direct,group'],
            'title' => ['nullable', 'string', 'max:120'],
            'member_ids' => ['required', 'array', 'min:1'],
            'member_ids.*' => ['integer', 'exists:users,id'],
        ]);

        $conversation = DB::transaction(function () use ($request, $data) {
            $conversation = Conversation::create([
                'type' => $data['type'],
                'title' => $data['title'] ?? null,
                'created_by' => $request->user()->id,
            ]);
            $members = collect($data['member_ids'])->push($request->user()->id)->unique();
            $conversation->members()->sync($members->mapWithKeys(fn ($id) => [$id => ['role' => $id === $request->user()->id ? 'admin' : 'member']])->all());
            return $conversation->load('members:id,name,avatar_url,last_seen_at');
        });

        return response()->json($conversation, 201);
    }

    public function show(Request $request, Conversation $conversation): JsonResponse
    {
        $this->authorizeMember($request, $conversation);
        return response()->json($conversation->load(['members:id,name,avatar_url,last_seen_at', 'messages' => fn ($query) => $query->with('sender:id,name,avatar_url')->latest()->limit(50)]));
    }

    public function read(Request $request, Conversation $conversation): JsonResponse
    {
        $membership = $this->authorizeMember($request, $conversation);
        $membership->update(['last_read_at' => now()]);
        return response()->json(['last_read_at' => $membership->fresh()->last_read_at]);
    }

    public function authorizeMember(Request $request, Conversation $conversation)
    {
        $membership = $conversation->memberships()->where('user_id', $request->user()->id)->first();
        abort_unless($membership, 403, 'You are not a member of this conversation.');
        return $membership;
    }
}
