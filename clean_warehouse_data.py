#!/usr/bin/env python3
"""
Clean Raw Data/warehouse_messy_data.csv into Cleaned_Data/warehouse_cleaned_data.csv.

Usage:
    python clean_warehouse_data.py
    python clean_warehouse_data.py input.csv output.csv
"""

from pathlib import Path
import sys
import re
import pandas as pd

MISSING_TOKENS = {"", "nan", "none", "null", "n/a", "na", "-", "--"}


def normalize_column(col):
    col = str(col).strip().lower()
    col = re.sub(r"[^a-z0-9]+", "_", col)
    return col.strip("_")


def clean_warehouse_csv(input_file, output_file):
    df = pd.read_csv(input_file)

    # Normalize column names
    df.columns = [normalize_column(c) for c in df.columns]

    # Clean text and missing values
    for col in df.columns:
        if df[col].dtype == "object":
            df[col] = df[col].astype("string").str.strip()
            df[col] = df[col].replace(
                {token: pd.NA for token in MISSING_TOKENS},
                regex=False
            )

    # Convert mostly numeric columns to numbers
    for col in df.columns:
        if df[col].dtype == "object" or str(df[col].dtype) == "string":
            cleaned = (
                df[col].astype("string")
                .str.replace(",", "", regex=False)
                .str.replace("%", "", regex=False)
                .str.strip()
            )
            numeric = pd.to_numeric(cleaned, errors="coerce")
            non_missing = df[col].notna().sum()

            if non_missing > 0 and numeric.notna().sum() / non_missing >= 0.8:
                df[col] = numeric

    # Parse date/time columns
    for col in df.columns:
        if any(term in col for term in ("date", "time", "timestamp")):
            parsed = pd.to_datetime(df[col], errors="coerce", dayfirst=True)
            if parsed.notna().sum() > 0:
                df[col] = parsed.dt.strftime(
                    "%Y-%m-%d %H:%M:%S"
                ).replace("NaT", pd.NA)

    # Remove completely empty rows and columns
    df = df.dropna(axis=0, how="all")
    df = df.dropna(axis=1, how="all")

    # Remove exact duplicate rows
    df = df.drop_duplicates().reset_index(drop=True)

    # Save result
    df.to_csv(output_file, index=False)

    print("Cleaning completed successfully.")
    print(f"Rows after cleaning: {len(df)}")
    print(f"Columns after cleaning: {len(df.columns)}")
    print(f"Saved cleaned file: {Path(output_file).resolve()}")


if __name__ == "__main__":
    input_file = sys.argv[1] if len(sys.argv) > 1 else "Raw Data/warehouse_messy_data.csv"
    output_file = sys.argv[2] if len(sys.argv) > 2 else "Cleaned_Data/warehouse_cleaned_data.csv"
    clean_warehouse_csv(input_file, output_file)
