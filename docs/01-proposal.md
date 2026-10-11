# Proposal for Story Shelf

## Contents

1. [The problem, in one sentence](#the-problem-in-one-sentence)
2. [Who it is for](#who-it-is-for)
3. [Core features](#core-features)
4. [Out of scope, and why](#out-of-scope-and-why)
5. [Screens](#screens)
6. [Data the app remembers, and where it is saved](#data-the-app-remembers-and-where-it-is-saved)
7. [Risks](#risks)
8. [Changes since the last version](#changes-since-the-last-version)

## The problem, in one sentence
People who read books and comics or watch movies, dramas, anime, and other series often keep their progress, ratings, and personal thoughts scattered across different apps or rely on memory, making it difficult to remember what they experienced and how they felt about it.

## Who it is for
This app is for people who regularly read and watch different types of stories, such as books, manga, manhwa, webtoons, movies, dramas, anime, and TV series, and want one personal place to organize, remember, and journal their feelings about them.

Instead of using separate tracking apps for different media or relying on memory and notes, users can keep their stories, progress, ratings, and personal journal entries together in one app.

Story Shelf groups everything into four mediums so the library stays simple: **Book**, **Comic** (manga, manhwa, webtoons), **Movie**, and **Series** (dramas, anime, TV shows). Searching for "manga" finds Comics and searching for "anime" finds Series.

## Core features
| # | Feature | Still in the MVP? | Flutter pieces it needs | Honest estimate |
|---|---|---|---|---:|
| 1 | Add and Track Stories, with a **catalog search** (Open Library, AniList, TMDB) that pre-fills the form, or manual entry | Keep (expanded) | Form, TextFormField, DropdownButtonFormField, `image_picker` cover upload, `http` for catalog APIs, debounced search, ElevatedButton, Card, ListTile, Navigator.push | 5 hrs |
| 2 | Organize Story Library: medium, status and favorites filters that combine, plus sort (A–Z or last read) | Keep | GridView/ListView.builder, `StoryPosterCard`, ChoiceChip, modal bottom sheet, IconButton, Story model class | 4 hrs |
| 3 | View Story and Memory Details: story banner with progress, rating and status; memory page that **autosaves** | Keep (reworked) | SingleChildScrollView, Stack, Card, Column, Row, debounce Timer, save-state indicator, Navigator.push | 4 hrs |
| 4 | Add Story/Memory: journal-style memory with entry type and number, optional title, rating, **mood**, and favorite quote | Keep (reworked) | TextField, bottom sheet, `MoodPicker`, Slider/rating, "Discard this memory?" dialog, Memory model class | 4 hrs |
| 5 | Search and filter: one shared search bar in **Library** and **Memories**, with medium, date and mood filters and newest/oldest sort | Keep (moved) | `AppSearchBar`, ListView.builder, ChoiceChip, DropdownButton/bottom sheet, filtering logic | 4 hrs |

All five core features are built and working in the deployed app.

## Out of scope, and why
Three items from the original stretch list were built after the core flow worked, and two were left out.

**Built after the MVP**
1. **Home Highlights** – The Home screen shows "A Memory From This Day" (it picks memories from up to two different stories and gives the same answer all day), "Continue your stories" with progress bars, and "Recent memories."
2. **Dashboard and Statistics** – The Profile screen shows Stories, Completed and Memories counts, the user's most common mood, and a "Stories by Medium" breakdown.
3. **Accessibility settings** – Text size (small, medium, large) and a high-contrast mode, saved to the account and applied on every sign-in. This was not in the original plan.

**Still out of scope**
1. **Custom Collections** – Users could create groups such as "Favorite Books," "Comfort Movies," or "Stories to Watch Together." The Library's favorites, medium and status filters cover most of this need for now.
2. **Local notification reminders** – A retention nudge that is not required for the core loop of **add story → track progress → write memory**.

**Known limitations I am accepting for now:** the app needs a network connection (no offline mode), lists do not refresh on pull-down, movies are tracked by status only (no minutes watched), and automated test coverage is small.

## Screens
The plan grew from 12 screens to 16, and the finished app has **17**: Start, Log In, Reset Password, Sign Up, Home, Library, **Story Search (find a story to add)**, Add Story, Story Details, Edit Story, Add Memory, Memory Details, Memories, Profile, Edit Profile, and Settings. (Edit Memory was dropped because editing now happens on the Memory Details page.)

The bottom navigation changed from Home / Library / Search / Profile to **Home / Library / Memories / Profile**, with a page-flip animation between tabs. Search now lives inside Library and Memories instead of being its own tab.

## Data the app remembers, and where it is saved
Story Shelf uses **Supabase** (Auth, Postgres and Storage). Every user has their own stories, progress, ratings, and memories, protected by Row Level Security.

| Data | Fields | Where it is saved |
|---|---|---|
| **Story** | `story_id`, `user_id`, `title`, `creator_author`, `release_year`, `medium` (book, comic, movie, series), `cover_image_or_color`, `status` (not started, in progress, completed), `current_progress`, `total_progress`, `rating`, `favorite`, `overview`, `date_added`, `last_read_at` | `stories` table, Supabase (Postgres) |
| **Memory** | `memory_id`, `story_id` (FK), `entry_type` (overall review, chapter, episode, volume), `progress_reference`, `rating`, `title`, `content`, `quote`, `mood` (moved, warm, cried, hyped, cozy, shocked), `date_created` | `memories` table, Supabase (Postgres) |
| **Account and preferences** | email and password (handled by Supabase Auth, never stored as a normal field), `name`, `username`, `avatar_url`, `text_size`, `high_contrast` | Supabase Auth account metadata (there is **no separate `profiles` table**) |
| **Cover images and avatars** | uploaded image files | `covers` storage bucket, in a folder named after the user's ID |
| **Catalog search results** | title, creator, year, cover link, total chapters/episodes/pages | Not stored. Fetched live from Open Library (books), AniList (comics) and TMDB (movies and series) while the user searches |

The `user_id` connects a story to its owner, and `story_id` connects each memory to its story, so one story can have many memories. The `delete_user` database function removes an account, and its stories and memories are deleted with it through `ON DELETE CASCADE`.

## Risks
### 1. Linking memories to the correct story — resolved
Each story can have multiple memories, and a memory can describe the overall story or a specific chapter, episode, or volume. This is handled with a `story_id` foreign key plus `entry_type` and `progress_reference`, and a memory is loaded together with its story in one joined query. Row Level Security on `memories` checks that the memory's story belongs to the signed-in user. Tested with one story and multiple memories, and with two separate accounts (neither could see the other's data).

### 2. Keeping the scope manageable — mostly resolved
The Story → Memory → Library flow was finished first, and stretch features were only started after it worked. Repeated code was reduced by combining Add and Edit Memory into the Memory Details page, and by sharing widgets such as `EmptyState`, `ProfileAvatar`, `StoryPosterCard` and `AppSearchBar`. The two remaining out-of-scope features (collections and reminders) stay out.

### 3. Depending on outside catalog services — new
The catalog search relies on Open Library, AniList and TMDB. If one is slow or down, search fails, and the TMDB key is readable in the deployed web build because it is sent with each request.

**Mitigation:** every search has a 10-second timeout and shows a friendly error, and **"Can't find it? Add manually"** is always available. The TMDB key is a free, read-only key that can be revoked and replaced. This is documented in `docs/06-security-and-privacy.md`.

## Changes since the last version
- **September 20, 2026** – The proposal was revised after gaining more Flutter experience. The main functions remained, but related functions were combined to reduce repeated UI and navigation work.
- **September 20, 2026** – The screen plan changed from 12 screens to 16 screens. New screens were added for Start, Reset Password, Edit Story, Memory Details, Edit Memory, and Edit Profile, while Story Details was simplified.
- **September 20, 2026** – Supabase was selected as the storage solution, with Profile, Story, and Memory tables to support the relationships between users, stories, and multiple memories.
- **September 20, 2026** – Project scope was added as a second major risk alongside the existing risk of correctly linking stories and memories.
- **September 22, 2026** – Coding started for the first four screens: Start, Login, Reset Password, and Sign Up, along with `SupabaseService` for authentication.
- **Week 2 (September 27 – October 3, 2026)** – Home, Library, and Story Details were finished. The theme was unified and the bottom navigation was reworked into a floating bar.
- **Week 3 (October 4 – 9, 2026)** – All screens were built and the app was connected fully to Supabase; the sample data file was removed. Changes from the earlier plan:
  - **Mediums simplified** from seven (book, manga, manhwa, movie, drama, anime, TV series) to four (Book, Comic, Movie, Series). Older saved values still load correctly.
  - **Profile table dropped.** Name, username, avatar and settings are stored in the Supabase Auth account metadata instead. The planned profile `quote` and `themeMode` fields were not built; text size and high contrast replaced theme mode.
  - **Search moved** from its own tab into Library and Memories, and the nav bar became Home / Library / Memories / Profile.
  - **Edit Memory removed.** Memory Details now autosaves as you type; Add Memory saves on Save and asks before discarding unsaved writing.
  - **New fields:** `quote` and `progress_reference` on memories, and `last_read_at` on stories, used for the "last read" sort.
  - **Real cover upload** with `image_picker` (gallery or camera) and a Supabase Storage `covers` bucket, replacing the paste-a-URL dialog. A pasted link still works.
  - **Stretch features built:** Home highlights, profile statistics, text size, and high contrast.
- **October 11, 2026** – **Mood added to memories.** Each memory can be tagged with one of six moods: 💖 Moved, 🧸 Warm, 😿 Cried, 🔥 Hyped, 🌧️ Cozy, or 🙀 Shocked. In Add Memory the moods are selectable chips, while Memory Details uses a bottom-sheet picker to keep the notes-style page clean, and a chosen mood can be cleared. The mood is saved in a new `mood` column on `memories`, shown on memory cards with a reusable mood badge, usable as a filter in the Memories tab, and counted in the "Your most common mood" statistic on Profile. This supports the app's main purpose of remembering how a story made the reader feel.
- **October 11, 2026** – **Story Search added.** Users can now search books (Open Library), comics (AniList), and movies or series (TMDB) when adding a story, and pick a result to pre-fill the Add Story form with the title, year, creator, cover, medium and total chapters, episodes or pages when available. Everything can still be reviewed and edited before saving, and manual entry stays available because a search may not find every story. A result already on the shelf opens its existing story instead of creating a duplicate. This added the `http` package and a `TMDB_API_KEY` setting (kept in `.env`, documented in `.env.example`, and stored as a GitHub Actions secret for deployment).
