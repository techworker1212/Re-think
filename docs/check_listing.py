"""Checks docs/app-store-listing.md against App Store Connect character limits."""
import pathlib
import re
import sys

LIMITS = {
    "App name": 30,
    "Subtitle": 30,
    "Promotional text": 170,
    "Description": 4000,
    "Keywords": 100,
    "What's new in this version": 4000,
}

text = (pathlib.Path(__file__).parent / "app-store-listing.md").read_text()
sections = dict(
    (m.group(1).split(" (")[0].strip(), m.group(2).strip())
    for m in re.finditer(r"^## (.+?)\n(.*?)(?=^## |\Z)", text, re.S | re.M)
)

failed = False
for name, limit in LIMITS.items():
    body = sections[name]
    if name == "Keywords":
        body = body.split("\n\n")[0]
    count = len(body)
    ok = count <= limit
    failed |= not ok
    print(f"{'ok  ' if ok else 'OVER'} {name}: {count}/{limit}")

sys.exit(1 if failed else 0)
