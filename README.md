# HostsGuard

> A modular, cron-enforced website blocker — add a `.txt` file to block a new site.

HostsGuard redirects distracting domains to `localhost` via `/etc/hosts` and uses a cron job to re-apply the rules every 10 minutes, so they stay in place even if manually removed.

## How it works

- **`blockSites.sh`** — interactive script that lets you pick which sites to block. Reads domain lists from the `domains/` directory and adds `127.0.0.1` / `::1` entries to `/etc/hosts`. Saves your selection to `.selected_sites` so cron knows what to re-enforce.
- **`addCronJob.sh`** — registers `blockSites.sh` as a cron job that runs every 10 minutes. When invoked by cron (no TTY), the script skips the menu and reads `.selected_sites` instead.
- **`domains/`** — one `.txt` file per site. Each line is a hostname to block. Add a new file to block a new site — no script changes needed.
- **`.selected_sites`** — auto-generated file that stores your last selection. Not committed to git (local state only).

### Included sites

| File | Blocks |
|------|--------|
| `domains/youtube.txt` | YouTube and related Google video domains |
| `domains/reddit.txt` | Reddit and short-link domains |
| `domains/hackernews.txt` | news.ycombinator.com |

## Changing which sites are blocked

Re-run `blockSites.sh` manually and pick a new selection — it overwrites `.selected_sites` and cron will follow the new choice from the next tick onwards.

```bash
sudo ./blockSites.sh
```

## Temporary override

Delete the relevant entries from `/etc/hosts` to unblock a site until the next 10-minute cron tick. If you're using Chrome, you may need to flush its DNS cache manually:

- Clear DNS: `chrome://net-internals/#dns`
- Flush sockets: `chrome://net-internals/#sockets`

([Why?](https://superuser.com/questions/203674/how-to-clear-flush-the-dns-cache-in-google-chrome#comment207196_203702))

## Setup

1. Clone the repo
2. Run `addCronJob.sh` with sudo — it auto-detects its own path, no edits needed:
   ```bash
   sudo ./addCronJob.sh
   ```
3. To block sites immediately (without waiting for cron):
   ```bash
   sudo ./blockSites.sh
   ```

> **Note:** `sudo` is required because `/etc/hosts` is a privileged file. The cron job should be added to sudo's crontab via `sudo crontab -e`.

## Adding a new site to block

Create a file under `domains/`, one hostname per line:

```
# my-site.txt
my-site.com
www.my-site.com
```

It will appear in the `blockSites.sh` menu automatically.
