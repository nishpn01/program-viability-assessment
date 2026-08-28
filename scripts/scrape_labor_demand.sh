#!/usr/bin/env bash
# Labor-demand scrape (Phase 1a). RUN THIS IN YOUR OWN TERMINAL.
# Firecrawl works on your machine (it can't reach the internet from Claude's sandbox).
#
# Generated with AI assistance, as part of the Phase 1 data-collection pull
# (docs/ai-prompts-log.md, 1.3).
#
# Prereqs:
#   export FIRECRAWL_API_KEY=fc-...        # your key, do NOT commit it
#   (CLI optional; the script falls back to npx if `firecrawl` isn't installed)
#
# Run from the repo root:
#   bash scripts/scrape_labor_demand.sh
#
# Output: one markdown file per candidate in data/raw/labor_raw/.
# Those files land in the shared repo folder, so Claude can read them directly.

set -u

if [ -z "${FIRECRAWL_API_KEY:-}" ]; then
  echo "Set your key first:  export FIRECRAWL_API_KEY=fc-..."
  exit 1
fi

# Use installed CLI if present, else npx
FC="firecrawl"
command -v firecrawl >/dev/null 2>&1 || FC="npx -y firecrawl-cli@latest"

OUT="data/raw/labor_raw"
mkdir -p "$OUT"

# candidate_label | BLS Occupational Outlook Handbook URL (edit freely, add/remove lines)
ROWS=(
  "cybersecurity|https://www.bls.gov/ooh/computer-and-information-technology/information-security-analysts.htm"
  "business_analytics|https://www.bls.gov/ooh/business-and-financial/management-analysts.htm"
  "data_science|https://www.bls.gov/ooh/math/data-scientists.htm"
  "public_health|https://www.bls.gov/ooh/life-physical-and-social-science/epidemiologists.htm"
  "healthcare_admin|https://www.bls.gov/ooh/management/medical-and-health-services-managers.htm"
  "social_work|https://www.bls.gov/ooh/community-and-social-service/social-workers.htm"
  "finance|https://www.bls.gov/ooh/business-and-financial/financial-analysts.htm"
  "accounting|https://www.bls.gov/ooh/business-and-financial/accountants-and-auditors.htm"
  "marketing|https://www.bls.gov/ooh/business-and-financial/market-research-analysts.htm"
  "supply_chain|https://www.bls.gov/ooh/business-and-financial/logisticians.htm"
  "project_management|https://www.bls.gov/ooh/business-and-financial/project-management-specialists.htm"
  "public_administration|https://www.bls.gov/ooh/management/social-and-community-service-managers.htm"
)

for row in "${ROWS[@]}"; do
  label="${row%%|*}"
  url="${row##*|}"
  echo "-> $label"
  $FC scrape "$url" -o "$OUT/$label.md" || echo "   FAILED: $label ($url)"
done

echo "Done. Files in $OUT/. Tell Claude and it will parse them into labor_demand.csv"
