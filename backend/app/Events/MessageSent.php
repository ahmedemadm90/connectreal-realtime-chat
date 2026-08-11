<?php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcastNow
{
    use Dispatchable, SerializesModels;

    public function __construct(public Message $message)
    {
        $this->message->loadMissing('sender:id,name,avatar_url', 'replyTo.sender:id,name');
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel('conversation.' . $this->message->conversation_id)];
    }

    public function broadcastAs(): string
    {
        return 'message.sent';
    }

    public function broadcastWith(): array
    {
        return [
            'message' => [
                'id' => $this->message->id,
                'conversation_id' => $this->message->conversation_id,
                'body' => $this->message->body,
                'message_type' => $this->message->message_type,
                'metadata' => $this->message->metadata,
                'created_at' => $this->message->created_at?->toISOString(),
                'sender' => $this->message->sender,
                'reply_to' => $this->message->replyTo,
            ],
        ];
    }
}
