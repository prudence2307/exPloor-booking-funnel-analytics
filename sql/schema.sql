PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS funnel_events;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS experiences;

CREATE TABLE experiences (
    experience_id TEXT PRIMARY KEY,
    experience_name TEXT NOT NULL,
    category TEXT NOT NULL,
    city TEXT NOT NULL,
    base_price_zar REAL NOT NULL CHECK (base_price_zar >= 0),
    capacity INTEGER NOT NULL CHECK (capacity > 0)
);

CREATE TABLE bookings (
    booking_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    experience_id TEXT NOT NULL,
    booking_created_at TEXT NOT NULL,
    booking_status TEXT NOT NULL,
    payment_status TEXT NOT NULL,
    booking_value_zar REAL NOT NULL CHECK (booking_value_zar >= 0),
    is_synthetic INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (experience_id) REFERENCES experiences(experience_id)
);

CREATE TABLE funnel_events (
    event_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_timestamp TEXT NOT NULL,
    experience_id TEXT NOT NULL,
    channel TEXT NOT NULL,
    is_synthetic INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (experience_id) REFERENCES experiences(experience_id)
);

CREATE INDEX idx_events_name ON funnel_events(event_name);
CREATE INDEX idx_events_session ON funnel_events(session_id);
CREATE INDEX idx_bookings_experience ON bookings(experience_id);
CREATE INDEX idx_bookings_created_at ON bookings(booking_created_at);
