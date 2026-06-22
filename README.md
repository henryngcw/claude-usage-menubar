# claude usage macos menubar

![](./claude-code-usage-menu-bar-example.png)

Personal [SwiftBar](https://github.com/swiftbar/SwiftBar) plugins.

## `claude-usage.5m.sh` — Claude subscription usage

Shows live Claude subscription usage in the menu bar — the same numbers
`/usage` reports, pulled from the OAuth usage endpoint:

- **🤖 42% · 3:15 PM** — current 5-hour (session) window usage + next reset
- Dropdown adds the weekly (7-day) window and its reset time

The access token is read from the macOS keychain (`Claude Code-credentials`).

### Installtion

1. Run `brew install --cask swiftbar`
2. Download `claude-usage.5m.sh` file and put in a folder where swiftbar will read it.
3. Done

### States

The menu bar always shows the robot, a percentage, and a reset time. When
usage data can't be fetched it falls back to `🤖 0% · idle`, and the dropdown
explains why and lists the steps to recover (sign in / wait out a rate-limit /
check the connection, then **Refresh**).

| Menu bar           | Meaning                                                              |
| ------------------ | -------------------------------------------------------------------- |
| `🤖 42% · 3:15 PM` | normal — session usage + reset time                                  |
| `🤖 0% · idle`     | no data — click it; the dropdown says why and how to fix it          |

### Claude Code only (not Claude Desktop)

This reads the **Claude Code** OAuth token from the keychain
(`Claude Code-credentials`), so you must have Claude Code installed and signed
in. The number it shows is account-wide subscription usage, so it already
covers usage from Claude Desktop, the web app, and anything else on the same
account — but it can't run off Desktop alone. Claude Desktop stores its session
encrypted behind the `Claude Safe Storage` keychain key rather than as a plain
bearer token, so there's no token to read there. Bottom line: keep Claude Code
signed in.

### Polling interval

The filename is `claude-usage.5m.sh`. SwiftBar reads the `.5m.` suffix and
refreshes the widget every 5 minutes.

You don't have to rename it by hand: click the menu bar → **Refresh interval**
and pick 2 / 3 / 5 / 10 / 30 min or 1 hour. That renames the script for you and
SwiftBar reschedules automatically (the current interval is marked with ✓).

Each run is a network call to Anthropic's usage endpoint. The endpoint
**rate-limits bursts** — calling it several times in quick succession returns
`{"error": {"type": "rate_limit_error"}}` instead of usage. One call every
5 minutes stays well clear of that. If you shorten the interval and start
seeing `🤖 0% · idle`, you're polling too fast; back off.

> ⚠️ The OAuth usage endpoint is undocumented and may change. If it 401s,
> re-login to Claude Code; if it 404s, the path moved.
