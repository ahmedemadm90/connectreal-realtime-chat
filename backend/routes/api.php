<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ConversationController;
use App\Http\Controllers\MessageController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::apiResource('conversations', ConversationController::class)->only(['index', 'store', 'show']);
        Route::get('conversations/{conversation}/messages', [MessageController::class, 'index']);
        Route::post('conversations/{conversation}/messages', [MessageController::class, 'store']);
        Route::post('conversations/{conversation}/read', [ConversationController::class, 'read']);
        Route::patch('messages/{message}', [MessageController::class, 'update']);
        Route::delete('messages/{message}', [MessageController::class, 'destroy']);
    });
});
