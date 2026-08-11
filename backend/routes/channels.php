<?php

use App\Models\Conversation;
use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('conversation.{conversation}', function (User $user, Conversation $conversation) {
    return $conversation->members()->whereKey($user->id)->exists();
});
