# Proposal for Story Shelf

## The problem, in one sentence
People who read books and manga or watch movies, dramas, anime, and other stories often keep their progress, ratings, and personal thoughts scattered across different apps or rely on memory, making it difficult to remember what they experienced and how they felt about it.

## Who it is for
This app is for people who regularly read and watch different types of stories, such as books, manga, manhwa, movies, dramas, anime, and TV series, and want one personal place to organize, remember, and journal their feelings about them.

Instead of using separate tracking apps for different media or relying on memory and notes, users can keep their stories, progress, ratings, and personal journal entries together in one app.


## Core features
| # | Feature | Still in the MVP? | Flutter pieces it needs | Honest estimate |
|---|---|---|---|---:|
| 1 | Add and Track Stories | Keep | Form, TextFormField, DropdownButtonFormField, ElevatedButton, Card, Row, Column, ListTile, Navigator.push | 5 hrs |
| 2 | Organize Story Library | Keep | ListView.builder, Card, ListTile, ChoiceChip, DropdownButton, IconButton, story model class, Navigator.push | 4 hrs |
| 3 | View Story/Memory Details | Keep | SingleChildScrollView, Card, Column, Row, ListTile, ChoiceChip, IconButton, Navigator.push | 4 hrs |
| 4 | Add Story/Memory | Keep | Form, TextFormField, DropdownButtonFormField, Slider, ChoiceChip, Switch, ElevatedButton, SingleChildScrollView, memory model class | 4 hrs |
| 5 | Search Stories | Keep | TextField, ListView.builder, Card, ChoiceChip, DropdownButton, story model class, filtering logic | 4 hrs |

## Out of scope, and why
1. **Custom Collections** – Users can create collections and organize stories into groups such as “Favorite Books,” “Comfort Movies,” or “Stories to Watch Together.”
2. **Home Highlights** – The home screen can show a “Memory of the Day,” recent memories, and stories the user is currently watching or reading.
3. **Dashboard and Statistics** – The profile can show simple statistics such as completed stories and stories by medium.

These are out of scope for the core MVP because the app can still fully function without them. The local notification feature is specifically a retention nudge and is not required for the core loop of **add story → track progress → write memory**.

## Data the app remembers, and where it is saved
Story Shelf uses **Supabase (Postgres)** to store its data. The app is designed so that each user has their own stories, progress, ratings, and memories.

| Data | Fields | Where it is saved |
|---|---|---|
| **Story** | `id`, `title`, `creator`, `releaseYear`, `medium`, `coverPath`, `status`, `currentProgress`, `totalProgress`, `rating`, `isFavorite`, `overview`, `dateAdded` | `stories` table, Supabase (Postgres) |
| **Memory** | `id`, `storyId` (FK), `entryType`, `rating`, `title`, `content`, `dateCreated` | `memories` table, Supabase (Postgres) |
| **User/Profile/Settings** | `name`, `quote`, `email`, `password/auth token`, `profilePicturePath`, `themeMode` | `profiles` table, Supabase (Postgres), one row per `auth.users.id` |

The `user_id` connects a user's profile to their stories, while `story_id` connects each memory to the story it belongs to. Passwords are handled by the authentication system rather than being stored as a normal Profile field.

## Risks
### 1. Linking memories to the correct story

Each story can have multiple memories, and memories can represent either the overall story or a specific chapter, episode, or volume. If the relationship is not designed correctly, memories could appear under the wrong story or the progress information could become confusing.

**First step:** Create and test one Story with multiple Memory records during the Supabase storage spike.

**Target date:** September 21, 2026.

### 2. Keeping the scope manageable

Having too many separate screens can increase the amount of repeated code and navigation work. The original proposal had twelve screens, including separate Story Details screens, separate New Memory screens, and a separate Search screen.

**First step:** Build the six main story-related functions first and keep the MVP requirements fixed. Stretch goals will not be started until the main **Story → Memory → Library** flow is working correctly.

**Target date:** September 23, 2026.

## Changes since the last version
- **September 20, 2026** – The proposal was revised after gaining more Flutter experience. The main functions remained, but related functions were combined to reduce repeated UI and navigation work.
- **September 20, 2026** – The screen plan changed from 12 screens to 16 screens. New screens were added for Start, Reset Password, Edit Story, Memory Details, Edit Memory, and Edit Profile, while Story Details was simplified.
- **September 20, 2026** – Supabase was selected as the storage solution, with Profile, Story, and Memory tables to support the relationships between users, stories, and multiple memories.
- **September 20, 2026** – Project scope was added as a second major risk alongside the existing risk of correctly linking stories and memories.
- **September 22, 2026** – Coding started for the first four screens: Start, Login, Reset Password, and Sign Up. Other files needed was also accomplished.
