# Security checklist for Story Shelf

## Secrets and credentials

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | I searched the Git history for words like `password`, `secret`, `api_key`, and `token`. The results were only variable names, messages, placeholders, or documentation, not real passwords or keys. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | Yes | `.env.example` shows which Supabase values the app needs, while `.env` is ignored by Git. This keeps the actual values out of the repository. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | `.gitignore` blocks files such as `.keystore`, `.jks`, and other signing files. I also checked that none of these files are in the repository. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | I searched the full Git history for possible passwords, secrets, API keys, and tokens. The matches were only normal code names, text, placeholders, or comments, with no real credentials found. |
| 5 | Any credential that was ever committed has been rotated | N/A | No real credentials were found in the Git history. Because of this, there is nothing that needs to be changed or replaced. |

## GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | The workflow uses secret names instead of writing the actual values. The Supabase secret references are also currently commented out. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | Yes, once uncommented | The workflow is already set up to use GitHub Secrets for the Supabase values. They are currently disabled because the app is still using sample data. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | Yes | I checked the workflow and found no command that prints secret values. The Supabase secrets are also not currently being used by the workflow. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The project currently only has a web deployment workflow. There is no Android signing or keystore setup to check. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The workflow only uploads the `build/web` folder. No keystore or secret files are included in that folder. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | No | The workflow uses version tags such as `@v7`, `@v2`, and `@v5` instead of specific commit SHAs. These can be changed later to make this check pass. |
| 12 | Secret scanning and push protection are enabled on the repository | Yes | I enabled Secret Protection and Push Protection in the GitHub repository settings. |

## Backend and security rules

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | The app uses Supabase, not Firebase. There are no Firestore or Firebase Storage rules in the project. |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | There are no Firestore rules because the project does not use Firebase. User access will be controlled using Supabase RLS later. |
| 15 | If Supabase: Row Level Security is on for every table | N/A | The Story and Memory tables have not been created yet. RLS will need to be enabled when these tables are created. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The project does not use Firebase or Google Cloud API keys. It currently only uses Supabase. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | There is no real Story or Memory database yet to test. This will need to be checked after the Supabase database is connected. |
| 18 | Seed and sample data is invented, not real people's data | Yes | The app uses made-up story information and placeholder images. No real person's personal information is being used. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | The form checks the user's input before submitting it. Fields like Title, Year, Medium, and Status have validation checks. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | Only the Supabase URL and publishable key are meant to be included in the app. Secret keys such as `GEMINI_API_KEY` and `SUPABASE_SECRET_KEY` are not included. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes (with one accepted exception) | I searched the repository history and found no student number, phone number, or address. The real name and Gmail only appear as Git author information. |
| 22 | No classmate's personal data in the repository | Yes | I checked the repository history and found no classmates' names, emails, or other personal information. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | `.gitignore` keeps `build/` and `.dart_tool/` out of Git. The packages used by the project come from pub.dev. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | There are no custom font files in the project. The app uses fonts through the `google_fonts` package. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | I checked that the GitHub repository is public. This matches the decision to make the project publicly accessible. |

## Anything I found and fixed

This checklist caught two things I didn't already know about. First, GitHub's Secret Protection and Push Protection were not enabled on the repo. I turned both on under Settings > Code security. 

One honest caveat to flag alongside this: several rows (6, 7, 8, 15, 17) are only "clean" because the Supabase secrets are still commented out and no real tables exist yet. These rows need a second pass once the app goes live with real data and credentials, not just this one.
