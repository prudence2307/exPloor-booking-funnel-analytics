-- 1. Funnel conversion by stage.
-- Counts distinct sessions to avoid inflating counts if an event is duplicated.
WITH stages AS (
  SELECT 'experience_viewed' AS stage, 1 AS stage_order,
         COUNT(DISTINCT session_id) AS sessions
  FROM funnel_events WHERE event_name = 'experience_viewed'
  UNION ALL
  SELECT 'checkout_started', 2, COUNT(DISTINCT session_id)
  FROM funnel_events WHERE event_name = 'checkout_started'
  UNION ALL
  SELECT 'booking_created', 3, COUNT(DISTINCT session_id)
  FROM funnel_events WHERE event_name = 'booking_created'
  UNION ALL
  SELECT 'payment_started', 4, COUNT(DISTINCT session_id)
  FROM funnel_events WHERE event_name = 'payment_started'
  UNION ALL
  SELECT 'payment_succeeded', 5, COUNT(DISTINCT session_id)
  FROM funnel_events WHERE event_name = 'payment_succeeded'
)
SELECT stage, sessions,
       ROUND(100.0 * sessions / NULLIF(MAX(CASE WHEN stage_order=1 THEN sessions END) OVER (),0), 2)
         AS conversion_from_view_pct
FROM stages
ORDER BY stage_order;

-- 2. Booking and payment outcomes.
SELECT booking_status, payment_status,
       COUNT(*) AS bookings,
       ROUND(SUM(booking_value_zar), 2) AS booking_value_zar
FROM bookings
GROUP BY booking_status, payment_status
ORDER BY bookings DESC;

-- 3. Booking value and paid booking value by experience category.
-- These are marketplace booking-value metrics, not platform revenue.
SELECT e.category,
       COUNT(DISTINCT b.booking_id) AS bookings_created,
       SUM(CASE WHEN b.payment_status='paid' THEN 1 ELSE 0 END) AS paid_bookings,
       ROUND(SUM(b.booking_value_zar),2) AS total_booking_value_zar,
       ROUND(SUM(CASE WHEN b.payment_status='paid' THEN b.booking_value_zar ELSE 0 END),2)
         AS paid_booking_value_zar
FROM bookings b
JOIN experiences e ON e.experience_id=b.experience_id
GROUP BY e.category
ORDER BY total_booking_value_zar DESC;

-- 4. Funnel performance by acquisition channel.
WITH session_funnel AS (
  SELECT session_id, channel,
    MAX(CASE WHEN event_name='experience_viewed' THEN 1 ELSE 0 END) AS viewed,
    MAX(CASE WHEN event_name='checkout_started' THEN 1 ELSE 0 END) AS checkout_started,
    MAX(CASE WHEN event_name='booking_created' THEN 1 ELSE 0 END) AS booking_created,
    MAX(CASE WHEN event_name='payment_succeeded' THEN 1 ELSE 0 END) AS payment_succeeded
  FROM funnel_events
  GROUP BY session_id, channel
)
SELECT channel,
       SUM(viewed) AS viewed,
       SUM(checkout_started) AS checkout_started,
       SUM(booking_created) AS booking_created,
       SUM(payment_succeeded) AS payment_succeeded,
       ROUND(100.0 * SUM(checkout_started) / NULLIF(SUM(viewed),0),2) AS view_to_checkout_pct,
       ROUND(100.0 * SUM(booking_created) / NULLIF(SUM(viewed),0),2) AS view_to_booking_pct,
       ROUND(100.0 * SUM(payment_succeeded) / NULLIF(SUM(viewed),0),2) AS view_to_paid_pct
FROM session_funnel
GROUP BY channel
ORDER BY view_to_paid_pct DESC;

-- 5. Monthly booking value trend.
SELECT substr(booking_created_at,1,7) AS booking_month,
       COUNT(*) AS bookings_created,
       ROUND(SUM(booking_value_zar),2) AS booking_value_zar,
       ROUND(SUM(CASE WHEN payment_status='paid' THEN booking_value_zar ELSE 0 END),2)
         AS paid_booking_value_zar
FROM bookings
GROUP BY substr(booking_created_at,1,7)
ORDER BY booking_month;
