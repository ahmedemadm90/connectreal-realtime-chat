# ConnectReal Backend

This directory contains the working Laravel 13 API and Reverb broadcast server for ConnectReal.

## Local setup

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

Start real-time broadcasting separately:

```bash
php artisan reverb:start --host=0.0.0.0 --port=8080
```

## Main components

- `app/Models/Conversation.php`, `ConversationMember.php`, and `Message.php` define the chat domain.
- `app/Events/MessageSent.php` publishes message payloads to private conversation channels.
- `app/Http/Controllers/ConversationController.php` enforces membership and handles read receipts.
- `app/Http/Controllers/MessageController.php` handles message history, creation, edits, deletes, and broadcast dispatch.
- `routes/channels.php` authorizes `private-conversation.{id}` using the current Sanctum user.

Run the tests with:

```bash
php artisan test --compact
```
