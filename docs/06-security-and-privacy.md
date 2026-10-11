# Security and privacy

This repository is public. This page is honest about what the app stores, where the secrets are, and what is still open.

**Last checked:** 2026-10-11

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Email and password | Supabase Auth (the password is stored hashed by Supabase, never by my code) | Only that user. I can see the email in my Supabase dashboard as the project owner |
| Display name, username, avatar link, text size, high-contrast setting | The user's account metadata in Supabase Auth (there is no separate `profiles` table) | Only that user |
| Stories (title, creator, year, medium, status, progress, rating, favorite, cover) | `stories` table in Supabase, tied to the user's ID | Only that user (Row Level Security, see below) |
| Memories (journal text, title, entry type, quote, rating, date, mood) | `memories` table in Supabase, tied to the user's story | Only that user (Row Level Security, see below). Memories are private journal writing, so this is the most sensitive data in the app |
| Uploaded cover images and avatars | `covers` storage bucket in Supabase, in a folder named after the user's ID | **Anyone who has the link.** The app uses public URLs (`getPublicUrl`), so these images are not private. The file names contain the user ID and a timestamp, and there is no read policy, so the files cannot be listed through the API |
| Search text typed in "add a story" | Sent to Open Library, AniList and TMDB while searching. Not stored by my app | Those services (they also see the visitor's IP address, as any website does) |
| Cover images shown from other sites | Loaded straight from Open Library, TMDB, AniList or any link a user pastes | The site hosting the image sees the visitor's IP address when it loads |
| Anything on the device | Nothing is saved locally except the Supabase login session kept by `supabase_flutter` | Only that device |

There is no analytics, advertising or tracking code in the app.

## Secrets

- Values my app needs at run time: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `TMDB_API_KEY` (names only; `.env.example` holds placeholders)
- Where they live locally: `.env`, which is git-ignored (`.env` and `.env.*` are in `.gitignore`, and `!.env.example` keeps the example committed)
- Where the deploy workflow gets them: repository secrets (Settings > Secrets and variables > Actions): `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `TMDB_API_KEY`. The workflow writes a `.env` from them at build time and also passes the two Supabase values with `--dart-define`. No secret is written literally in the workflow file.
- Anything my deployed web build carries that a visitor could read, and why that is acceptable:
  - **Supabase URL and publishable key.** Both are designed to be public in a client app. Row Level Security is what protects the data, not hiding them.
  - **TMDB API key.** `pubspec.yaml` lists `.env` under `assets:`, so the file is copied into the web build, and TMDB takes the key as an `api_key=` parameter on each search request, so it is also visible in the browser's network tab. It is a free, read-only v3 key. The worst a stranger can do with it is use up my TMDB rate limit. If I see abuse, I will revoke it in my TMDB account and create a new one.
  - **No secret or service-role key** (`SUPABASE_SECRET_KEY`, `GEMINI_API_KEY`) is used anywhere in the app. Both appear in `.env.example` only as commented-out warnings.

## What protects the data on the service side

Supabase Row Level Security (RLS) is on for both tables, and the app relies on it: queries such as `getAllMemoriesForUser`, `getMemory`, `updateStory` and `deleteStory` do not filter by user in the Dart code.

**Policies checked on 2026-10-11** (output of `pg_policies` in the Supabase SQL editor):

| Table / bucket | Policy | Rule |
| --- | --- | --- |
| `stories` | `own stories` (ALL, authenticated) | `user_id = auth.uid()` for both reading and writing |
| `memories` | `own memories` (ALL, authenticated) | The memory's story must belong to `auth.uid()`, for both reading and writing |
| `covers` bucket | Upload, update and delete policies (authenticated) | Only inside the folder named with the user's own ID (`(storage.foldername(name))[1] = auth.uid()`) |

- RLS is enabled on both tables (checked with a query on `pg_class`). Every policy applies to `authenticated` users only, so signed-out visitors get no access.
- There is no read policy on `storage.objects`, so files cannot be listed through the API; they are reachable only by their direct public link.
- `delete_user()` is a `SECURITY DEFINER` function that runs `delete from auth.users where id = auth.uid()`, so it can only delete the caller.
- Account deletion removes all of a user's stories and memories (both foreign keys use `ON DELETE CASCADE`). Uploaded images in the `covers` bucket are not deleted.

**Two-account test (2026-10-11):** I signed up a second test user in a privat window and added a story and a memory. Neither account could see the other' stories or memories on Home, Library or Memories. Deleting the second accoun removed its stories and memories and left the first account's data untouched.

Other protections:

- **Sign-in is required.** `main.dart` opens the start screen unless a session exists, and the upload function throws if nobody is signed in.
- **Input is checked before it is saved.** The story form validates title, year, medium and status; Add Memory checks that the content is not empty and that chapter, episode and volume entries have a number; image uploads keep only jpg, jpeg, png, webp or gif and fall back to jpg for anything else.
- **Deleting an account** asks for confirmation, then calls `delete_user` and signs the user out.

## Known gaps

- Cover images and avatars are public by link, and are not deleted from storage when a story or account is deleted.
- Profile details live in account metadata, so usernames are not enforced as unique and other users' profiles can't be shown. That suits a private app.
- The TMDB key is readable in the deployed build (see Secrets).
- The deployed demo runs inside the `device_preview` phone frame (`enabled: true` in `main.dart`), which is a development tool.
- The workflow uses version tags (`@v7`, `@v2`, `@v5`) for third-party actions instead of commit SHAs.
- My real name is in the README author line and in my commits. New commits use my GitHub noreply email; older commits still show my Gmail address in the Git author information. I accepted that.

## Checklist

- [x] `.env` (or `env.json`) is in `.gitignore`, and `.env.example` is committed
- [x] `git log -p | grep -i "api_key\|secret\|password\|token"` finds nothing real (searched the full history on 2026-10-11; see the note below)
- [x] No service account file, keystore or `service_role` key anywhere in the repo
- [x] Security rules or RLS policies written and tested, not left open (RLS is on for `stories` and `memories`; policies checked in the SQL editor and tested with two accounts on 2026-10-11)
- [x] No real personal data in sample data, screenshots or the video
- [x] No course or university credentials anywhere (checked 2026-10-11: the README names the course and university, but no HAU login, password, student number or student email appears in the files, commits, screenshots or video)
- [x] Anyone whose data appears in a test was asked first

**Found on 2026-10-11:** `.env` is bundled into the web build as an asset, so the TMDB key is readable on the deployed site (it is also visible in the network tab, since TMDB takes the key as a URL parameter). Decision: I am keeping it. It is a free, read-only v3 key, and the worst case is someone using up my rate limit. I will revoke it in my TMDB account and create a new key if I see abuse. No Supabase secret or service-role key is in the build.
