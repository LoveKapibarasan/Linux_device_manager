#!/usr/bin/env python3

import csv
import os
import json
from typing import Set, List, Tuple


WHITE_CSV = "/opt/white_list/white_list.csv"
BLOCK_CSV = "/opt/white_list/block_list.csv"

def extract_url(csv_path: str) -> Set[str]:
    domains = set()
    if not os.path.exists(csv_path):
        return domains
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        for row in reader:
            if not row:
                continue
            if row[0].startswith("#") or row[0].lower() in {"domain", "domains"}:
                continue
            for cell in row:
                cell = cell.strip().lower()
                if cell.startswith("http://") or cell.startswith("https://"):
                    cell = cell.split("/")[2]
                if cell and not cell.startswith("#"):
                    domains.add(cell.strip("."))
    return domains

