# Homebrew Tap for TokenLive

Install TokenLive all-in-one LLM gateway + admin console:

```bash
brew tap tokenlive/tokenlive
brew install tokenlive
brew services start tokenlive
```

Open http://127.0.0.1:2525 — login `admin` / `admin`

Config: `$(brew --prefix)/etc/tokenlive/config.yml`

## Uninstall

```bash
brew services stop tokenlive
brew uninstall tokenlive
brew untap tokenlive/tokenlive
```
