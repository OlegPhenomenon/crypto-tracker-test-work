# Crypto Alert Service

A personal service for monitoring cryptocurrency prices and receiving notifications when user-defined thresholds are met. The application is built with Ruby on Rails and architected as a set of containerized services managed by Docker Compose, designed for scalability, resilience, and extensibility.

Project can be touch here: http://localhost:3000/notification_channels

---

## Architecture Overview

The system is composed of several independent services that communicate asynchronously via a Redis queue and a shared PostgreSQL database. This decoupled design ensures that the web interface remains responsive and that the real-time price processing is handled efficiently without blocking.

+-------+        +------------------+        +-------------+
| User  | -----> |  Web Service     | -----> | PostgreSQL  |
+-------+        |  (Rails App)     |        +-------------+
    ^            +------------------+                ^
    |                   |                           |
    |                   v                           |
    |           +------------------+                |
    |           |      Redis       | <---------------+
    |           +------------------+
    |                   ^
    |                   |
    |            +------------------+
    |            | Price Listener   |
    |            |   (Binance)      |
    |            +------------------+
    |                   |
    |                   v
    |            +------------------+
    |            | Background Worker|
    |            |    (Sidekiq)     |
    |            +------------------+
    |                   |
    |                   v
    |            +------------------+
    +------------| Notification     |
                 | Channels         |
                 | (Email, etc.)    |
                 +------------------+

-----

## Key Concepts & Design Patterns

### Extensible Notification Channels (STI)

The notification system is designed to be easily extensible using **Single Table Inheritance (STI)**.

  * A base `NotificationChannel` model stores all channel types in a single table.
  * The `type` column in the `notification_channels` table determines which subclass (e.g., `EmailChannel`, `TelegramChannel`, `LogChannel`) represents the record.
  * **To add a new notification method**, a developer simply needs to create a new class that inherits from `NotificationChannel` and implements a public `send_notification(alert)` method. The rest of the system, particularly the `NotificationJob`, will automatically be able to use it without modification due to polymorphism.

### High-Performance Trigger Matching (Redis)

To handle a potentially large number of active alerts without overwhelming the primary database, the system uses **Redis as a high-performance cache for alert triggers**.

  * When an `Alert` is created or activated, an `after_save` callback stores its trigger condition (symbol, price, direction) in a Redis Hash. The key is structured like `alerts:binance:BTCUSDT`.
  * The `PriceListener` service, upon receiving a new price, queries only Redis to find matching alerts. This is an extremely fast, in-memory operation that keeps the database free for transactional tasks.

### Asynchronous Processing (Sidekiq)

All notification deliveries are handled asynchronously by a **Sidekiq background worker**.

  * The `PriceListener`'s only job is to watch for triggers. When a trigger is matched, it enqueues a `NotificationJob` with the `alert_id`. It does not send the notification itself.
  * A separate `worker` container runs the Sidekiq process, which pulls jobs from the Redis queue and executes them. This ensures that the `PriceListener` is never blocked by slow API calls and can continue processing real-time price data without interruption.

### Real-time Frontend Updates (Action Cable)

The `PriceListener` broadcasts every price tick it receives using **Action Cable**, which pushes the data to connected web clients via WebSockets.

  * This is enabled by Redis Pub/Sub, which acts as a messaging bus between the backend `listener` container and the `web` container running the Action Cable server.
  * This allows for the creation of a real-time UI that displays live price updates without requiring the user to refresh the page.

-----

## Database Schema

The database consists of three main tables to manage alerts and their notification channels.

### `alerts` table

Stores the core alert data created by the user.

  * `symbol`, `threshold_price`, `direction`: Define the trigger condition.
  * `exchange`: The source of the price data (e.g., 'binance').
  * `status`: The current state of the alert (e.g., 'active', 'triggered').

### `notification_channels` table

Stores the different endpoints for sending notifications, using STI.

  * `title`: A user-defined name for the channel.
  * `type`: A special column for STI that stores the class name (e.g., `EmailChannel`).
  * `details` (jsonb): A flexible column to store configuration specific to each channel type, such as a `chat_id` for Telegram or an `email` address.

### `alert_notifications` table

A join table that creates the many-to-many relationship between `alerts` and `notification_channels`.