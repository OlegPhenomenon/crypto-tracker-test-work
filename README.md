# Crypto Alert Service Architecture

This document outlines the architecture of the personal crypto-alert service. The system is designed to be scalable, extensible, and efficient, leveraging professional design patterns and tools.

---

## 1. Data Models (PostgreSQL)

The core data is stored in a PostgreSQL database, structured around three main tables:

* **`alerts`**: Stores the user-defined alert conditions.
    * `exchange` (string): The exchange the alert is for (e.g., 'binance').
    * `symbol` (string): The trading pair (e.g., 'BTCUSDT').
    * `threshold_price` (decimal): The price at which the alert triggers.
    * `direction` (string): The trigger direction ('up' or 'down').
    * `status` (string): The current state ('active' or 'triggered').
* **`notification_channels`**: Manages the various methods for sending notifications. This table uses **Single Table Inheritance (STI)** for extensibility.
    * `type` (string): Stores the class name (e.g., `EmailChannel`, `TelegramChannel`), allowing for different logic for each channel type.
    * `details` (jsonb): A flexible field to store channel-specific configuration, like an email address or a Telegram chat ID.
* **`alert_notifications`**: A join table that creates a **many-to-many relationship** between alerts and notification channels, allowing one alert to notify multiple channels and one channel to be used for multiple alerts.

---

## 2. Real-time Processing (Redis)

To handle a high volume of real-time price data without overwhelming the main database, the system uses **Redis** as a high-speed, in-memory cache for active alerts.

* **Structure**: Active alerts are stored in Redis **Hashes**. The key is structured as `alerts:<exchange>:<symbol>` (e.g., `alerts:binance:BTCUSDT`).
* **Workflow**: When a new price is received, the application makes a single, fast query to Redis to get all relevant alerts for that specific symbol. This avoids slow database queries in the real-time processing loop.
* **Synchronization**: The `Alert` model uses `after_save` and `after_destroy` callbacks to automatically keep the Redis cache in sync with the PostgreSQL database.

---

## 3. Price Ingestion Service

Price data is ingested by a **standalone, long-running service** (`PriceListener`) that connects to exchange WebSockets.

* **Design Pattern**: The service is built using the **Strategy Pattern**. A base `ExchangeListener` class defines a common interface, and specific classes (`Binance::PriceListener`, etc.) implement the connection and message parsing logic for each exchange.
* **Extensibility**: Adding a new exchange is as simple as creating a new listener class that adheres to the established interface.
* **Decoupling**: The service runs as a separate process from the main Rails web application, ensuring that the web UI remains responsive regardless of the load on the price listener.

---

## 4. Notification System

When an alert is triggered, a background job (`NotificationJob`) is enqueued to handle the notifications.

* **Polymorphism**: The system leverages Ruby's polymorphic capabilities. The job iterates through the alert's associated `NotificationChannel` objects and calls a single, common method: `send_notification(alert)`.
* **Extensibility**: Each channel subclass (e.g., `EmailChannel`, `LogChannel`) implements its own version of the `send_notification` method. To add a new notification method (like SMS), a developer only needs to create a new `SmsChannel` class with its own `send_notification` logic. No other part of the system needs to be changed.