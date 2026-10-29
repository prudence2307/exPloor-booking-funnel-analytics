"""Validate synthetic ExPloor funnel data and export KPI tables."""
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUTPUT = ROOT / "output"
OUTPUT.mkdir(exist_ok=True)

events = pd.read_csv(DATA / "funnel_events.csv", parse_dates=["event_timestamp"])
bookings = pd.read_csv(DATA / "bookings.csv", parse_dates=["booking_created_at"])
experiences = pd.read_csv(DATA / "experiences.csv")

# Basic quality checks
assert events["event_id"].is_unique, "Duplicate event_id values found"
assert bookings["booking_id"].is_unique, "Duplicate booking_id values found"
assert events["session_id"].notna().all(), "Events missing session_id"
assert bookings["session_id"].notna().all(), "Bookings missing session_id"
assert bookings["booking_value_zar"].ge(0).all(), "Negative booking value found"
assert set(bookings["experience_id"]).issubset(set(experiences["experience_id"])), "Unknown experience_id"

# One row per session in each funnel stage (use distinct sessions, not event row counts)
stage_order = ["experience_viewed", "checkout_started", "booking_created", "payment_started", "payment_succeeded"]
stage_rows = []
all_sessions = events.loc[events.event_name == "experience_viewed", "session_id"].nunique()
previous_count = None
for stage in stage_order:
    count = events.loc[events.event_name == stage, "session_id"].nunique()
    stage_rows.append({
        "stage": stage,
        "sessions": int(count),
        "conversion_from_view": round(count / all_sessions, 4) if all_sessions else 0,
        "conversion_from_previous_stage": round(count / previous_count, 4) if previous_count else 1.0,
        "drop_off_from_previous_stage": int(previous_count - count) if previous_count is not None else 0
    })
    previous_count = count
funnel = pd.DataFrame(stage_rows)
funnel.to_csv(OUTPUT / "funnel_kpis.csv", index=False)

# Booking value metrics are NOT ExPloor platform revenue.
paid = bookings.loc[bookings.payment_status == "paid"]
value_summary = pd.DataFrame([{
    "bookings_created": int(bookings.booking_id.nunique()),
    "paid_bookings": int(paid.booking_id.nunique()),
    "paid_booking_rate": round(len(paid) / len(bookings), 4) if len(bookings) else 0,
    "total_booking_value_zar": round(bookings.booking_value_zar.sum(), 2),
    "paid_booking_value_zar": round(paid.booking_value_zar.sum(), 2),
    "average_booking_value_zar": round(bookings.booking_value_zar.mean(), 2) if len(bookings) else 0,
    "note": "Synthetic demonstration metrics; booking value is not platform revenue."
}])
value_summary.to_csv(OUTPUT / "booking_value_kpis.csv", index=False)

# Category and channel summaries
merged = bookings.merge(experiences[["experience_id","experience_name","category"]], on="experience_id", how="left")
category_summary = merged.groupby("category", dropna=False).agg(
    bookings=("booking_id","nunique"),
    booking_value_zar=("booking_value_zar","sum"),
    paid_bookings=("payment_status", lambda s: int((s == "paid").sum()))
).reset_index()
category_summary["paid_booking_rate"] = (category_summary["paid_bookings"] / category_summary["bookings"]).round(4)
category_summary.to_csv(OUTPUT / "category_summary.csv", index=False)

session_channels = events.loc[events.event_name=="experience_viewed", ["session_id","channel"]].drop_duplicates()
session_stages = events.pivot_table(index="session_id", columns="event_name", values="event_id", aggfunc="count", fill_value=0).reset_index()
for col in stage_order:
    if col not in session_stages:
        session_stages[col] = 0
    session_stages[col] = (session_stages[col] > 0).astype(int)
channel_summary = session_channels.merge(session_stages, on="session_id", how="left").groupby("channel").agg(
    viewed=("session_id","nunique"),
    checkout_started=("checkout_started","sum"),
    booking_created=("booking_created","sum"),
    payment_succeeded=("payment_succeeded","sum")
).reset_index()
channel_summary["view_to_checkout_rate"] = (channel_summary["checkout_started"] / channel_summary["viewed"]).round(4)
channel_summary["view_to_booking_rate"] = (channel_summary["booking_created"] / channel_summary["viewed"]).round(4)
channel_summary["view_to_paid_rate"] = (channel_summary["payment_succeeded"] / channel_summary["viewed"]).round(4)
channel_summary.to_csv(OUTPUT / "channel_summary.csv", index=False)

print("Validation passed.")
print(f"Sessions viewed: {all_sessions:,}")
print(f"Bookings created: {bookings.booking_id.nunique():,}")
print(f"Events: {len(events):,}")
print(f"Outputs written to: {OUTPUT}")
