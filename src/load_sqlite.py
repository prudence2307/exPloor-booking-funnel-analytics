"""Load project CSV files into a local SQLite database."""
from pathlib import Path
import sqlite3
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "exploor_analytics.db"

with sqlite3.connect(DB) as conn:
    conn.executescript((ROOT / "sql" / "schema.sql").read_text(encoding="utf-8"))
    for table in ["experiences", "bookings", "funnel_events"]:
        df = pd.read_csv(ROOT / "data" / f"{table}.csv")
        df.to_sql(table, conn, if_exists="append", index=False)
    counts = {
        table: conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        for table in ["experiences", "bookings", "funnel_events"]
    }
print(f"SQLite database created at {DB}")
print(counts)
