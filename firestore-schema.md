# Firestore Schema — e-z.rsvp

The app ships in **demo mode** (in-memory `MockBackend`). When you enable
Firebase (`AppConfig.useFirebase = true`), `FirebaseBackend` reads/writes the
collections below. The Swift models in `Sources/Models` are `Codable` and map
1:1 to these documents.

## Collections

### `users/{uid}`
| Field | Type | Notes |
|-------|------|-------|
| id | string | == auth uid |
| name | string | |
| email | string | |
| photoURL | string? | |
| interests | array<string> | Interest raw values |
| city | string | |
| budget | string | "$" / "$$" / "$$$" |
| radiusMiles | number | |
| availability | array<string> | e.g. ["Fri","Sat"] |

### `events/{id}`
| Field | Type | Notes |
|-------|------|-------|
| id | string | |
| title | string | hidden until reveal |
| eventDescription | string | hidden until reveal |
| category | string | EventCategory raw value |
| difficulty | string | Difficulty raw value |
| price | string | PriceTier raw value |
| venueName | string | hidden until reveal |
| generalArea | string | shown in feed |
| latitude / longitude | number | hidden until reveal |
| eventTime | timestamp | |
| revealTime | timestamp | |
| distanceMiles | number | |
| interests | array<string> | for matching |
| clues | array<map> | `{ id, text, symbol, unlocksDaysBefore }` |
| weather | map? | `{ temp, condition, symbol }` |
| imageSymbol | string | SF Symbol hero glyph |

### `groups/{id}`
| Field | Type | Notes |
|-------|------|-------|
| id | string | |
| name | string | |
| symbol | string | SF Symbol |
| ownerID | string | uid |
| inviteCode | string | unique, indexed |
| eventID | string | |
| members | array<map> | `{ user, status, isReady }` |
| polls | array<map> | `{ id, question, options:[{id,label,votes}] }` |

### `rsvps/{id}`
| Field | Type |
|-------|------|
| id | string |
| eventID | string |
| userID | string |
| groupID | string? |
| status | string (going/maybe/pending/declined) |
| createdAt | timestamp |

## Suggested security rules (starter)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /events/{id} {
      allow read: if true;                 // browsing the feed is public
      allow write: if false;               // events curated server-side
    }
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid;
    }
    match /groups/{id} {
      allow read: if true;                 // invite-link friendly
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    match /rsvps/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.data.userID == request.auth.uid;
    }
  }
}
```

## Realtime
Subscribe to `groups/{id}` snapshots to drive the live lobby (member readiness,
poll votes). Subscribe to `events` for newly published mysteries.
