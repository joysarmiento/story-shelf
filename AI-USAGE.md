# AI usage


## 1. How I used AI

> **Note:** I started this log late. I reconstructed these entries on 2026-10-03 from my commit history and my chat history, and finished them on 2026-10-09. Entry dates are the dates of the commits where the work landed, and each entry describes something I really did.

### 2026-09-23 - Planning and building the authentication screens

- **Tool:** Claude
- **What I asked for:** Help planning and implementing the authentication screens for Story Shelf: Start, Log In, Sign Up, and Reset Password.
- **What it gave back:** Flutter widget structures, reusable text fields and buttons, and Supabase authentication logic.
- **What I kept, what I changed, and why:** I kept some of the suggested structure and the overall Supabase authentication approach. I changed the wording, font sizes, content, and mainly the UI of every screen so it matches my Story Shelf design. The AI also gave me a first version of `app_theme.dart`, and its styling didn't fit my project, so it became the file I rewrote the most. After the first commit I reworked the text styles myself, with a little help from online sources: I connected my own fonts and added the high-contrast and text-size settings (see Section 3). I added my own chosen font and my own logo instead of the defaults. I haven't changed the Supabase logic itself. I only set up my own Supabase project and added the `.env` file with my own keys.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/fe1109360f0a9b980be32491a41daffc23956925

### 2026-09-27 - Home and Library Screens

> **Note:** I forgot to update the date after copying the format of my first entry. The correct date can be confirmed through the commit link. I also initially left out that AI provided the first versions of the models and navigation, which I have now added. My own changes to these are explained in Section 3.

- **Tool:** Claude
- **What I asked for:** Help planning and implementing the Home and Library Screens.
- **What it gave back:** Flutter widget structures, a first version of the navigation between the screens, a first version of the story and memory models, and the Home and Library screens themselves.
- **What I kept, what I changed, and why:** I kept some of the suggested structure and the overall screen layouts. I replaced the text headers ("Your Shelf" and "Library") with images so they use the custom font I wanted (this was replaced with the Railey font through `app_theme` later in development). I changed the sizes and spacing throughout, and fixed the size of the story poster cards so nothing gets cut off. Some of the information needed for the "memory of the day" section was missing, so I added it and fixed its format. For the sample data, I wrote my own story entries and built that file myself, using online sources for reference. I reworked the story and memory models into the versions in the project now (see Section 3). I also reorganised the navigation into the `AppTab` names and the single `navigateToTab` function, so every screen switches tabs the same way. I rewrote these because the first versions did not fit my data or my screens. The AI's empty states were separate pieces of code on each screen, and I later combined them into one shared `EmptyState` widget (see Section 3). I first connected Supabase in this commit, but I did not carry it over to the other screens until a later commit.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211

### 2026-09-27 - Add Story/Edit Story and Story Details Screens

- **Tool:** Claude
- **What I asked for:** Help build the screens to add a story, edit a story, and view one story in full.
- **What it gave back:** A first version of a shared story form, the Add Story and Edit Story screens that use it, and the Story Details screen.
- **What I kept, what I changed, and why:** I kept the idea of one shared form (`StoryForm`) used by both the Add and Edit screens, so they cannot end up with different fields or validation rules. I changed the form to fit my design and my data. It handles the cover image through the gallery, the camera, or a pasted URL. It validates the title, year, medium and status before submitting. The progress label changes with the medium (Page, Chapter or Episode). I made the form hand the finished `Story` to `onSubmit` instead of saving to Supabase itself, so the Add screen calls `addStory` and the Edit screen calls `updateStory`. On the Add screen I made sure a failed save shows a snackbar and keeps the user on the form, so their input is not lost, and that a successful save opens the new story's details page with `pushReplacement`. On the Edit screen I pass the existing story as `initialStory` to fill the form, and I return the updated `Story` to the previous screen so the details refresh right away. I also checked `context.mounted` after every `await`. I changed the layout, spacing and styling of the Story Details screen to match my design, and I replaced its empty state with my shared `EmptyState` widget. I wrote these files with the help of online resources. Section 3 has more detail on each file.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/0e73e89036957547b33551d7f468dafe5814610e

### 2026-10-04 - Memories Screens

- **Tool:** Claude
- **What I asked for:** Help building the Memories screen, a place to browse every memory I have written across all my stories, with search and filtering.
- **What it gave back:** A first version of the Memories screen, including the list of memory cards, the search bar, and a filter-and-sort sheet.
- **What I kept, what I changed, and why:** I kept the overall structure: a list of memory cards with search and filter chips for each medium. I changed the layout, spacing and styling to match my design, and used the Railey heading from `app_theme`. I turned the search bar into a shared widget (`AppSearchBar`), because the Library screen now uses it too. I also changed my navigation. It was planned as Home, Library, Search, Profile, and I made it Home, Library, Memories, Profile. That is why I moved the search into the Library screen and added another one in Memories. I also added a filter by date (any date, last 7 days, last 30 days, this year, or a custom range) and a sort by newest or oldest. I replaced the empty state with my shared `EmptyState` widget.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/f47b7ff4f359cbf68e7fb117a71da28774dbef5e

### 2026-10-04 - Add/Edit Memory and Memory Details Screens (first version)

- **Tool:** Claude
- **What I asked for:** Help building the screens to add a memory, edit a memory, and view one memory in full.
- **What it gave back:** A first version of the memory form, the Add and Edit screens, and the Memory Details screen with its banner and card.
- **What I kept, what I changed, and why:** I kept the idea of one shared form used by both the Add and Edit screens, so they could not drift apart. I changed the form to fit my design and my data: the entry-type chips, a number field that only shows for chapter, episode or volume, the favorite quote field, and a date picker. I added the logic that saves "Chapter 85" as one text value and strips the label again when editing. On the details screen I added the edit button. This part uses the same approach as the Add/Edit Story and Story Details screens, so it was quick to build.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/5ae47d20aa6ab02caec4c2c3a36a5ffdd1919822

### 2026-10-04 - Add Profile and Settings Screens

- **Tool:** Claude
- **What I asked for:** Help building the Profile, Edit Profile and Settings screens, including the text-size and high-contrast options.
- **What it gave back:** A first version of the three screens and the Supabase calls to save profile details and preferences to the user's account.
- **What I kept, what I changed, and why:** I kept the approach of saving profile details and preferences in the user's account metadata, so they come back on every device. I changed the layout and styling to match my design and wrote the reusable `ProfileAvatar` widget myself. I added the high-contrast and text-size settings to `app_theme`, with some help from online resources, and applied the text size through `MediaQuery` in `main.dart`. On the Settings screen I added confirmation dialogs for signing out and for deleting the account, and the text-size selector.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/dcfeedd76db9f45ccbb31ed81370e39a5f258c02

### 2026-10-04 - Supabase

- **Tool:** Claude
- **What I asked for:** Help finishing the Supabase connection, so all the screens use the database instead of sample data.
- **What it gave back:** The `SupabaseService` methods for stories, memories, preferences, the cover upload to storage, and account deletion, plus the idea of loading a memory together with its story in one query.
- **What I kept, what I changed, and why:** I kept the service structure and the joined query, because it lets a memory card show its story without a second request. I set up the tables, the `covers` storage bucket and the account-deletion function in my own Supabase project. I made my `Story` and `Memory` models match my columns, and I removed the sample data file, so the database is now the only source of data.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/fe1109360f0a9b980be32491a41daffc23956925#diff-cfd5f784236e61436b75057bec65f04ffc76b7e77df8cb809c4ac52882928608 (first added for the authentication screens, then finished and updated later in development)

### 2026-10-09 - Reworking Add Memory and Memory Details into a journal/notes style

> **Note:** This replaces the first version above (Add/Edit Memory and Memory Details Screens). The shared `MemoryForm` and the separate Edit Memory screen no longer exist. I deleted `memory_form.dart` and `edit_memory_screen.dart` because editing now happens directly on the Memory Details screen.

- **Tool:** Claude
- **What I asked for:** Help making the Add Memory and Memory Details screens feel like a journal or notes app instead of a form: one page you write on, not a list of fields.
- **What it gave back:** Ideas and code for a notes-style page layout, a bottom sheet for picking the entry type and number, and an autosave approach where the memory saves itself shortly after you stop typing (a debounce timer plus a save-state indicator).
- **What I kept, what I changed, and why:** I kept the notes-style layout, the type-and-number bottom sheet and the autosave on the Memory Details screen. I changed the styling, spacing and wording to match my design. Because editing now happens on the details screen, I removed the Edit Memory screen and the shared form. I kept my earlier logic from the first version: the type and number are saved together as one text value ("Chapter 85"), and `_stripUnit` removes the label when a memory is opened. Add Memory works differently from Memory Details on purpose: it does not save anything until I tap Save, and it asks "Discard this memory?" if I leave with unsaved writing. Memory Details autosaves, so it has no Save button and also keeps a delete confirmation. I wrote the loading logic, `_stripUnit`, the date picker, the delete dialog, and the layout and styling myself, using online resources. The autosave (the timer, the save states and saving on close) and the entry type bottom sheet were built with AI help.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/6b8f5bdfa42e47ddab110a0568be656afead419f

### 2026-10-09 - Page-flip animation for tab navigation

- **Tool:** Claude
- **What I asked for:** Help adding a page-flip animation when switching between the main tabs.
- **What it gave back:** The harder animation parts: a `_Snapshot` wrapper that safely disposes the captured image, the custom `PageFlipRoute` (a `PageRouteBuilder` with an `AnimatedBuilder`, `AbsorbPointer` and a 750 ms `easeInOut` transition), and the `_PageFlipPainter` custom painter that draws the page-curl effect with a moving fold line, polygon clipping, a mirrored flap using a reflection matrix, and shading gradients.
- **What I kept, what I changed, and why:** I kept the AI's route and painter, because I could not have written the page-curl drawing myself. I wrote the surrounding logic: the `pageSnapshotKey` `GlobalKey` and the `RepaintBoundary` in `main.dart` that it points to, the `_flipping` flag so a second tap cannot start another animation, the async `_flipToPage` function, and the `_findBoundary` helper (see Section 3). I added a fallback to the normal transition if the screen capture fails.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/c34c0081b13a03d20e15b5a169b75cc80e7e19c9

## 2. Where the AI got it wrong

Three cases. Be specific. If you write that the AI was never wrong, this section
scores zero.

### Case 1 - short title

- **What it gave me:**
- **What was wrong with it:**
- **What I did instead:**
- **Commit:** https://github.com/YOUR-USERNAME/YOUR-REPO/commit/SHA

## 3. Who wrote what

At least a fifth of this project is code you wrote yourself. Name it, and explain
it in your own words.

> Group projects: give each member their own heading below, and use your GitHub
> handle as the heading. You are graded on your own section.

### Written by me

- **File:**
- **Commit:**
- **What it does and why it is built this way:**

### The AI-written part I understand best

- **File:**
- **Commit:**
- **What it does and why we kept it:**
