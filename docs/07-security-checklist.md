# Security checklist for Story Shelf

**Last checked:** 2026-10-11

## Contents

1. [Secrets and credentials](#secrets-and-credentials)
2. [GitHub Actions](#github-actions)
3. [Backend and security rules](#backend-and-security-rules)
4. [Input and app surface](#input-and-app-surface)
5. [Repository and privacy](#repository-and-privacy)
6. [Anything I found and fixed](#anything-i-found-and-fixed)

See also [`06-security-and-privacy.md`](06-security-and-privacy.md) for what the app stores, the Supabase policies and the known gaps.

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | I searched the Git history for `password`, `secret`, `api_key` and `token`. The results were only variable names, messages, placeholders or documentation, not real passwords or keys. `TMDB_API_KEY` appears in the code only as a name read from `.env`, and in `.env.example` as a placeholder. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | Yes | `.env.example` shows which values the app needs (Supabase URL, publishable key and the TMDB key), while `.env` is ignored by Git. This keeps the actual values out of the repository. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | `.gitignore` blocks files such as `.keystore`, `.jks`, and other signing files. I also checked that none of these files are in the repository. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | On 2026-10-11 I searched the full Git history for `api_key`, `secret`, `password`, `token` and `key` followed by a long value, for JWT-style strings (`eyJ...`), Supabase key prefixes and 32-character hex strings. All matches were variable names, error messages, documentation or placeholders. `.env` was never committed (`git log --all -- .env` is empty). |
| 5 | Any credential that was ever committed has been rotated | N/A | No real credentials were found in the Git history. Because of this, there is nothing that needs to be changed or replaced. |

## GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | The workflow uses secret names instead of writing the actual values. The workflow now reads `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `TMDB_API_KEY` from repository secrets. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | Yes | Confirmed on 2026-10-11 that `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `TMDB_API_KEY` exist under Settings > Secrets and variables > Actions, and the workflow reads them with `${{ secrets.NAME }}`. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | Yes | I checked the workflow and found no command that prints secret values. Opened the log of the latest deploy run on 2026-10-11. In the "Create .env from secrets" step the values appear as `***`, and the "Build web" step prints no secret values. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The project currently only has a web deployment workflow. There is no Android signing or keystore setup to check. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The workflow only uploads the `build/web` folder. No keystore or secret files are included in that folder. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | Yes | Pinned all four third-party actions (`actions/checkout`, `subosito/flutter-action`, `actions/upload-pages-artifact`, `actions/deploy-pages`) to full commit SHAs on 2026-10-11, with the version tag kept in a comment. The deploy still runs green. |
| 12 | Secret scanning and push protection are enabled on the repository | Yes | I enabled Secret Protection and Push Protection in the GitHub repository settings. |

## Backend and security rules

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | The app uses Supabase, not Firebase. There are no Firestore or Firebase Storage rules in the project. |
| 14 | Rules restrict a user to their own documents where that makes sense | Yes | Checked in the Supabase SQL editor on 2026-10-11. `stories` has one policy (`user_id = auth.uid()`), `memories` has one that requires the memory's story to belong to `auth.uid()`, and `covers` uploads, updates and deletes are limited to the user's own folder. All policies apply to signed-in users only. |
| 15 | If Supabase: Row Level Security is on for every table | Yes | A query on `pg_class` on 2026-10-11 showed RLS enabled on `stories` and `memories`, the only two tables in the `public` schema. The policies are in `docs/06-security-and-privacy.md`. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The project does not use Firebase or Google Cloud API keys. It currently only uses Supabase. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | Yes | Tested on 2026-10-11. Requesting `stories` and `memories` through the Supabase REST API with only the publishable key returned no rows (`[]`), and a write was rejected with 401. I also tested with a second account: neither account could see the other's stories or memories, and deleting the second account removed only its own data. |
| 18 | Seed and sample data is invented, not real people's data | Yes | The sample data file was deleted when I moved to Supabase. The app now shows data from the database; story search results come from public catalog sites (Open Library, AniList, TMDB). I checked the screenshots and the demo video, and they show only my own test account. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | The form checks the user's input before submitting it. Fields like Title, Year, Medium, and Status have validation checks. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Partly | The Supabase URL and publishable key are meant to be public. `.env` is listed as an asset in `pubspec.yaml`, so the built web app also contains the `TMDB_API_KEY` (a free key; see `docs/06-security-and-privacy.md`). Secret keys such as `GEMINI_API_KEY` and `SUPABASE_SECRET_KEY` are not included. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes (with accepted exceptions) | I searched the repository history and found no student number, phone number, home address or school login. My real name is in the README author line and in my commits. New commits use my GitHub `noreply` email; older commits still show my Gmail address in the Git author information. I accepted both. |
| 22 | No classmate's personal data in the repository | Yes | I checked the repository history and found no classmates' names, emails, or other personal information. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | `.gitignore` keeps `build/` and `.dart_tool/` out of Git. The packages used by the project come from pub.dev. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes, with one caveat | The app uses Montserrat through the `google_fonts` package. Railey (`docs/assets/fonts/Railey-PersonalUse.ttf`) is a custom font with a personal-use licence; it is credited in the README. The logo and wordmark are my own. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | I checked that the GitHub repository is public. This matches the decision to make the project publicly accessible. |

## Anything I found and fixed

This checklist caught three things I didn't know about.

1. GitHub's Secret Protection and Push Protection were not enabled on the repo. I turned both on under Settings > Code security.
2. On 2026-10-11 I found that `.env` is bundled into the web build as an asset, so the free TMDB key is readable on the deployed site and visible in the network tab. Decision: I am keeping it, because the worst case is someone using up my rate limit. I will revoke it and create a new key if I see abuse. No Supabase secret or service-role key is in the build. See `docs/06-security-and-privacy.md`.
3. My Gmail address appeared in the Git author information of my commits. I switched to my GitHub `noreply` address for new commits. Older commits keep the Gmail, and I accepted that rather than rewrite history, which would break the commit links in `AI-USAGE.md`.

Checked on 2026-10-11 now that the app uses real data and credentials: RLS is on and the policies are correct (rows 14 and 15), a second account cannot see the first account's data, signed-out requests return no rows (row 17), the workflow logs show secrets masked (row 8), all three secrets exist (row 7), and the third-party actions are pinned to commit SHAs (row 11).

Nothing is left open from this checklist.
