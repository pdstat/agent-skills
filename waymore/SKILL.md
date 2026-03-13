---
name: waymore
description: Expert guidance for waymore archived URL and response discovery during penetration testing, including multi-source URL retrieval, response downloading, filtering, and integration with xnLinkFinder and other recon tools
---

# Waymore Skill

## Overview
Waymore is a Python 3 reconnaissance tool that discovers archived URLs and downloads archived responses from multiple sources. It surpasses waybackurls and gau by retrieving from more sources and downloading actual archived responses for deeper analysis. The tool is designed for coverage, not speed.

### Data Sources
- Wayback Machine (web.archive.org)
- Common Crawl (index.commoncrawl.org)
- Alien Vault OTX (otx.alienvault.com)
- URLScan (urlscan.io)
- VirusTotal (virustotal.com)
- GhostArchive (ghostarchive.org)
- Intelligence X (intelx.io) — academia/paid tiers only

## Installation
```bash
# pip
pip install waymore

# From GitHub
pip install git+https://github.com/xnl-h4ck3r/waymore.git -v

# Upgrade
pip install --upgrade waymore

# pipx (isolated)
pipx install git+https://github.com/xnl-h4ck3r/waymore.git

# Docker
git clone https://github.com/xnl-h4ck3r/waymore.git
cd waymore
docker build -t waymore .
```

## Core Concepts

### Modes
- **`U`** — URLs only: retrieves deduplicated URLs from all sources
- **`R`** — Responses only: downloads archived responses
- **`B`** — Both URLs and responses (default for domain-only input)

Domain+path input defaults to mode `R` and cannot be forced to `U` or `B`.

### Input Handling
- Scheme, port, query string, and URL fragment are automatically stripped
- TLD-only search: prefix with period (e.g., `.mil`)
- **Do NOT pass a file of subdomains** — pass the root domain only; it retrieves all subdomains automatically and is much faster

### Output Structure
```
~/.config/waymore/results/
└── target.com/
    ├── waymore.txt          # Deduplicated URLs (mode U/B)
    ├── index.txt            # CSV: hash,archive_url,timestamp (mode R/B)
    ├── 7960113391501.html   # Response files (mode R/B)
    ├── responses.tmp        # All response URLs to retrieve
    └── continueResp.tmp     # Resume tracking for interrupted runs
```

## Command Line Arguments

### Input/Output
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-i` | `--input` | Target domain, file of domains, or domain with path |
| `-mode` | | Mode: `U` (URLs), `R` (Responses), `B` (Both) |
| `-oU` | `--output-urls` | URL output file path (default: results dir) |
| `-oR` | `--output-responses` | Response output directory (default: results dir) |
| `-ow` | `--output-overwrite` | Overwrite existing URL file instead of appending |
| `-nlf` | `--new-links-file` | Create `.new` suffix file with only latest run links (mode U) |

### Filtering
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-n` | `--no-subs` | Exclude subdomains; target domain only |
| `-f` | `--filter-responses-only` | Apply filters to downloaded responses only, not initial links |
| `-fc` | | Exclude these HTTP status codes (comma-separated; overrides config) |
| `-ft` | | Exclude these MIME types (comma-separated; overrides config) |
| `-mc` | | Only match these HTTP status codes (overrides `-fc` and config) |
| `-mt` | | Only match these MIME types (overrides `-ft` and config) |
| `-ko` | `--keywords-only` | Return only links/responses containing keywords (config or regex) |
| `-ra` | `--regex-after` | Regex filter against all found links and responses |

### Response Retrieval
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-l` | `--limit` | Responses to save: positive=first N, negative=last N, 0=ALL (default: 5000) |
| `-from` | `--from-date` | Start date (partial OK: 2016, 201805) |
| `-to` | `--to-date` | End date (partial OK) |
| `-ci` | `--capture-interval` | Archive.org dedup filter: `h`/`d`/`m`/`none` (default: `d`) |
| `-t` | `--timeout` | Seconds to wait for archived response (default: 30) |
| `-url-filename` | | Use URL as filename instead of hash |

### Source Control
| Flag | Purpose |
|------|---------|
| `-xwm` | Exclude Wayback Machine |
| `-xcc` | Exclude Common Crawl |
| `-xav` | Exclude Alien Vault OTX |
| `-xus` | Exclude URLScan |
| `-xvt` | Exclude VirusTotal |
| `-xix` | Exclude Intelligence X |
| `-xga` | Exclude GhostArchive |
| `-lcc` | Limit Common Crawl collections (default: 1; 0=ALL; ~106 total) |

### Rate Limiting & Performance
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-wrlr` | `--wayback-rate-limit-retry` | Minutes to wait on Wayback rate limit (default: 3) |
| `-urlr` | `--urlscan-rate-limit-retry` | Minutes to wait on URLScan rate limit (default: 1) |
| `-lr` | `--limit-requests` | Max requests per source (default: 0 = unlimited) |
| `-p` | `--processes` | Thread count (default: 2; keep low for reliability) |
| `-r` | `--retries` | Retry attempts for errors (default: 1) |
| `-m` | `--memory-threshold` | Memory percentage threshold for graceful stop (default: 95) |

### Configuration & Utility
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-c` | `--config` | Path to config.yml (default: ~/.config/waymore/config.yml) |
| `-sip` | `--source-ip` | Bind requests to specific source IP |
| `-co` | `--check-only` | Estimate requests/time without executing |
| `-nd` | `--notify-discord` | Send Discord notification on completion |
| `-nt` | `--notify-telegram` | Send Telegram notification on completion |
| `-oijs` | `--output-inline-js` | Combine inline JS from responses into files (1000/file) |
| `--stream` | | Output URLs to STDOUT as found (mode U only; dupes shown) |
| `-v` | `--verbose` | Verbose output |
| `--version` | | Show version |
| `-h` | `--help` | Show help |

## Common Use Cases

### 1. Basic URL Retrieval
```bash
waymore -i target.com -mode U
```

### 2. Full Run (URLs + Responses)
```bash
waymore -i target.com -mode B
```

### 3. Filtered Responses from Wayback Only
```bash
waymore -i target.com -xcc -xav -xus -xvt -f -l 200 -from 2022
```

### 4. JavaScript Responses Only
```bash
waymore -i target.com -ko "\.js(\?.*|$)" -l -20000 -from 2015 -to 201801
```

### 5. Status Code Matching
```bash
waymore -i target.com -mc 200,403
```

### 6. Check Estimate Before Running
```bash
waymore -i target.com --check-only
```

### 7. Piping to Other Tools
```bash
waymore -i target.com -mode U | unfurl keys | sort -u
```

### 8. Stdin Input
```bash
cat domains.txt | waymore
```

### 9. Stream Output
```bash
waymore -i target.com -mode U --stream
```

### 10. Docker Execution
```bash
docker run -it --rm -v $PWD/results:/app/results waymore:latest \
  -i example.com -oU example.com.links -oR results/example.com/
```

### 11. Domain with Specific Path
```bash
waymore -i target.com/robots.txt
```

### 12. TLD-Only Search
```bash
waymore -i .mil -mode U
```

### 13. Extract Inline JS from Responses
```bash
waymore -i target.com -mode R -oijs
```

### 14. Rate-Limited with Retries
```bash
waymore -i target.com -lr 500 -r 3 -wrlr 5
```

## Integration with Other Tools

### xnLinkFinder (Primary Integration)
Extract additional endpoints from downloaded responses:
```bash
waymore -i target.com -mode B
xnLinkFinder -i ~/.config/waymore/results/target.com \
  -sp https://target.com -sf target.* -d 5 -u desktop mobile \
  -o links.txt -op params.txt -owl wordlist.txt
```

### trufflehog (Secret Detection)
```bash
trufflehog filesystem ~/.config/waymore/results/target.com
```

### gf (Pattern Matching)
```bash
gf urls ~/.config/waymore/results/target.com/*
```

### unfurl (URL Analysis)
```bash
waymore -i target.com -mode U | unfurl keys | sort -u
```

## Configuration (config.yml)

Default location: `~/.config/waymore/config.yml`

If config exists, updates create `config.yml.NEW` instead of overwriting.

| Key | Purpose |
|-----|---------|
| `FILTER_CODE` | HTTP status codes to exclude (e.g., `301,302`) |
| `FILTER_MIME` | MIME types to exclude (e.g., `text/css,image/jpeg`) |
| `FILTER_URL` | URL patterns to exclude (handles `unk`/`unknown` MIME) |
| `FILTER_KEYWORDS` | Keywords for `-ko` without explicit value |
| `URLSCAN_API_KEY` | Free key from urlscan.io for higher limits |
| `INTELX_API_KEY` | Intelligence X API key (academia/paid) |
| `WEBHOOK_DISCORD` | Discord webhook URL for notifications |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token for notifications |
| `TELEGRAM_CHAT_ID` | Telegram chat ID for notifications |
| `DEFAULT_OUTPUT_DIR` | Output directory (blank = ~/.config/waymore/) |
| `SOURCE_IP` | Bind to specific source IP |
| `CONTINUE_RESPONSES_IF_PIPED` | Continue incomplete response runs when piped (default: True) |

**Note:** MIME type filtering does not apply to Alien Vault, VirusTotal, or Intelligence X (they don't support it). URLScan sometimes lacks MIME type definitions.

## Notes for Claude

When helping users with waymore:

1. **Never suggest passing a subdomain file** — pass the root domain only. Waymore retrieves all subdomains automatically and it's much faster.
2. **Always recommend `--check-only` first** for large targets to estimate request volume and time before committing.
3. **Use `-lr`** (limit requests) for massive domains (e.g., twitter.com with 28M+ requests) to prevent extremely long runs.
4. **Keep `-p` at default (2-3)** — higher thread counts cause reliability issues with archived response retrieval.
5. **Suggest `-l`** to limit response count. Default is 5000; use negative values for most recent (e.g., `-l -1000`).
6. **Use date filters** (`-from`, `-to`) to narrow results to relevant time periods.
7. **Recommend `-v`** for visibility — shows MIME types found, helps identify additional exclusions.
8. **Common Crawl can be slow** — suggest `-xcc` if speed matters or Common Crawl API is down. Check status at index.commoncrawl.org/collinfo.json.
9. **For xnLinkFinder integration**: run `waymore -mode B` first, then point xnLinkFinder at the results directory with `-d 5 -u desktop mobile`.
10. **Response resumption**: interrupted runs create `continueResp.tmp` and `responses.tmp` for automatic resume on next run.
11. **Piping behavior**: errors to stderr, links to stdout. Output file still created alongside pipe. Burp/ZAP/Caido/HAR files cannot be piped.
12. **Use `-ci` (capture interval)** to control deduplication granularity: `d` (daily, default), `h` (hourly for more coverage), `m` (monthly for less).
13. **API keys improve results**: URLScan key (free) gives higher rate limits. Intelligence X requires academia/paid subscription.
14. **Date limits have exceptions**: VirusTotal returns all known subdomains regardless; Intelligence X returns all URLs regardless.
15. **For secret hunting**: combine `waymore -mode R` with `trufflehog filesystem` on the results directory.
16. **Use `-ko` with regex** for targeted retrieval (e.g., JS files only: `-ko "\.js(\?.*|$)"`). The CDX regex requires full string match — use `.*` padding.
17. **Use `-ow`** when re-running to get clean output instead of appended duplicates.
