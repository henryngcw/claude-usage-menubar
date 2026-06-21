# custom-swiftbar-widgets

Personal [SwiftBar](https://github.com/swiftbar/SwiftBar) plugins.

## `claude-usage.sh` — Claude subscription usage

Shows live Claude subscription usage in the menu bar — the same numbers
`/usage` reports, pulled from the OAuth usage endpoint:

- **🤖 42% · 3:15 PM** — current 5-hour (session) window usage + next reset
- Dropdown adds the weekly (7-day) window and its reset time

The access token is read from the macOS keychain (`Claude Code-credentials`).

### States

| Menu bar | Meaning |
|----------|---------|
| `🤖 42% · 3:15 PM` | normal — session usage + reset time |
| `🤖 inactive` | token expired / session timed out — re-login to Claude Code |
| `🤖 ?` | no token in keychain |
| `🤖 —` | usage endpoint unreachable |

### Why there's no polling interval

The filename is `claude-usage.sh` with **no** `.Nm.` refresh suffix on
purpose. SwiftBar therefore runs it once on load and never on a timer.

Each run is a network call to Anthropic's usage endpoint. Polling it on a
short interval (e.g. every minute) gets **rate-limited by Anthropic**, which
is exactly when you'd see the widget go blank or error. So instead of polling:

- A Claude Code **`Stop` hook** triggers a refresh via
  `swiftbar://refreshplugin?name=claude-usage.sh` after every completion.
- That means the number updates right when usage actually changes (when
  Claude does work) and makes **zero** background calls while idle.

Hook lives in `~/.claude/settings.json` under `hooks.Stop`.

### Install

1. Copy/symlink `claude-usage.sh` into your SwiftBar plugin folder.
2. Make it executable: `chmod +x claude-usage.sh`.
3. Refresh SwiftBar's plugin list (or restart SwiftBar) to pick it up.

> ⚠️ The OAuth usage endpoint is undocumented and may change. If it 401s,
> re-login to Claude Code; if it 404s, the path moved.
