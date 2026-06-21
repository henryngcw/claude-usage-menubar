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
# The ".5m." in the filename = refresh every 5 minutes. Rename to .30s./.1m./etc to taste.
#
# Note: this calls an undocumented endpoint that Claude Code uses internally.
# If it ever 401s, re-login to Claude Code; if it 404s, the path moved upstream.

export PATH="/usr/bin:/bin:$PATH"

# Read the OAuth token from the keychain (service name is the same for every user).
TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
  | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin)["claudeAiOauth"]["accessToken"])' 2>/dev/null)

# No token → empty body. Everything funnels through the same renderer below,
# which always shows the robot + 0% + "idle" when data is missing.
BODY=""
export STATUS="Not logged in — open Claude Code and sign in"
if [ -n "$TOKEN" ]; then
  STATUS="Usage endpoint unreachable"
  BODY=$(curl -s --max-time 8 \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "anthropic-version: 2023-06-01" \
    "https://api.anthropic.com/api/oauth/usage")
fi

echo "$BODY" | /usr/bin/python3 -c '
import json, os, sys
from datetime import datetime

# Parse whatever we got. Anything missing or an error reply -> no usage data,
# and we fall back to a single, consistent "0% · idle" UI.
status = os.environ.get("STATUS", "No usage data")
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
if not isinstance(d, dict) or "error" in d:
    status = (d.get("error") or {}).get("message", status) if isinstance(d, dict) else status
    d = {}

def reset(s, fmt):
    try:
        dt = datetime.fromisoformat(s).astimezone()   # -> local time
        return dt.strftime(fmt).replace(" 0", " ").lstrip("0")
    except Exception:
        return "idle"

fh, sd = d.get("five_hour") or {}, d.get("seven_day") or {}
fh_u, sd_u = fh.get("utilization", 0), sd.get("utilization", 0)
fh_r = reset(fh.get("resets_at", ""), "%I:%M %p")
sd_r = reset(sd.get("resets_at", ""), "%a %I:%M %p")

print(f"🤖 {fh_u:.0f}% · {fh_r}")      # menu bar: session % · next reset
print("---")
if not d:
    print(status)
    print("---")
print(f"Session (5h): {fh_u:.0f}%")
print(f"  resets {fh_r} | size=11")
print(f"Weekly (7d): {sd_u:.0f}%")
print(f"  resets {sd_r} | size=11")
print("---")
print("Refresh | refresh=true")
'
