# 🤖 Claude Usage Menu Bar

Live **Claude Code** subscription usage in your macOS menu bar — the same numbers `/usage` shows, always visible.

```
🤖 14% · 3:20 AM          ← session usage % · when it resets
─────────────────
Session (5h): 14%
  resets 3:20 AM
Weekly (7d): 17%
  resets Thu 11:00 AM
```

It refreshes every minute, so you can see how much of your limit is left without typing `/usage`.

## Why this exists

Claude Code shows usage only when you run `/usage`. This pins it to your menu bar. No API key, no config — it reads whoever is logged into Claude Code on this Mac and shows *their* usage.

## How it works

Claude meters two rolling windows (there is **no daily limit**):

- **Session (5h)** — the one that gates you minute-to-minute.
- **Weekly (7d)** — your longer-term cap.

The plugin reads your OAuth token from the macOS keychain and calls the same usage endpoint Claude Code uses internally, then renders the result. Reset times are shown in your local timezone.

## Requirements

- macOS
- [SwiftBar](https://github.com/swiftbar/SwiftBar) (`brew install --cask swiftbar`)
- [Claude Code](https://claude.com/claude-code) installed and **logged in** (Pro/Max subscription)

## Install

```sh
# 1. Install SwiftBar
brew install --cask swiftbar

# 2. Drop the plugin into your SwiftBar plugin folder
#    (SwiftBar asks you to pick this folder on first launch)
curl -fsSL https://raw.githubusercontent.com/henryngcw/claude-usage-menubar/main/claude-usage.1m.sh \
  -o "$HOME/swiftbar-plugins/claude-usage.1m.sh"
chmod +x "$HOME/swiftbar-plugins/claude-usage.1m.sh"
```

Then launch SwiftBar, point it at that folder (or click **Refresh All**). `🤖 14% · 3:20 AM` appears in your menu bar.

> Replace `$HOME/swiftbar-plugins` with whatever folder you told SwiftBar to use.

## Customize

- **Refresh rate** — rename the file: `claude-usage.30s.sh`, `.5m.sh`, etc. The number before the unit (`s`/`m`/`h`) is the interval.
- **Menu bar text** — edit the `print(f"🤖 ...")` line near the bottom of the script. Want both windows? Try `🤖 {fh_u:.0f}% · {sd_u:.0f}%`.
- **Icon** — swap the 🤖 for any emoji.

## Privacy

Your token never leaves your machine except to Anthropic's own usage endpoint (the same call Claude Code already makes). Nothing is stored, logged, or sent anywhere else. The script is ~40 lines — read it.

## Caveats

- Uses an **undocumented** endpoint Claude Code relies on internally. If it ever stops working: re-login to Claude Code (fixes auth), or open an issue (the path may have moved upstream).
- Subscription (Pro/Max) accounts only — this is the OAuth usage endpoint, not the pay-as-you-go API.

## License

MIT
