# Supabase Schema — e-z.rsvp

The app ships in **demo mode** (in-memory `MockBackend`). When you enable
Supabase (`AppConfig.useSupabase = true`), `SupabaseBackend` reads/writes the
tables below over PostgREST. The Swift models in `Sources/Models` are `Codable`
and map 1:1 to these rows — keep the column names matching the models' coding
keys (camelCase) or add a renaming `JSONDecoder` in `SupabaseBackend`.

## Tables

### `profiles`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | == `auth.users.id` |
| name | text | |
| email | text | |
| photoURL | text null | |
| interests | text[] | Interest raw values |
| city | text | |
| budget | text | "$" / "$$" / "$$$" |
| radiusMiles | numeric | |
| availability | text[] | e.g. {"Fri","Sat"} |

### `events`
| Column | Type | Notes |
|--------|------|-------|
| id | text (PK) | |
| title | text | hidden until reveal |
| eventDescription | text | hidden until reveal |
| category | text | EventCategory raw value |
| difficulty | text | Difficulty raw value |
| price | text | PriceTier raw value |
| venueName | text | hidden until reveal |
| generalArea | text | shown in feed |
| latitude / longitude | numeric | hidden until reveal |
| eventTime | timestamptz | |
| revealTime | timestamptz | |
| distanceMiles | numeric | |
| interests | text[] | for matching |
| clues | jsonb | `[{ id, text, symbol, unlocksDaysBefore }]` |
| weather | jsonb null | `{ temp, condition, symbol }` |
| imageSymbol | text | SF Symbol hero glyph |

### `groups`
| Column | Type | Notes |
|--------|------|-------|
| id | text (PK) | |
| name | text | |
| symbol | text | SF Symbol |
| ownerID | uuid | == `auth.users.id` |
| inviteCode | text unique | indexed |
| eventID | text null | |
| members | jsonb | `[{ user, status, isReady }]` |
| polls | jsonb | `[{ id, question, options:[{id,label,votes}] }]` |

### `rsvps`
| Column | Type |
|--------|------|
| id | text (PK) |
| eventID | text |
| userID | uuid |
| groupID | text null |
| status | text (going/maybe/pending/declined) |
| createdAt | timestamptz |

## Row-level security (starter)

```sql
alter table profiles enable row level security;
alter table events   enable row level security;
alter table groups   enable row level security;
alter table rsvps    enable row level security;

-- events: browsing the feed is public; rows are curated server-side
create policy "events readable" on events for select using (true);

-- profiles: any signed-in user can read; you can only write your own
create policy "profiles readable" on profiles for select
  using (auth.role() = 'authenticated');
create policy "own profile writable" on profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);

-- groups: invite-link friendly reads; signed-in users can create/update
create policy "groups readable" on groups for select using (true);
create policy "groups writable" on groups for insert
  with check (auth.role() = 'authenticated');
create policy "groups updatable" on groups for update
  using (auth.role() = 'authenticated');

-- rsvps: you can only touch your own
create policy "rsvps readable" on rsvps for select
  using (auth.role() = 'authenticated');
create policy "own rsvps writable" on rsvps for all
  using (auth.uid() = "userID") with check (auth.uid() = "userID");
```

## Account deletion RPC

The anon key can't delete an `auth.users` row, so `SupabaseBackend.deleteAccount`
calls this `SECURITY DEFINER` function, which deletes the **calling** user:

```sql
create or replace function delete_account()
returns void
language sql
security definer
set search_path = public
as $$
  delete from auth.users where id = auth.uid();
$$;

revoke all on function delete_account() from public;
grant execute on function delete_account() to authenticated;
```

## Realtime
Subscribe to the `groups` table to drive the live lobby (member readiness, poll
votes). Subscribe to `events` for newly published mysteries.
