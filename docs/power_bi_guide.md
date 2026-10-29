# Power BI Build Guide

## 1. Import
In Power BI Desktop, select **Get data → Text/CSV** and import:
- `data/experiences.csv`
- `data/funnel_events.csv`
- `data/bookings.csv`

Set timestamps to Date/Time, booking values and prices to Decimal Number, and identifiers/statuses to Text.

## 2. Model
Create relationships:
- `experiences[experience_id]` 1 → many `bookings[experience_id]`
- `experiences[experience_id]` 1 → many `funnel_events[experience_id]`

Do not directly join `bookings` to `funnel_events` by session in the Power BI model unless you deliberately model the many-to-many implications. Use the distinct session measures below for funnel analysis.

## 3. Suggested DAX measures
```DAX
Sessions Viewed =
CALCULATE(
    DISTINCTCOUNT(funnel_events[session_id]),
    funnel_events[event_name] = "experience_viewed"
)

Checkout Sessions =
CALCULATE(
    DISTINCTCOUNT(funnel_events[session_id]),
    funnel_events[event_name] = "checkout_started"
)

Booking Sessions =
CALCULATE(
    DISTINCTCOUNT(funnel_events[session_id]),
    funnel_events[event_name] = "booking_created"
)

Paid Sessions =
CALCULATE(
    DISTINCTCOUNT(funnel_events[session_id]),
    funnel_events[event_name] = "payment_succeeded"
)

View to Checkout % =
DIVIDE([Checkout Sessions], [Sessions Viewed], 0)

View to Booking % =
DIVIDE([Booking Sessions], [Sessions Viewed], 0)

View to Paid % =
DIVIDE([Paid Sessions], [Sessions Viewed], 0)

Bookings Created =
DISTINCTCOUNT(bookings[booking_id])

Paid Bookings =
CALCULATE(
    DISTINCTCOUNT(bookings[booking_id]),
    bookings[payment_status] = "paid"
)

Paid Booking Rate % =
DIVIDE([Paid Bookings], [Bookings Created], 0)

Total Booking Value ZAR =
SUM(bookings[booking_value_zar])

Paid Booking Value ZAR =
CALCULATE(
    SUM(bookings[booking_value_zar]),
    bookings[payment_status] = "paid"
)

Average Booking Value ZAR =
AVERAGE(bookings[booking_value_zar])
```
Format percentage measures as Percentage. Format booking value measures as Currency (South African Rand) or use a clear ZAR label.

## 4. Visual layout
- Top row: Sessions Viewed, Bookings Created, Paid Bookings, View to Paid %, Paid Booking Value ZAR.
- Left: funnel stage bar chart or funnel visual. Use a dedicated stage table if the visual requires stage order.
- Middle: View to Paid % by channel.
- Right: Paid Booking Value ZAR by category.
- Bottom: monthly bookings and paid booking value.
- Slicers: channel, category, booking status, payment status, booking month.

## 5. Interpretation safeguards
- The funnel uses session counts from event records; booking table totals may differ from session counts if a session can create multiple bookings in future versions.
- In this sample, one synthetic session creates at most one booking.
- Do not call booking value "ExPloor revenue." The platform revenue model is undecided.
- Label the report "Synthetic demonstration data".
