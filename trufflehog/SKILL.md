---
name: trufflehog
description: Expert guidance for TruffleHog secret detection and credential scanning across Git repos, GitHub/GitLab, Docker images, S3, GCS, filesystems, CI/CD, Postman, Jenkins, Elasticsearch, and Hugging Face
---

# TruffleHog Skill

## Overview
TruffleHog discovers, classifies, validates, and analyzes leaked secrets across multiple sources. It detects 800+ secret types (API keys, passwords, private keys, tokens) and verifies whether detected credentials are live/active. Written in Go.

### Key Capabilities
- **Discovery**: scans Git, GitHub/GitLab, Docker, S3, GCS, filesystems, CI/CD, Postman, Jenkins, Elasticsearch, Hugging Face, syslog, stdin
- **Classification**: 800+ credential detectors mapped to specific identities
- **Validation**: tests if secrets are live via API verification
- **Analysis**: deep inspection of verified credentials to determine permissions and resource access

## Installation

```bash
# macOS
brew install trufflehog

# Install script (latest)
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

# Install script (with cosign signature verification)
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -v -b /usr/local/bin

# Install script (specific version)
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin v3.56.0

# From source
git clone https://github.com/trufflesecurity/trufflehog.git
cd trufflehog && go install

# Docker
docker run --rm -it trufflesecurity/trufflehog:latest <subcommand>
```

## Supported Sources (Subcommands)

| Subcommand | Source |
|------------|--------|
| `git` | Git repositories (local or remote) |
| `github` | GitHub organizations and repositories |
| `gitlab` | GitLab repositories |
| `docker` | Docker images (registry, daemon, tarball) |
| `s3` | Amazon S3 buckets |
| `gcs` | Google Cloud Storage |
| `filesystem` | Local files and directories |
| `stdin` | Standard input |
| `syslog` | Syslog data |
| `postman` | Postman workspaces/collections |
| `jenkins` | Jenkins servers |
| `elasticsearch` | Elasticsearch clusters |
| `circleci` | CircleCI pipelines |
| `travisci` | Travis CI pipelines |
| `huggingface` | Hugging Face models/datasets/spaces |
| `github-experimental` | GitHub cross-fork object references (alpha) |
| `multi-scan` | Multiple sources via config YAML |

## Command Line Arguments

### Global Flags
| Flag | Purpose |
|------|---------|
| `--log-level=0` | Verbosity 0 (info) to 5 (trace); -1 to disable |
| `-j, --json` | JSON output |
| `--json-legacy` | Pre-v3.0 JSON format |
| `--github-actions` | GitHub Actions output format |
| `--concurrency=20` | Concurrent workers |
| `--no-verification` | Skip secret verification |
| `--results=RESULTS` | Filter: `verified`, `unknown`, `unverified`, `filtered_unverified` |
| `--allow-verification-overlap` | Allow similar credentials verification across detectors |
| `--filter-unverified` | Only first unverified result per chunk per detector |
| `--filter-entropy=N` | Filter unverified by Shannon entropy (start at 3.0) |
| `--config=FILE` | YAML config file path |
| `--print-avg-detector-time` | Show average time per detector |
| `--no-update` | Skip update check |
| `--fail` | Exit code 183 if results found |
| `--verifier=URL` | Custom verification endpoint |
| `--custom-verifiers-only` | Use only custom verifiers |
| `--archive-max-size=SIZE` | Max archive size (e.g., 4MB) |
| `--archive-max-depth=N` | Max archive extraction depth |
| `--archive-timeout=DURATION` | Max archive extraction time |
| `--include-detectors=LIST` | Include specific detector types |
| `--exclude-detectors=LIST` | Exclude specific detector types |
| `-i, --include-paths=FILE` | File with newline-separated path regexes to include |
| `-x, --exclude-paths=FILE` | File with newline-separated path regexes to exclude |
| `--version` | Show version |

### Git-Specific Flags
| Flag | Purpose |
|------|---------|
| `--exclude-globs=GLOBS` | Comma-separated globs to exclude (git log level) |
| `--since-commit=COMMIT` | Start scanning from this commit |
| `--branch=BRANCH` | Specific branch to scan |
| `--max-depth=N` | Maximum commit depth |
| `--bare` | Scan bare repository (pre-receive hooks) |
| `--clone-path=PATH` | Custom clone path for local repos |
| `--trust-local-git-config` | Skip cloning, scan directly (trusted repos only) |

### GitHub-Specific Flags
| Flag | Purpose |
|------|---------|
| `--org=ORG` | Scan entire organization |
| `--repo=URL` | Specific repository URL |
| `--issue-comments` | Scan issue comments |
| `--pr-comments` | Scan PR comments |
| `--token=TOKEN` | GitHub API token (improves rate limits) |

### S3-Specific Flags
| Flag | Purpose |
|------|---------|
| `--bucket=NAME` | S3 bucket name |
| `--role-arn=ARN` | IAM role ARN to assume (repeatable) |

### GCS-Specific Flags
| Flag | Purpose |
|------|---------|
| `--project-id=ID` | Google Cloud project ID |
| `--cloud-environment` | Use cloud environment credentials |

### Docker-Specific Flags
| Flag | Purpose |
|------|---------|
| `--image=IMAGE` | Image to scan (repeatable); supports `docker://` and `file://` |

### Elasticsearch-Specific Flags
| Flag | Purpose |
|------|---------|
| `--nodes=NODES` | Cluster node addresses |
| `--username=USER` | Auth username |
| `--password=PASS` | Auth password |
| `--service-token=TOKEN` | Service token auth |
| `--cloud-id=ID` | Elastic Cloud ID |
| `--api-key=KEY` | Elastic Cloud API key |

### Jenkins-Specific Flags
| Flag | Purpose |
|------|---------|
| `--url=URL` | Jenkins server URL |
| `--username=USER` | Jenkins username |
| `--password=PASS` | Jenkins password |

### Postman-Specific Flags
| Flag | Purpose |
|------|---------|
| `--token=TOKEN` | Postman API token |
| `--workspace-id=ID` | Workspace ID (repeatable) |
| `--collection-id=ID` | Collection ID (repeatable) |
| `--environment=ENV` | Environment (repeatable) |

### Hugging Face-Specific Flags
| Flag | Purpose |
|------|---------|
| `--model=ID` | Model ID (repeatable) |
| `--dataset=ID` | Dataset ID (repeatable) |
| `--space=ID` | Space ID (repeatable) |
| `--org=NAME` | Organization name |
| `--user=USERNAME` | Username |
| `--skip-models` | Skip all models |
| `--skip-datasets` | Skip all datasets |
| `--skip-spaces` | Skip all spaces |
| `--ignore-models=ID` | Skip specific model IDs |
| `--ignore-datasets=ID` | Skip specific dataset IDs |
| `--ignore-spaces=ID` | Skip specific space IDs |
| `--include-discussions` | Scan discussion comments |
| `--include-prs` | Scan PR comments |

### GitHub Experimental Flags
| Flag | Purpose |
|------|---------|
| `--repo=URL` | Repository URL |
| `--object-discovery` | Enumerate deleted/hidden commits |
| `--delete-cached-data` | Remove tracking files after scan |

## Common Use Cases

### 1. Git Repository (Verified Secrets Only)
```bash
trufflehog git https://github.com/org/repo --results=verified
```

### 2. Git Repository (JSON Output)
```bash
trufflehog git https://github.com/org/repo --results=verified --json
```

### 3. Local Git Repository
```bash
trufflehog git file://./my-repo --results=verified,unknown
```

### 4. GitHub Organization
```bash
trufflehog github --org=myorg --results=verified --token=ghp_xxx
```

### 5. GitHub Repo with Comments
```bash
trufflehog github --repo=https://github.com/org/repo --issue-comments --pr-comments
```

### 6. S3 Bucket
```bash
trufflehog s3 --bucket=my-bucket --results=verified,unknown
```

### 7. S3 with IAM Role Assumption
```bash
trufflehog s3 --bucket=my-bucket --role-arn=arn:aws:iam::123456:role/scanner
```

### 8. Docker Image (Remote Registry)
```bash
trufflehog docker --image trufflesecurity/secrets --results=verified
```

### 9. Docker Image (Local Daemon)
```bash
trufflehog docker --image docker://my-image:tag --results=verified
```

### 10. Docker Image (Tarball)
```bash
trufflehog docker --image file://image.tar --results=verified
```

### 11. Filesystem
```bash
trufflehog filesystem path/to/dir --results=verified,unknown
```

### 12. Filesystem (Waymore Results)
```bash
trufflehog filesystem ~/.config/waymore/results/target.com
```

### 13. Google Cloud Storage
```bash
trufflehog gcs --project-id=my-project --cloud-environment --results=verified
```

### 14. Postman Workspace
```bash
trufflehog postman --token=PMAK-xxx --workspace-id=ws-xxx
```

### 15. Jenkins Server
```bash
trufflehog jenkins --url https://jenkins.example.com --username admin --password admin
```

### 16. Elasticsearch Cluster
```bash
trufflehog elasticsearch --nodes 192.168.1.10 --username admin --password secret
```

### 17. Elasticsearch (Elastic Cloud)
```bash
trufflehog elasticsearch --cloud-id='prod:base64data' --api-key='key'
```

### 18. Hugging Face Organization
```bash
trufflehog huggingface --org myorg --include-discussions --include-prs
```

### 19. Stdin (Piped Data)
```bash
aws s3 cp s3://bucket/data.gz - | gunzip -c | trufflehog stdin
```

### 20. CI/CD PR Scanning
```bash
trufflehog git file://. --since-commit main --branch feature-1 --results=verified,unknown --fail
```

### 21. GitHub Experimental (Deleted Commits)
```bash
trufflehog github-experimental --repo https://github.com/org/repo.git --object-discovery
```

### 22. Analyze Verified Credentials
```bash
trufflehog analyze
```

### 23. Docker (Platform-Specific)
```bash
# Unix
docker run --rm -it -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --repo https://github.com/org/repo

# Windows PowerShell
docker run --rm -it -v "${PWD}:/pwd" trufflesecurity/trufflehog github --repo https://github.com/org/repo

# M1/M2 Mac
docker run --platform linux/arm64 --rm -it -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --repo https://github.com/org/repo

# With SSH key access
docker run --rm -v "$HOME/.ssh:/root/.ssh:ro" trufflesecurity/trufflehog:latest git ssh://github.com/org/repo
```

## CI/CD Integration

### GitHub Actions
```yaml
on:
  push:
    branches: [main]
  pull_request:

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - uses: trufflesecurity/trufflehog@main
      with:
        extra_args: --results=verified,unknown
```

### GitHub Actions (Scan Entire Branch)
```yaml
- uses: trufflesecurity/trufflehog@main
  with:
    base: ""
    head: ${{ github.ref_name }}
    extra_args: --results=verified,unknown
```

### GitLab CI
```yaml
security-secrets:
  stage: security
  image: alpine:latest
  before_script:
    - apk add --no-cache git curl jq
    - curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
  script:
    - trufflehog filesystem "$SCAN_PATH" --results=verified,unknown --fail --json | jq
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

## Configuration

### Custom Regex Detectors (YAML)
Define custom detectors with patterns, keywords, entropy thresholds, and verification webhooks:
```yaml
# Minimum: one regex + one keyword
# Optional: webhook verification, entropy filtering, excluded word lists
```

### Multi-Source Config
```yaml
sources:
- connection:
    '@type': type.googleapis.com/sources.GitHub
    repositories:
    - https://github.com/org/repo.git
    unauthenticated: {}
  name: example scan
  type: SOURCE_TYPE_GITHUB
  verify: true
```

### Ignoring Specific Secrets
Add `trufflehog:ignore` comment on the line containing the secret (sources with line number support).

### Exit Codes
| Code | Meaning |
|------|---------|
| 0 | No errors, no results |
| 1 | Errors encountered, sources may be incomplete |
| 183 | No errors but results found (only with `--fail`) |

### Result Statuses
| Status | Meaning |
|--------|---------|
| `verified` | Credential confirmed active via API |
| `unverified` | Detected but not confirmed valid |
| `unknown` | Verification attempted but failed (network/API errors) |

## Notes for Claude

When helping users with TruffleHog:

1. **Always recommend `--results=verified,unknown`** for most scans — this filters out noise while keeping actionable findings and edge cases.
2. **Use `--fail` in CI/CD** to fail pipelines when secrets are found (exit code 183).
3. **Always include `--token` for GitHub org scans** — without it, rate limiting makes scans extremely slow.
4. **For local git repos**, use `file://` prefix: `trufflehog git file://./repo`.
5. **For CI/CD PR scanning**, use `--since-commit main --branch feature-1` to scan only the diff.
6. **Use `--json`** for machine-parseable output, especially when piping to `jq` or other tools.
7. **Filesystem scanning works with waymore results**: `trufflehog filesystem ~/.config/waymore/results/target.com` to find secrets in archived responses.
8. **Docker images support three sources**: remote registry (default), local daemon (`docker://`), and tarball (`file://`).
9. **Use `--no-verification`** when scanning air-gapped environments or when you don't want to trigger API calls against detected credentials.
10. **Filter noisy results** with `--filter-entropy=3.0` to remove low-entropy unverified matches.
11. **S3 scanning with multiple roles**: pass `--role-arn` multiple times to scan buckets across accounts.
12. **GitHub experimental `--object-discovery`** can find secrets in deleted/force-pushed commits but takes 20min to hours depending on repo size.
13. **Use `-x exclude_paths.txt`** to skip vendor, node_modules, test fixtures, and other noisy directories.
14. **Verified private keys** mean the key is confirmed live for SSH or TLS authentication (via Driftwood technology).
15. **Local repo security**: TruffleHog clones local repos to a temp dir by default to guard against malicious git configs. Use `--trust-local-git-config` only for trusted repos.
16. **Use `trufflehog analyze`** after scanning to perform deep permission analysis on verified credentials.
