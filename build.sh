#!/bin/bash
# Regenerate files/resume.pdf from resume.html.
# The print rules live in the @media print block of style.css; the résumé is
# tuned to land on exactly one page. Re-run this after any résumé edit.
#
# Added 2026-08-26: this packet was NOT covered by the 8/25 lock sweep (which
# fixed portfolio-general and packet-anthropic only). Both its page and its
# separately-authored PDF served "Shira Goodman", "November 2025", "run by HUD",
# "nearly 3,000 cited cards" and "nearly seven years" for a month. Deriving the
# PDF from the page, with a guard, is the fix.
set -euo pipefail
cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="files/resume.pdf" "file://$PWD/resume.html" >/dev/null 2>&1

PAGES=$(~/DataLake/.venv/bin/python -c "import fitz;print(fitz.open('files/resume.pdf').page_count)")
echo "files/resume.pdf regenerated: ${PAGES} page(s)"
[ "$PAGES" = "1" ] || { echo "FAIL: résumé must be one page"; exit 1; }

# Lock guard: these strings must never reach the served PDF.
~/DataLake/.venv/bin/python - <<'PY'
import fitz, sys
t = "".join(p.get_text() for p in fitz.open("files/resume.pdf"))
banned = ["Shira Goodman", "November 2025", "Nov 2025", "run by HUD", "hackathon run by",
          "nearly 3,000", "nearly seven years", "head of global operations",
          "Senior Supply Chain Consultant", "Hacking Medicine"]
required = ["Oct 2025", "Y Combinator", "3,335", "Healthcare Hospitality Systems"]
hits = [b for b in banned if b in t]
missing = [r for r in required if r not in t]
if hits or missing:
    if hits:    print("FAIL: banned string(s) in PDF:", hits)
    if missing: print("FAIL: required string(s) missing from PDF:", missing)
    sys.exit(1)
print("lock guard: PASS")
PY
