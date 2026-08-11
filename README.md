# ConnectReal — Real-Time Chat Platform

ConnectReal is a working full-stack chat platform, not a mock repository. It includes a Laravel API with database-backed conversations and messages, Sanctum authentication, private broadcast channels, Laravel Reverb support, a Flutter mobile client, and automated tests for the core messaging flows.

## Architecture

```text
Flutter client
    ├── REST: authentication, conversations, message history, send, read receipt
    └── Pusher/Reverb WebSocket: private-conversation.{id} live events
                │
                ▼
Laravel 13 API + Sanctum + Reverb
    ├── SQLite/MySQL-compatible persistence
    ├── membership authorization for every conversation operation
    └── MessageSent event broadcast with sender and reply metadata
```

## Working capabilities

| Area | Implemented functionality |
|---|---|
| Identity | Register, login, token revocation, last-seen timestamp |
| Conversations | Create direct/group rooms, member pivots, member-only access, read receipts |
| Messages | Paginated history, send, edit, soft delete, reply references, metadata |
| Real-time | `MessageSent` broadcasts on `private-conversation.{id}` through Laravel Reverb |
| Mobile | Flutter conversation drawer, message bubbles, composer, connection state, live updates |
| Quality | Laravel feature tests and Flutter model tests/analyzer checks |

## Run the Laravel backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
# Keep SQLite for local development, then configure Reverb values from .env.example.
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

In a second terminal, start the WebSocket server:

```bash
cd backend
php artisan reverb:start --host=0.0.0.0 --port=8080
```

The seeded demo credentials are:

| User | Email | Password |
|---|---|---|
| Ahmed Emad | `ahmed@connectreal.test` | `password` |
| Sara Hassan | `sara@connectreal.test` | `password` |

For production, replace the demo Reverb key/secret and run the server behind HTTPS/WSS.

## Run the Flutter client

Install Flutter 3.24 or newer, then:

```bash
cd frontend
flutter pub get
flutter test
flutter analyze
flutter run
```

The client is configured for an Android emulator by default (`10.0.2.2`). If you run on a physical device or iOS simulator, update the API and WebSocket host in `frontend/lib/services/chat_api_service.dart`.

On launch, the demo client logs in with the seeded Ahmed account, loads the `Product Launch Room`, fetches recent messages, authenticates the private channel through `/api/broadcasting/auth`, and subscribes to `message.sent` events.

## API surface

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Issue a Sanctum token |
| `GET` | `/api/v1/conversations` | List conversations for the current user |
| `GET` | `/api/v1/conversations/{id}/messages` | Load paginated message history |
| `POST` | `/api/v1/conversations/{id}/messages` | Persist and broadcast a message |
| `POST` | `/api/v1/conversations/{id}/read` | Update the member read timestamp |
| `PATCH` | `/api/v1/messages/{id}` | Edit a message owned by the current user |
| `DELETE` | `/api/v1/messages/{id}` | Soft-delete a message owned by the current user |
| `POST` | `/api/broadcasting/auth` | Authorize an authenticated private channel |

## Tests

```bash
cd backend
php artisan test --compact

cd ../frontend
flutter test
flutter analyze
```

## Repository layout

```text
backend/
├── app/Events/MessageSent.php
├── app/Http/Controllers/        Auth, conversations, and messages
├── app/Models/                  User, conversation, membership, and message
├── database/migrations/         Chat schema and profile fields
├── database/seeders/            Two demo users, room, and messages
├── routes/api.php               Versioned REST API
├── routes/channels.php          Private channel authorization
└── tests/Feature/               Authentication and membership tests
frontend/
├── lib/models/                  Chat domain models
├── lib/providers/               REST + WebSocket state management
├── lib/services/                HTTP and Reverb/Pusher client
├── lib/views/                   Chat screen and message UI
└── test/                        JSON parsing tests
```

## Author

Ahmed Emad — Backend, Mobile, and Automation Developer.
