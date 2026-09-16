# Snippets Content — Data Flow & Static File Schema

How the app loads its learning content (categories, card groups, and code snippet cards) from a remote host, with versioning, caching, and an offline fallback.

## Data flow

```
App launch (python_flashApp.swift → contentStore.start())
   │
   ├─ 1. INSTANT load (0–10ms): read disk cache, else bundled fallback → state = .ready (UI shown)
   │
   └─ 2. BACKGROUND: fetch manifest.json (fresh, no cache)
          │
          ├─ remote.version ≤ localVersion  → done, keep current content
          ├─ manifest.minAppVersion > appVersion → incompatible, skip silently
          └─ remote.version > localVersion → download Category/CardGroup/Card files (concurrent)
                 │
                 ├─ validate by decoding all three; any failure → abort, keep old content
                 ├─ atomic commit to cache (all-or-nothing)
                 ├─ bump localVersion (@AppStorage "contentVersion")
                 └─ publish new content → UI refreshes
```

**Guarantees:** the app never blocks on the network, always has usable content (cache → bundle), and a failed/partial download never replaces good content.

### Key files
| File | Role |
|------|------|
| `Content/ContentStore.swift` | Orchestrates the flow + state machine |
| `Content/ContentService.swift` | Networking (manifest + file fetch) |
| `Content/ContentManifest.swift` | `Codable` contract for `manifest.json` |
| `Content/ContentCache.swift` | Atomic disk persistence |
| `Content/AppConfig.swift` | Base URL, app version, manifest name |
| `Models/Category.swift`, `CardGroup.swift`, `Card.swift` | Decoded content models |
| `Data/*.json` | Bundled fallback (first run / offline) |

### Cache location
`~/Library/Application Support/Content/live/` — holds `Category.json`, `CardGroup.json`, `Card.json`. Survives disk pressure, excluded from iCloud backup.

## Static files required on the host

Base URL is set in `AppConfig.swift`:

```swift
static let contentBaseURL = URL(string: "https://cdn.example.com/pylab/")!
```

Expected layout (file paths come from the manifest, so versioned folders are a convention, not a requirement):

```
{contentBaseURL}/
├── manifest.json          ← fetched fresh on every launch
└── v3/
    ├── Category.json
    ├── CardGroup.json
    └── Card.json
```

### `manifest.json`
The only file with a fixed name/location. Controls versioning and points to the three content files (relative to `contentBaseURL`).

```json
{
  "version": 3,
  "minAppVersion": 1,
  "files": {
    "categories": "v3/Category.json",
    "cardgroups": "v3/CardGroup.json",
    "cards": "v3/Card.json"
  }
}
```

| Field | Type | Meaning |
|-------|------|---------|
| `version` | Int | Content version. App downloads only when this exceeds the locally cached version. Increment on every content update. |
| `minAppVersion` | Int | Minimum `AppConfig.appVersion` required. Content is skipped if the app is older. Bump when the model shape changes. |
| `files.categories` / `.cardgroups` / `.cards` | String | Paths (relative to base URL) to the three content files. |

### `Category.json` — array, no wrapper
```json
[
  {
    "id": 1,
    "tag": "fundamentals",
    "title": "Data Types",
    "description": "Discover the magic of data types…",
    "is_premium": false
  }
]
```
| Field | Type | Notes |
|-------|------|-------|
| `id` | Int | Unique. Referenced by `CardGroup.category_id`. |
| `tag` | String | UI tab filter, e.g. `fundamentals`, `mastery`, `hands-on`. |
| `title` | String | |
| `description` | String | |
| `is_premium` | Bool | |

### `CardGroup.json` — array, no wrapper
```json
[
  {
    "id": 1,
    "title": "String",
    "total_cards": 20,
    "category_id": 1,
    "description": "Strings are like the words and sentences for computers…"
  }
]
```
| Field | Type | Notes |
|-------|------|-------|
| `id` | Int | Unique. Referenced by `Card.cardgroup_id`. |
| `title` | String | |
| `total_cards` | Int | |
| `category_id` | Int | FK → `Category.id`. |
| `description` | String | |

### `Card.json` — array, no wrapper (the snippets)
```json
[
  {
    "id": "5fc91c7a16279a3e94f7fc6a",
    "cardgroup_id": 1,
    "title": "Concatenation",
    "description": "Concatenate two strings to combine them into one.\n\nUses the `+` operator.",
    "syntax": "str1 = 'Hello'\nstr2 = 'World'\nresult = str1 + ' ' + str2\nprint(result)",
    "output": "Hello World"
  }
]
```
| Field | Type | Notes |
|-------|------|-------|
| `id` | String | Unique (MongoDB ObjectId style). Note: **String**, not Int. |
| `cardgroup_id` | Int | FK → `CardGroup.id`. |
| `title` | String | |
| `description` | String | Supports `\n` for line breaks; Markdown inline (e.g. `` `code` ``). |
| `syntax` | String | The Python code snippet. Use `\n` for multiline. |
| `output` | String | Expected program output. |

## Publishing an update
1. Upload the new `Category.json`, `CardGroup.json`, `Card.json` (e.g. into a `v4/` folder).
2. Update `manifest.json`: bump `version` and point `files.*` at the new paths.
3. If the model shape changed, also bump `minAppVersion` (and `AppConfig.appVersion` in a new app build).

All three content files are top-level JSON arrays with **no wrapping object**. Every referential `id`/`*_id` must line up across the three files.
