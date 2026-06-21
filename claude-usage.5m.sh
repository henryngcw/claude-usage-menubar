#!/bin/bash
# Claude Code usage in your macOS menu bar — a SwiftBar plugin.
# Shows your live subscription usage % and next reset time (same data as /usage).
#
# Requirements: macOS, SwiftBar, and Claude Code installed + logged in.
# No setup, no API key: the token is read live from your macOS keychain, so it
# always reflects whoever is logged into Claude Code on this machine.
#
# Claude meters a 5-hour (session) window and a 7-day (weekly) window — there is
# no literal "daily" limit, so "Session (5h)" is the day-to-day one.
# The ".1m." in the filename = refresh every minute. Rename to .30s./.5m./etc to taste.
#
# Note: this calls an undocumented endpoint that Claude Code uses internally.
# If it ever 401s, re-login to Claude Code; if it 404s, the path moved upstream.

export PATH="/usr/bin:/bin:$PATH"

# Read the OAuth token from the keychain (service name is the same for every user).
TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
  | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin)["claudeAiOauth"]["accessToken"])' 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "🤖 ?"; echo "---"; echo "Not logged in — open Claude Code and sign in"; exit 0
fi

BODY=$(curl -s --max-time 8 \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "anthropic-version: 2023-06-01" \
  "https://api.anthropic.com/api/oauth/usage")

echo "$BODY" | /usr/bin/python3 -c '
import json, sys
from datetime import datetime

try:
    d = json.load(sys.stdin)
except Exception:
    print("🤖 —"); print("---"); print("Usage endpoint unreachable"); sys.exit()

def reset(s, fmt):
    try:
        dt = datetime.fromisoformat(s).astimezone()   # -> local time
        return dt.strftime(fmt).replace(" 0", " ").lstrip("0")
    except Exception:
        return "?"

fh, sd = d.get("five_hour") or {}, d.get("seven_day") or {}
fh_u, sd_u = fh.get("utilization", 0), sd.get("utilization", 0)
fh_r = reset(fh.get("resets_at", ""), "%I:%M %p")
sd_r = reset(sd.get("resets_at", ""), "%a %I:%M %p")

print(f"🤖 {fh_u:.0f}% · {fh_r}")      # menu bar: session % · next reset
print("---")
print(f"Session (5h): {fh_u:.0f}%")
print(f"  resets {fh_r} | size=11")
print(f"Weekly (7d): {sd_u:.0f}%")
print(f"  resets {sd_r} | size=11")
print("---")
print("Refresh | refresh=true")
'
