# ExPloor Booking Funnel & Revenue Analytics

**Portfolio project using synthetic data.** This project demonstrates how a Business Analyst / BI Analyst can evaluate a marketplace booking funnel, payment outcomes, booking value, and acquisition channels. It does not report actual ExPloor performance.

## Business question
Where do prospective customers leave the booking journey, and how do booking and payment outcomes vary by channel and experience category?

## Tools
- Python and pandas for data quality checks and KPI exports
- SQLite and SQL for analysis
- Power BI for dashboard design
- Git/GitHub for reproducible documentation

## Data
- `data/experiences.csv`: six fictional marketplace experiences
- `data/funnel_events.csv`: synthetic customer journey events
- `data/bookings.csv`: synthetic bookings and payment outcomes

All records are synthetic and generated with a fixed random seed. They are not customer records and must not be described as actual platform performance.

## Run locally
```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
# source .venv/bin/activate
pip install -r requirements.txt
python src/analyze_funnel.py
```

## SQL setup
Use SQLite. Create a database named `exploor_analytics.db`, run `sql/schema.sql`, import the three CSV files into tables with matching names (`experiences`, `bookings`, `funnel_events`), then run queries from `sql/analysis_queries.sql`.

One simple route is DB Browser for SQLite: create/open the database, execute `schema.sql`, then use its CSV import function to import each CSV into the matching table. If you use an import tool that creates tables automatically, ensure the column names and types match the schema.

## KPI definitions
- **View-to-checkout rate** = distinct sessions with `checkout_started` / distinct sessions with `experience_viewed`.
- **View-to-booking rate** = distinct sessions with `booking_created` / distinct sessions with `experience_viewed`.
- **View-to-paid rate** = distinct sessions with `payment_succeeded` / distinct sessions with `experience_viewed`.
- **Paid booking rate** = bookings with `payment_status = paid` / all created bookings.
- **Booking value** = sum of the listed value for created bookings, regardless of payment status.
- **Paid booking value** = sum of booking value for bookings whose synthetic payment status is `paid`.
- **Average booking value** = average value across created bookings.

**Important:** Booking value / paid booking value is not the same as ExPloor's revenue. The platform's monetisation model is undecided, so this project does not claim platform revenue or commission income.

## Power BI dashboard plan
Create a report with:
1. KPI cards: sessions viewed, bookings created, paid bookings, view-to-paid rate, paid booking value (ZAR).
2. Funnel visual: viewed → checkout started → booking created → payment succeeded.
3. Bar chart: view-to-paid rate by channel.
4. Bar chart: paid booking value by experience category.
5. Line chart: bookings and paid booking value by month.
6. Slicers: channel, category, booking status, payment status, month.

Use distinct session counts for funnel stages. Do not sum event rows as if they were unique visitors.

## Limitations
- Synthetic data cannot establish real customer behaviour, seasonality, or business performance.
- Event tracking is assumed to be complete for the generated dataset; real event pipelines often contain missing or duplicated events.
- The simplified booking table stores one booking value per booking and does not model discounts, refunds, taxes, provider payouts, or platform fees.
- No platform revenue is calculated because the revenue model has not been selected.
- Booking status and payment status are separate fields and should not be treated as interchangeable.

## Next steps
1. Validate the code and KPI definitions.
2. Build the Power BI report.
3. Add screenshots and a short findings document.
4. Replace synthetic data only if suitable real data becomes available and can be safely anonymised.

### Optional: build the SQLite database using Python

```bash
python src/load_sqlite.py
```

This creates a local `exploor_analytics.db` file (ignored by Git) and loads the CSV data into it.
