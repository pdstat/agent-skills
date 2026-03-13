# param-repeater API Skills

param-repeater is a security testing tool for automated parameter discovery, endpoint enumeration, and fuzzing during penetration testing. It runs on `http://localhost:8081` by default.

All endpoints below are read-only (GET) unless stated otherwise. Use `curl` for requests and `jq` for parsing JSON responses.

## Discover Available Projects, Sources, and Categories

Before querying parameters or paths, discover the valid values for filters.

### List projects

```bash
curl -s http://localhost:8081/api/browser/projects | jq '.[]'
```

Returns a JSON array of project name strings. Use these as the `{project}` path variable in all other endpoints.

### List parameter sources

```bash
curl -s http://localhost:8081/api/browser/sources | jq '.[]'
```

Returns a JSON array of strings. Valid values: `QUERY_PARAMETER`, `COOKIE`, `REQUEST_BODY_JSON`, `REQUEST_BODY_FORM`, `REQUEST_BODY_MULTIPART`, `RESPONSE_BODY_JSON`, `RESPONSE_HTML_LINK`, `RESPONSE_HTML_INPUT`, `RESPONSE_HTML_HIDDEN_INPUT`, `RESPONSE_HTML_JSON_SCRIPT`, `JS_REQUEST_QUERY_KEY`, `JS_REQUEST_BODY_KEY`, `JS_REQUEST_HEADER`, `JS_RESPONSE_PROPERTY`, `JS_PATH_PARAM`, `JS_URLSEARCHPARAM_KEY`, `JS_FORMDATA_KEY`, `JS_STORAGE_KEY`, `JS_DATASET_KEY`, `JS_CONFIG_KEY`, `JS_ANALYTICS_KEY`, `JS_GRAPHQL_VARIABLE`, `JS_OBJECT_PROPERTY`, `JS_INLINE_SCRIPT`, `JS_EVENT_HANDLER`.

### List path sources

```bash
curl -s http://localhost:8081/api/browser/path-sources | jq '.[]'
```

Returns a JSON array of strings. Valid values: `HTML_LINK`, `HTML_FORM_ACTION`, `HTML_SCRIPT`, `HTML_RESOURCE`, `JS_URL`, `JSON_VALUE`.

### List suspicious categories

```bash
curl -s http://localhost:8081/api/browser/sus-categories | jq '.[]'
```

Returns a JSON array of strings. Valid values: `SQLI`, `OPEN_REDIRECT`, `SSRF`, `DEBUG`, `XSS`, `IDOR`, `FILEINC`, `CMDI`, `SSTI`, `MASSASSIGNMENT`. These classify parameters by the vulnerability types they are commonly associated with.

---

## Parameters

### Export parameter wordlist

```
GET /api/params/{project}/
```

Returns plain text (one parameter name per line). Use this to build wordlists for fuzzing tools like ffuf, Burp Intruder, or custom scripts.

**Query parameters (all optional):**

| Param    | Type             | Description                                      |
|----------|------------------|--------------------------------------------------|
| `q`      | string           | Filter parameter names containing this substring |
| `host`   | string (regex)   | Filter by host regex pattern                     |
| `path`   | string (regex)   | Filter by request path regex pattern             |
| `source` | string (multi)   | Filter by parameter source (repeatable)          |
| `sus`    | string (multi)   | Filter by suspicious category (repeatable)       |

**Examples:**

```bash
# Get all discovered parameters for a project
curl -s 'http://localhost:8081/api/params/amazon-testing/'

# Search for parameters containing "token"
curl -s 'http://localhost:8081/api/params/amazon-testing/?q=token'

# Filter by host
curl -s 'http://localhost:8081/api/params/amazon-testing/?host=api\.amazon\.com'

# Filter by path
curl -s 'http://localhost:8081/api/params/amazon-testing/?path=/checkout.*'

# Get only query string and cookie parameters
curl -s 'http://localhost:8081/api/params/amazon-testing/?source=QUERY_PARAMETER&source=COOKIE'

# Get parameters flagged as potential SQL injection or IDOR vectors
curl -s 'http://localhost:8081/api/params/amazon-testing/?sus=SQLI&sus=IDOR'

# Combine filters: JSON body params on a specific host that look like SSRF
curl -s 'http://localhost:8081/api/params/amazon-testing/?host=api\.amazon\.com&source=REQUEST_BODY_JSON&sus=SSRF'

# Count discovered parameters
curl -s 'http://localhost:8081/api/params/amazon-testing/' | wc -l

# Pipe directly into ffuf
curl -s 'http://localhost:8081/api/params/amazon-testing/?sus=SQLI' | \
  ffuf -u 'https://target.com/search?FUZZ=test' -w -
```

### Get parameter detail

```
GET /api/params/{project}/{param}
```

Returns JSON with full detail about a single parameter: where it was found, how many times, and which vulnerability categories it maps to. Returns HTTP 404 if the parameter does not exist.

**Example:**

```bash
curl -s 'http://localhost:8081/api/params/amazon-testing/redirect_url' | jq
```

**Response structure:**

```json
{
  "name": "redirect_url",
  "susCategories": [
    "OPEN_REDIRECT",
    "SSRF"
  ],
  "occurrences": [
    {
      "source": "QUERY_PARAMETER",
      "host": "www.amazon.com",
      "path": "/login",
      "occurrenceCount": 5
    }
  ]
}
```

**Response fields:**

| Field                          | Description                                                |
|--------------------------------|------------------------------------------------------------|
| `name`                         | The parameter name                                         |
| `susCategories[]`              | Vulnerability categories this parameter is associated with |
| `occurrences[]`                | Where this parameter was found (one per source+request)    |
| `occurrences[].source`         | The extraction method (see parameter sources above)        |
| `occurrences[].host`           | Host of the request where the parameter was observed       |
| `occurrences[].path`           | Request path where the parameter was observed              |
| `occurrences[].occurrenceCount`| How many times this param was seen from this source        |

**Analysis examples:**

```bash
# Check if a parameter is flagged as suspicious
curl -s 'http://localhost:8081/api/params/amazon-testing/redirect_url' | \
  jq '.susCategories'

# List all hosts where a parameter was seen
curl -s 'http://localhost:8081/api/params/amazon-testing/user_id' | \
  jq '[.occurrences[].host] | unique'

# List all paths where a parameter was seen
curl -s 'http://localhost:8081/api/params/amazon-testing/user_id' | \
  jq '[.occurrences[].path] | unique'

# Get the total occurrence count across all sources
curl -s 'http://localhost:8081/api/params/amazon-testing/session_id' | \
  jq '[.occurrences[].occurrenceCount] | add'

# Find which extraction methods discovered a parameter
curl -s 'http://localhost:8081/api/params/amazon-testing/api_key' | \
  jq '[.occurrences[].source] | unique'
```

---

## Paths

### Export discovered paths wordlist

```
GET /api/paths/{project}/
```

Returns plain text (one path per line). Use this for endpoint enumeration and directory brute-forcing.

**Query parameters (all optional):**

| Param    | Type           | Description                                               |
|----------|----------------|-----------------------------------------------------------|
| `q`      | string         | Filter paths containing this substring                    |
| `host`   | string (regex) | Filter by host regex pattern                              |
| `source` | string (multi) | Filter by path source (repeatable)                        |
| `format` | string         | `path` (default) for paths only, `full` for `host/path`   |

**Examples:**

```bash
# Get all discovered paths
curl -s 'http://localhost:8081/api/paths/amazon-testing/'

# Get full URLs (host + path)
curl -s 'http://localhost:8081/api/paths/amazon-testing/?format=full'

# Search for API endpoints
curl -s 'http://localhost:8081/api/paths/amazon-testing/?q=/api/'

# Get paths discovered from JavaScript
curl -s 'http://localhost:8081/api/paths/amazon-testing/?source=JS_URL'

# Get paths found in HTML links and forms
curl -s 'http://localhost:8081/api/paths/amazon-testing/?source=HTML_LINK&source=HTML_FORM_ACTION'

# Filter to a specific host
curl -s 'http://localhost:8081/api/paths/amazon-testing/?host=api\.amazon\.com'

# Count discovered endpoints
curl -s 'http://localhost:8081/api/paths/amazon-testing/' | wc -l

# Pipe into ffuf for directory discovery
curl -s 'http://localhost:8081/api/paths/amazon-testing/' | \
  ffuf -u 'https://target.com/FUZZ' -w -
```

### Get path detail

```
GET /api/paths/{project}/detail
```

Returns JSON with full detail about a discovered path. Returns HTTP 404 if the path does not exist.

**Query parameters:**

| Param  | Required | Description                                 |
|--------|----------|---------------------------------------------|
| `path` | yes      | The path to look up                         |
| `host` | no       | Filter to a specific host                   |

**Example:**

```bash
curl -s 'http://localhost:8081/api/paths/amazon-testing/detail?path=/api/v1/users' | jq
```

**Response structure:**

```json
{
  "path": "/api/v1/users",
  "occurrences": [
    {
      "source": "JS_URL",
      "host": "www.amazon.com",
      "path": "/static/js/app.bundle.js",
      "occurrenceCount": 3
    }
  ]
}
```

**Response fields:**

| Field                          | Description                                                        |
|--------------------------------|--------------------------------------------------------------------|
| `path`                         | The discovered path/endpoint                                       |
| `occurrences[]`                | Where this path was found (one per source+request pair)            |
| `occurrences[].source`         | The extraction method (see path sources above)                     |
| `occurrences[].host`           | Host of the request that contained the path reference              |
| `occurrences[].path`           | Path of the request/resource that contained the reference (null if no stored request) |
| `occurrences[].occurrenceCount`| How many times this path was found from this source                |

**Analysis examples:**

```bash
# List all hosts an endpoint was discovered on
curl -s 'http://localhost:8081/api/paths/amazon-testing/detail?path=/api/v1/users' | \
  jq '[.occurrences[].host] | unique'

# See which source files referenced this path
curl -s 'http://localhost:8081/api/paths/amazon-testing/detail?path=/api/v1/users' | \
  jq '.occurrences[] | "\(.source) \(.host)\(.path)"'

# Check discovery sources
curl -s 'http://localhost:8081/api/paths/amazon-testing/detail?path=/admin' | \
  jq '[.occurrences[].source] | unique'

# Filter path detail to a specific host
curl -s 'http://localhost:8081/api/paths/amazon-testing/detail?path=/api/v1/users&host=api.amazon.com' | jq
```

---

## Workflow: Security Analysis with param-repeater

### 1. Discover the attack surface

```bash
# What projects are configured?
PROJECT=$(curl -s http://localhost:8081/api/browser/projects | jq -r '.[0]')

# How many parameters have been discovered?
curl -s "http://localhost:8081/api/params/$PROJECT/" | wc -l

# How many endpoints have been discovered?
curl -s "http://localhost:8081/api/paths/$PROJECT/" | wc -l
```

### 2. Find high-value parameters

```bash
# Parameters that look like SQL injection vectors
curl -s "http://localhost:8081/api/params/$PROJECT/?sus=SQLI"

# Parameters that look like open redirect vectors
curl -s "http://localhost:8081/api/params/$PROJECT/?sus=OPEN_REDIRECT"

# Parameters from hidden form inputs (often security-sensitive)
curl -s "http://localhost:8081/api/params/$PROJECT/?source=RESPONSE_HTML_HIDDEN_INPUT"

# Parameters discovered in JavaScript (may reveal undocumented API params)
curl -s "http://localhost:8081/api/params/$PROJECT/?source=JS_REQUEST_BODY_KEY&source=JS_REQUEST_QUERY_KEY"
```

### 3. Investigate a suspicious parameter

```bash
# Get full detail on a parameter
curl -s "http://localhost:8081/api/params/$PROJECT/redirect_url" | jq

# What vulnerability types is it associated with?
curl -s "http://localhost:8081/api/params/$PROJECT/redirect_url" | \
  jq '.susCategories'

# Where exactly was it seen?
curl -s "http://localhost:8081/api/params/$PROJECT/redirect_url" | \
  jq '.occurrences[] | "\(.source) \(.host)\(.path)"'
```

### 4. Discover API endpoints from JavaScript

```bash
# Endpoints extracted from JS bundles
curl -s "http://localhost:8081/api/paths/$PROJECT/?source=JS_URL"

# Get full URLs for direct testing
curl -s "http://localhost:8081/api/paths/$PROJECT/?source=JS_URL&format=full"

# Investigate a specific endpoint
curl -s "http://localhost:8081/api/paths/$PROJECT/detail?path=/api/internal/admin" | jq
```

### 5. Build targeted wordlists

```bash
# IDOR parameter wordlist for a specific API host
curl -s "http://localhost:8081/api/params/$PROJECT/?host=api\.target\.com&sus=IDOR" \
  > idor_params.txt

# All API paths for directory brute-forcing
curl -s "http://localhost:8081/api/paths/$PROJECT/?q=/api/" \
  > api_paths.txt
```
