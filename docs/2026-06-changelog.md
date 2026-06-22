# Changelog — 2026-06

- **Refresh-interval picker** — menu bar → *Refresh interval* lets you pick
  2 / 3 / 5 / 10 / 30 min or 1 hour. Renames the script (`.5m.` → `.2m.` etc.)
  so SwiftBar reschedules; current interval marked with ✓.
- **Helpful idle state** — when usage data can't be fetched, the dropdown now
  explains why (not logged in / rate-limited / unreachable) and lists the
  steps to recover, instead of a single bare status line.
- **Docs** — README now notes this reads the *Claude Code* keychain token
  (not Claude Desktop), and that the % shown is account-wide.
- **Fix** — stray apostrophe in the renderer closed the `python3 -c '…'`
  block early, breaking the plugin (`?` in the menu bar); resolved.
