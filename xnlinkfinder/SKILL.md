---
name: xnlinkfinder
description: Expert guidance for xnLinkFinder endpoint/parameter/secret discovery during penetration testing, including crawling, Burp/ZAP/Caido/HAR import, wordlist generation, and scope management
---

# xnLinkFinder Skill

## Overview
xnLinkFinder is a Python 3 reconnaissance tool for discovering endpoints, parameters, and secrets from targets. It accepts live URLs, files, directories, Burp XML, ZAP exports, Caido CSV, and HAR files. It generates target-specific wordlists and extracts secrets automatically.

## Installation
```bash
# pip
pip install xnLinkFinder

# From GitHub
pip install git+https://github.com/xnl-h4ck3r/xnLinkFinder.git -v

# Upgrade
pip install --upgrade xnLinkFinder

# pipx (isolated)
pipx install git+https://github.com/xnl-h4ck3r/xnLinkFinder.git
```

### Optional PDF Support
```bash
# Linux
sudo apt install -y poppler-utils
# macOS
brew install poppler
# OCR for scanned PDFs
sudo apt install -y ocrmypdf
```

## Core Concepts

### Input Types
- **URL/domain**: `target.com` or `https://target.com`
- **URL list file**: text file with one URL per line
- **Directory**: searches all files recursively (e.g., waymore results)
- **Single file**: raw response, JS, HTML file
- **Burp XML**: exported Burp Suite project
- **ZAP ASCII**: exported ZAP message file
- **Caido CSV**: exported Caido HTTP history
- **HAR JSON**: browser HTTP Archive export
- **stdin**: piped input from other tools

### Scope Prefix (`-sp`)
Prepends scope domains to relative links found. Accepts a single domain or a file of domains. Format (no paths, no wildcards, schema optional — defaults to http):
```
http://www.target.com
https://target-payments.com
https://static.target-cdn.com
```

### Scope Filter (`-sf`)
Filters output to only include links matching specified domains. Format (no schema, no path):
```
target.*
target-payments.com
static.target-cdn.com
```

## Command Line Arguments

### Input/Output
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-i` | `--input` | URL, file of URLs, directory, Burp XML, ZAP, Caido CSV, HAR, or single file |
| `-o` | `--output` | Links output file (default: output.txt); "cli" for STDOUT only |
| `-op` | `--output-params` | Parameters output file (default: parameters.txt); "cli" for STDOUT |
| `-owl` | `--output-wordlist` | Target-specific wordlist output file; "cli" for STDOUT |
| `-oo` | `--output-oos` | Out-of-scope links output file |
| `-os` | `--output-secrets` | Secrets output in JSON format |
| `-ow` | `--output-overwrite` | Overwrite existing output files instead of appending |

### Scope and Filtering
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-sp` | `--scope-prefix` | Prefix relative links with scope domains (file or string) |
| `-spo` | `--scope-prefix-original` | Also include original relative links alongside prefixed |
| `-spkf` | `--scope-prefix-keep-failed` | Keep prefixed links even if they return 404/connection error |
| `-sf` | `--scope-filter` | Filter output to specified domains only (mandatory for URL input) |
| `-x` | `--exclude` | Comma-separated additional exclusions beyond config.yml |
| `-ra` | `--regex-after` | Regex to filter endpoints (e.g., `/api/v[0-9]\.[0-9]\*`) |

### Request Configuration
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-c` | `--cookies` | Cookies: `'name1=value1; name2=value2;'` |
| `-H` | `--headers` | Headers: `'Header1: value1; Header2: value2;'` |
| `-u` | `--user-agent` | UA type: desktop, mobile, set-top-boxes, game-console, mobile-apple/android/windows |
| `-uc` | `--user-agent-custom` | Custom User Agent string |
| `-t` | `--timeout` | Response timeout in seconds (default: 10) |
| `-r` | `--retries` | Retry failed requests, max 5 (default: 0) |
| `-insecure` | | Disable TLS certificate validation |

### Crawling and Processing
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-d` | `--depth` | Crawl depth level (default: 1); ignored for Burp/ZAP/Caido/HAR |
| `-p` | `--processes` | Number of threads (default: 25) |
| `-rl` | `--rate-limit` | Max requests per second (default: 0 = unlimited) |
| `-fp` | `--forward-proxy` | Replay requests through proxy (e.g., http://127.0.0.1:8080) |
| `-rp` | `--request-proxy` | Request proxy string or file with proxy list |
| `--heap` | | Extract links from browser heap memory via Playwright |

### Content Processing
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-ro` | `--readable-only` | Extract only human-readable text (excludes script/style/noscript/template) |
| `-ascii-only` | | Accept only ASCII-character links and parameters |
| `-xrel` | `--exclude-relative-links` | Exclude relative links starting with ./ or ../ |
| `-mfs` | `--max-file-size` | Skip files exceeding size in bytes (default: 500 MB; 0 = no limit) |
| `-mrs` | `--max-response-size` | Skip responses exceeding size in MB (default: 100 MB) |

### Output Formatting
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-orig` | `--origin` | Show link origins: `LINK [ORIGIN-URL]` |
| `-prefixed` | | Mark prefixed links with `(PREFIXED)` |
| `-inc` | `--include` | Include input links in output |
| `-cl` | `--content-length` | Show Content-Length during crawling |
| `-all` | `--all-tlds` | Return all TLDs (may increase false positives) |

### Stop Conditions
| Flag | Purpose |
|------|---------|
| `-s429` | Stop when >95% responses return 429 |
| `-s403` | Stop when >95% responses return 403 |
| `-sTO` | Stop when >95% requests time out |
| `-sCE` | Stop when >95% requests have connection errors |

### Resource Management
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-m` | `--memory-threshold` | Stop if memory exceeds percentage (default: 95%) |
| `-mtl` | `--max-time-limit` | Max runtime in minutes (default: 0 = unlimited) |

### Wordlist Generation Control
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-nwlpl` | `--no-wordlist-plurals` | Skip singular/plural variants |
| `-nwlpw` | `--no-wordlist-pathwords` | Skip path words from links |
| `-nwlpm` | `--no-wordlist-parameters` | Skip parameters from wordlist |
| `-nwlc` | `--no-wordlist-comments` | Skip page comments |
| `-nwlia` | `--no-wordlist-imgalt` | Skip image alt attributes |
| `-nwld` | `--no-wordlist-digits` | Exclude words with digits |
| `-nwll` | `--no-wordlist-lowercase` | Skip lowercase variants of uppercase words |
| `-wlml` | `--wordlist-maxlen` | Max word length (default: 0 = unlimited) |
| `-swf` | `--stopwords-file` | File of additional stop words to exclude |

### Burp-Specific
| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-brt` | `--burpfile-remove-tags` | Remove unnecessary Burp XML tags; pass "true"/"false" in scripts |

### Utility
| Flag | Purpose |
|------|---------|
| `--config` | Path to YML config file (default: ~/.config/xnLinkFinder/config.yml) |
| `-nb` / `--no-banner` | Hide banner |
| `-v` / `--verbose` | Verbose output |
| `-vv` / `--vverbose` | Extra verbose output |
| `--version` | Show version |
| `-h` / `--help` | Show help |

## Common Use Cases

### 1. Basic Target Crawl
```bash
xnLinkFinder -i target.com -sf target.com
```

### 2. Full-Featured Crawl with Auth
```bash
xnLinkFinder -i target.com -sp target_prefix.txt -sf target_scope.txt -spo -inc -vv \
  -H 'Authorization: Bearer XXXXXXXXXXXXXX' -c 'SessionId=MYSESSIONID' \
  -u desktop mobile -d 10
```

### 3. Multiple URLs from File
```bash
xnLinkFinder -i target_js.txt -sf target.com
```

### 4. Directory of Files (e.g., waymore results)
```bash
xnLinkFinder -i ~/.config/waymore/results/target.com
```

### 5. Burp Suite Project
```bash
xnLinkFinder -i target_burp.xml -o target_burp.txt -sp https://www.target.com \
  -sf target.* -ow -spo -inc -vv
```

### 6. ZAP Project
```bash
xnLinkFinder -i target_zap.txt
```

### 7. Caido CSV
```bash
xnLinkFinder -i 2023-03-18-010332_csv_requests.csv
```

### 8. Caido CSV (Filtered for Specific Target)
```bash
cat export.csv | grep -E '^id|^[0-9]+,[^,]*target' > caido_target.csv
xnLinkFinder -i caido_target.csv
```

### 9. HAR File
```bash
xnLinkFinder -i browser.har
```

### 10. Waymore Results with Depth
```bash
xnLinkFinder -i ~/Tools/waymore/results/target.com -d 5 -u desktop mobile
```

### 11. Piping to Other Tools
```bash
xnLinkFinder -i target.com -sp https://target.com -sf target.* -d 3 | unfurl keys | sort -u
```

### 12. Stdin Input
```bash
cat target_subs.txt | xnLinkFinder -sp https://target.com -sf target.* -d 3
```

### 13. Regex Filtering
```bash
xnLinkFinder -i target.com -sf target.com -ra '/api/v[0-9]\.[0-9]\*'
```

### 14. Forward Proxy (Burp Replay)
```bash
xnLinkFinder -i target.com -sp https://target.com -sf target.com -fp http://127.0.0.1:8080
```

### 15. Rate-Limited Crawl
```bash
xnLinkFinder -i target.com -sf target.com -rl 10
```

### 16. Browser Heap Analysis
```bash
xnLinkFinder -i target.com -sp https://target.com -sf target.com --heap
```

### 17. Full Recon with Wordlist + Secrets
```bash
xnLinkFinder -i target.com -sp https://target.com -sf target.* -d 3 \
  -o links.txt -op params.txt -owl wordlist.txt -os secrets.json -ow -v
```

## Configuration (config.yml)

Default location: `~/.config/xnLinkFinder/config.yml`

Key settings:
| Key | Purpose |
|-----|---------|
| `linkExclude` | Exclude links matching patterns (CSS, images, etc.) |
| `contentExclude` | Exclude responses by Content-Type |
| `fileExtExclude` | Exclude file extensions in directory mode |
| `regexFiles` | File extensions to match in regex |
| `respParamLinksFound` | Extract parameters from found links (True) |
| `respParamPathWords` | Add path words as parameters (True) |
| `respParamJSON` | Extract JSON keys as parameters (True) |
| `respParamJSVars` | Extract JS variables as parameters (True) |
| `respParamXML` | Extract XML attributes as parameters (True) |
| `respParamInputField` | Extract INPUT/TEXTAREA/SELECT names (True) |
| `respParamMetaName` | Extract META tag NAME attributes (True) |
| `wordsContentTypes` | Content types to search for wordlist |
| `stopWords` | Words excluded from wordlist generation |
| `commonTLDs` | Valid TLDs for link validation |

## Notes for Claude

When helping users with xnLinkFinder:

1. **ALWAYS use `-sp` and `-sf`** — scope prefix and scope filter are essential for meaningful results. Without them, output is noisy and includes irrelevant domains.
2. **Always recommend `-sf`** for URL/domain input — it's mandatory for filtering relevant links.
3. **Suggest `-owl`** for wordlist generation — target-specific wordlists are one of the tool's most valuable outputs for follow-up fuzzing.
4. **Use `-os`** for secret detection — JSON output is easy to parse and review.
5. **Start with low depth** (`-d 2`) and increase gradually — high depth can lead to crawling endless dynamic pages.
6. **Use `-v` or `-vv`** to give visibility into what the tool is doing and for troubleshooting.
7. **For authenticated scans**, pass `-H` for auth headers and `-c` for cookies.
8. **For proxy tools (Burp/ZAP/Caido/HAR)**, the `-d`, `-t`, `-p`, `-rl`, `-fp`, `-rp` flags are ignored — the tool processes the exported data directly.
9. **Waymore integration**: when scanning waymore results directory, pass `-d` for extra depth and `-u desktop mobile` for varied content.
10. **Rate limiting**: use `-rl` to avoid overwhelming targets. Use stop flags (`-s429`, `-s403`, `-sTO`, `-sCE`) for problematic targets.
11. **Piping**: errors go to stderr, links to stdout. Parameters are not piped but still written to file. Burp/ZAP/Caido/HAR files cannot be piped.
12. **Graceful shutdown**: Ctrl-C saves gathered data before exiting. Memory threshold (`-m`) also triggers graceful exit.
13. **Combine with other tools**: pipe output to `unfurl`, `sort -u`, `httpx`, `nuclei`, or use the wordlist with `ffuf`.
14. **Wrap regex values in single quotes**: `-ra '/api/v[0-9]\.[0-9]\*'`
15. **Use `-ascii-only`** to reduce false positives from binary/encoded content.
16. **Use `-ow`** when re-running scans to get clean output files instead of appended duplicates.
