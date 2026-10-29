# Data Dictionary

## experiences.csv
| Column | Type | Meaning |
|---|---|---|
| experience_id | text | Unique synthetic experience identifier |
| experience_name | text | Fictional experience name |
| category | text | Experience category |
| city | text | Fictional listing city |
| base_price_zar | decimal | Illustrative base price in ZAR |
| capacity | integer | Illustrative listing capacity |

## funnel_events.csv
| Column | Type | Meaning |
|---|---|---|
| event_id | text | Unique event identifier |
| session_id | text | Synthetic browsing session identifier |
| event_name | text | Stage event |
| event_timestamp | datetime | Synthetic event timestamp |
| experience_id | text | Related experience |
| channel | text | Synthetic acquisition channel |
| is_synthetic | boolean | Always true in this sample |

Event names: `experience_viewed`, `checkout_started`, `booking_created`, `payment_started`, `payment_succeeded`.

## bookings.csv
| Column | Type | Meaning |
|---|---|---|
| booking_id | text | Unique synthetic booking identifier |
| session_id | text | Session that created the booking |
| experience_id | text | Related experience |
| booking_created_at | datetime | Synthetic booking timestamp |
| booking_status | text | `pending`, `confirmed`, `completed`, `cancelled`, or `expired` |
| payment_status | text | `paid`, `failed`, `pending`, or `unpaid` |
| booking_value_zar | decimal | Synthetic booking value in ZAR |
| is_synthetic | boolean | Always true in this sample |

## Modelling notes
`session_id` links events and bookings. `experience_id` links events/bookings to the experience dimension. The dataset is intentionally simplified for learning and portfolio demonstration; it is not a complete production data model.
