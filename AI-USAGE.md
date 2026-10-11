# AI usage

## Summary
I used Claude to help with coding, debugging, and implementing features in Story Shelf. AI-generated code served as a starting point, but I modified it to match my designs, requirements, and preferred functionality.

I tested the app regularly and fixed issues involving navigation, database operations, validation, and screen layouts. I also used online resources to understand Flutter and Dart concepts better.

Overall, AI helped speed up development, but I remained responsible for design decisions, testing, code revisions, and documenting my contributions. This process helped me better understand the code and how the app works.

## Contents
  1. [How I used AI](#1-how-i-used-ai)
  2. [Where the AI got it wrong](#2-where-the-ai-got-it-wrong)
  3. [Who wrote what](#3-who-wrote-what)

--- 

## 1. How I used AI

> **Note:** I started this log late. I reconstructed these entries on 2026-10-03 from my commit history and my chat history, and finished them on 2026-10-11. Entry dates are the dates of the commits where the work landed, and each entry describes something I really did.

### 2026-09-23 - Building the authentication screens and connecting them to Supabase

- **Tool:** Claude
- **What I asked for:** Help implementing Supabase authentication (sign up, log in, password reset) for the Story Shelf authentication screens: Start, Log In, Sign Up, and Reset Password.
- **What it gave back:** The Supabase authentication logic in `SupabaseService`, and how the screens should call it.
- **What I kept, what I changed, and why:** I built the four authentication screens myself, including their wording, font sizes, content and my own Story Shelf logo, so they match my design. I kept the AI's overall Supabase authentication approach and connected my screens to it. I haven't changed the Supabase logic itself. I only set up my own Supabase project and added the `.env` file with my own keys. I wrote `app_theme.dart` myself, with only a little help from online sources, and it became the file I rewrote the most as the design grew: I connected my own fonts and added the high-contrast and text-size settings (see Section 3). [TODO: if the AI also gave you the reusable text field or button widgets, add that here.]
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

### 2026-10-11 - Mood selection and mood filtering

- **Tool:** Claude
- **What I asked for:** Help adding a mood to each memory, and a way to filter memories by mood.
- **What it gave back:** An initial implementation of mood selection, a reusable MoodPicker, a MoodBadge, and mood filtering on the Memories screen.
- **What I kept, what I changed, and why:** I directed how mood selection should work across the memory screens. In Add Memory, users select a mood using chips, while Memory Details uses a bottom sheet to keep the notes-style layout clean. I also added the option to clear a selected mood and refined the mood filter on the Memories screen. I kept the reusable widgets so moods look the same throughout the app.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/9f8ead4b9f0a957132446e575ce2e564d095b16c

### 2026-10-11 - Story Search and Add Story Integration

- **Tool:** Claude
- **What I asked for:** Help understanding and implementing external story-search APIs in Story Shelf, then connecting the search results to the shared StoryForm so users could add stories without entering all the details manually.
- **What it gave back:** An explanation of API integration, a StorySearchResult model, a search service, an initial search screen, and code to pass selected results into the story form. The service uses Open Library for books, AniList for comics and manga, and TMDB for movies and series.
- **What I kept, what I changed, and why:** I first asked Claude to explain how the APIs would work before implementing the feature. I registered for TMDB, configured the API key for local development, documented it in .env.example, and added the GitHub Actions secret for deployment. I changed the search screen layout because the first version did not use the available space well. I also improved the search option in StoryForm so users could find stories more easily. When a result is selected, the title, year, creator or author, cover image, medium, and total chapters or episodes are filled in when available. Users can still review and edit these details before saving. I kept manual entry available because external search may not find every story. These changes made adding stories faster while keeping users in control of the information saved.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/73884981f6c10e88291f04883e57f12000fdbe24

## 2. Where the AI got it wrong

### Case 1 - Separate empty states on every screen

- **What it gave me:** When I asked for the Library, Memories and Story Details screens, the AI wrote a separate "nothing here yet" block inside each screen.
- **What was wrong with it:** The copies were written differently on each screen, so they looked slightly different from one another. Some screens had no empty state at all, and any change to the design would have meant editing the same code in several places.
- **What I did instead:** I edited all of them, added the missing ones, and combined them into one shared `EmptyState` widget with an icon or custom widget, a title and a message. I added a `bordered` option for use inside a section, and an `assert` that makes sure an icon or a custom leading widget is always given. Home, Library, Memories and Story Details now all use it, so empty screens look the same everywhere (see Section 3).
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/1b3808a15eef62b6084b43f9c847ef245cd657e9#diff-07220d9bbd10805f7e16999b4c7f4067e742eb6dd4c5055b420e139c95dbb79

### Case 2 - Home didn't match my mockup's content rules

- **What it gave me:** The Home and Library screens, built with the sample data I had prepared. Home included Memory From This Day, Continue Your Stories, and Recent Memories, while Library displayed stories in a filterable grid.
- **What was wrong with it:** Continue Your Stories displayed every in-progress story instead of the three shown in my mockup. Memory From This Day selected the first sample memory rather than checking the current date, and it did not display the creator or medium. Story card sizes also differed between Home and Library
- **What I did instead:** I limited Continue Your Stories to three cards using take(3) and added the creator and medium to the Memory of the Day banner. I later connected the feature to Supabase so it uses real memories. I also reused StoryPosterCard and AppTheme.storyCardAspectRatio to keep story cards consistent across screens. Some changes were made later and may not appear in the linked commit.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211#diff-935e56a557f0ab902a679f47de66345d9f47058bccb96f870e6383d19e2c86dd

### Case 3 - Bottom nav bar gap

- **What it gave me:** Claude suggested adjusting SafeArea, bottom padding, and MediaQuery insets to fix the gap beneath the bottom navigation bar.
- **What was wrong with it:** These changes did not fix the problem because the gap had multiple causes. SafeArea was applied in several places, causing bottom insets to stack. The Column layout also reserved a separate row for the navigation bar, while DevicePreview added its own simulated phone-frame inset.
- **What I did instead:** I changed the layout from Column to Stack and used Positioned to make the navigation bar float above the content. I added rounded corners and a BackdropFilter blur effect, then consolidated the SafeArea handling. I also tested without DevicePreview to identify the remaining gap caused by the simulated frame.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211#diff-504ba30b38ec1a02630078d2c08fea433e90aca25e8fa2e5becacd76f75c354d

### Other Issues I Corrected During Development
Aside from these cases, I also made changes to other AI-generated parts of Story Shelf. I adjusted the screens to match my mockups, fixed search and filtering behavior, improved form validation and error messages, and made sure the data matched my Supabase database. I also redesigned the memory screens, improved accessibility settings, and added features such as mood selection and external story search.

These changes show that I used the AI-generated code as a starting point, then reviewed and improved it to fit my requirements. My specific contributions are explained in Section 3.

## 3. Who wrote what
This section documents the parts of Story Shelf that I wrote, implemented, or substantially reworked. Some files began with an AI-generated version, while others were written by me. I have described my specific contributions in each entry and recorded AI assistance separately in Section 1. I also used online resources as references throughout development.

**Note:** The commit links point to relevant versions in the development history. For some files, the linked commit is where my changes landed rather than the first commit containing the file. A commit shows the code at that point in time, but does not by itself establish who wrote every line.

### 3.1 Reusable Profile Avatar Widget

- **File:** `lib/widgets/profile_avatar.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/dcfeedd76db9f45ccbb31ed81370e39a5f258c02#diff-8e3125a8508c911554647373c518484fb5f7d538c99bec502642d534afce30f6
- A profile picture appears on both the Profile and Edit Profile screens, and I did not want to write the circle, the loading and the fallback twice. So I wrote one widget that takes an optional image URL and a size and draws the picture in a circular frame. I decided the fallback should be a person icon in my theme colors, so a missing or broken URL never leaves an empty or broken-looking circle. It uses the shared `AppTheme` colors, and I added a semantic label so assistive technologies can identify the image.

### 3.2 Theme and Accessibility Settings

- **File:** `lib/theme/app_theme.dart`
- **Commits:**
  - **first version:** https://github.com/joysarmiento/story-shelf/commit/fe1109360f0a9b980be32491a41daffc23956925#diff-08529fa9ec6a15d2358641c70607ef1b436f12f2f4f567766bf69393f82055c4
  - **Railey and text styles:** https://github.com/joysarmiento/story-shelf/commit/5ae47d20aa6ab02caec4c2c3a36a5ffdd1919822#diff-8d6c8293389df22934588bb65e314b47fedf8c2c92772313f57313d749f27ff8
- I wrote this file myself, with only a little help from online sources. I put the colors, spacing, card sizes and text styles in one place, so every screen reads from it and I can change the design without editing each screen. I chose Railey for headings because my mockups use a script-style heading, and Montserrat for the other text. In my first commits I used Montserrat through `google_fonts` and an image wordmark for the headers, and I registered Railey in `pubspec.yaml` and connected it to the heading styles later. I added a high-contrast text style and the text-size setting so people who need stronger contrast or larger text can change it themselves, and I apply the size through `MediaQuery` in `main.dart`.

### 3.3 Story Model
- **File:** `lib/models/story.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211#diff-b8bc68a29476ae41acd54d7947c212defe8726c936e446fba6cd1d91049829f0
- The AI gave me a first version of this model, and I reworked it to fit Story Shelf. I changed the status labels to Not Started, Started and Completed, because my library filter uses those words and I wanted the model and the screen to say the same thing. I named the fields to match the snake_case schema in my proposal. `progressFraction` returns 0 when the total is missing or zero and clamps the result between 0 and 1, so the progress bar never receives a bad value. I also added fallback values in `fromDb` so an unexpected value in the database cannot crash the app.

### 3.4 Memory Model
- **File:** `lib/models/memory.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211#diff-266e8ca1ac41ffb29661d17e33530417e81c1140ac99a090cb74a57d4ffd31ec
- The AI gave me a first version of this model, and I reworked it before committing. A memory is a journal entry tied to a story, and it can be an overall review, a chapter, an episode or a volume. I decided a memory should carry its story's title, cover, creator and medium when it is loaded, so a memory card can show what it is about without another request. When saving, I leave those joined fields out, so only the memory's own data goes to the `memories` table.

### 3.5 Home Screen Features
- **File:** `lib/screens/home_screen.dart` — Continue Your Stories, Recent Memories, and Memory of the Day
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/79688bfa5184ff753c5a2954418524d495760f04#diff-935e56a557f0ab902a679f47de66345d9f47058bccb96f870e6383d19e2c86dd
- The AI gave me the first version of the Home screen, and I changed it to match my mockup. My mockup showed three stories in "Continue Your Stories", but the first version listed all five in-progress stories, so I limited it with `take(3)` and let the See All link lead to the rest. I added the same See All link to "Recent Memories" so both sections follow one pattern, using the `actionLabel` of `SectionHeader`. I also added the story's creator and medium to the Memory of the Day banner, because my design shows them and the first version had only the title and date.

### 3.6 Floating Bottom Navigation Bar
- **File:** `lib/widgets/bottom_nav_bar.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211#diff-504ba30b38ec1a02630078d2c08fea433e90aca25e8fa2e5becacd76f75c354
- An empty strip appeared under the bottom bar, and the AI's suggestions (more `SafeArea`, zero padding) did not remove it. I found that the gap had several causes: stacked `SafeArea` widgets, the DevicePreview phone frame, and the `Column` layout reserving a row for the bar. So I changed the screens to a `Stack` and placed the bar with `Positioned`, so it floats over the content. Because it now floats, I gave it rounded corners, a border and a `BackdropFilter` blur so the content behind it stays visible. It calls `navigateToTab`, so every tab switches the same way.

### 3.7 Shared App Navigation and Page-Flip Transition
- **File:** `lib/utils/app_navigation.dart`
- **Commits:** 
 - **first version:** https://github.com/joysarmiento/story-shelf/commit/d2ac356fb6112a5c7e8bfc0b438942a3180ca913#diff-df476f3b0a7591094b61a644edd755af8ef63f30f239999eaa1d8e262fa21423
 - **page-flip update:** https://github.com/joysarmiento/story-shelf/commit/c34c0081b13a03d20e15b5a169b75cc80e7e19c9
- The AI gave me the first navigation code, and I reorganised it so all four tabs (Home, Library, Memories, Profile) switch through one `navigateToTab` function with named `AppTab` values. I originally planned Home, Library, Search and Profile, but I changed the third tab to Memories so there is one place to browse everything I have written, and moved the search into Library. Detail screens pass `currentIndex: -1`, so switching to a tab from them counts as new navigation. I later added a page-flip transition to give the app a book-like feel. I wrote the logic around it: `pageSnapshotKey`, the `_flipping` flag so a second tap cannot start another animation, `_flipToPage`, and `_findBoundary`. If capturing the screen fails, the app falls back to the normal transition, so a failed capture never blocks navigation. The page-curl drawing (`_Snapshot`, `PageFlipRoute` and `_PageFlipPainter`) was done with AI help.

### 3.8 Add Story Screen
- **File:** `lib/screens/add_story_screen.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/0e73e89036957547b33551d7f468dafe5814610e#diff-0d56670db097ca658afd555ad13cbdb3532e9e7d85539b5521d33b5a30c35694
- I wrote this screen around the shared `StoryForm`, so it only has to save the finished story with `SupabaseService.addStory`. I decided that a failed save should show a snackbar and keep the user on the form, because losing a typed title, year and cover would be frustrating. After a successful save, `pushReplacement` opens the new story's details page, so pressing back does not return to an empty form. I also check `context.mounted` after every `await`, so the screen never updates after it has been closed. This work was part of the AI-assisted entry in Section 1.

### 3.9 Edit Story Screen
- **File:** `lib/screens/edit_story_screen.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/0e73e89036957547b33551d7f468dafe5814610e#diff-ee8d6f750d288881d53a10498425537481b450e9924699f95caa61f994adf5cf
- I wrote this screen to reuse the same `StoryForm` as Add Story instead of building a second form. I pass the existing story as `initialStory`, so the fields start with its current details, and the screen calls `updateStory` instead of creating a new record. After saving, I return the updated `Story` to the previous screen, so the details page refreshes right away. Using one form means the Add and Edit screens can never end up with different fields or rules. This work was part of the AI-assisted entry in Section 1.

### 3.10 Shared Story Form
- **File:** `lib/widgets/story_form.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/0e73e89036957547b33551d7f468dafe5814610e#diff-0c3926eb4e1132f965bed37671b276f4a2282bb088444651b03922cfe723da7d
- I built one shared form for adding and editing stories. It is a `StatefulWidget` because it manages text fields, dropdowns, the rating and the loading state. Users can set the cover from the gallery, the camera or a pasted link, because covers can come from a photo or from the web. It checks the title, year, medium and status before submitting. The progress label changes with the medium (Page, Chapter or Episode), so the form asks for the right thing. I decided that the form should not save to Supabase itself. It passes the finished `Story` to `onSubmit`, which is what lets the Add and Edit screens share it. This work was part of the AI-assisted entry in Section 1.

### 3.11 Memories Filtering, Sorting, and Search
- **File:** `lib/screens/memories_screen.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/b58d486d1511b1a89903fdbcc4f9ac6de67254f1#diff-30d39900ef8e8243a9f8212a50e2bfcc293672b2f556e72962c08107290f2593
- The AI supplied the first version of this screen, and I wrote the filtering and sorting logic myself. `_DatePreset` offers any date, last 7 days, last 30 days, this year and a custom range, so someone can quickly narrow a long list to when they wrote something. `_activeDateRange` counts from the start of today, so "last 7 days" means today and the 6 days before it. `matchesDate` moves the end of the range to the next midnight, so a memory written late on the last day is still included. `_filteredMemories` combines the search text (title, content, quote, story title and chapter), the medium and mood filters and the date range, then sorts newest or oldest first. I kept all of it in one getter, so the list always matches the current choices.

### 3.12 Add Memory Screen
- **File:** `lib/screens/add_memory_screen.dart`
- **Commits:**
 - **first version:** https://github.com/joysarmiento/story-shelf/commit/5ae47d20aa6ab02caec4c2c3a36a5ffdd1919822#diff-e5da0692bd8fc8925b3127c0bcc4b027104ceddd011a446174e27bced81481df
 - **notes-style version:** https://github.com/joysarmiento/story-shelf/commit/6b8f5bdfa42e47ddab110a0568be656afead419f#diff-e5da0692bd8fc8925b3127c0bcc4b027104ceddd011a446174e27bced81481df
- My first version used a shared `MemoryForm`, but a list of fields did not feel like writing a memory. I redesigned the screen as a notes-style page with a title, entry type and number, date, favorite quote, mood and a large writing area. I did this with help from online resources and AI. I decided that nothing is saved until the user taps Save, and I added validation so empty content, or a chapter, episode or volume entry without a number, cannot be saved. If saving fails, an error message appears and the writing stays on screen. A dialog asks before leaving with unsaved writing, so a half-written memory is not lost by accident.

### 3.13 Memory Details and Notes-Style Editing
- **File:** `lib/screens/memory_details_screen.dart`
- **Commits:**
 - **first version:** https://github.com/joysarmiento/story-shelf/commit/5ae47d20aa6ab02caec4c2c3a36a5ffdd1919822#diff-df9ca01b43d6420e52e0cadd085674db567fea12451f5ce489715410d14cc07f
 - **journal/notes update:** https://github.com/joysarmiento/story-shelf/commit/6b8f5bdfa42e47ddab110a0568be656afead419f
- My first version showed a memory in a cover-image banner and a note card with a separate edit button that opened another screen. I felt that reading a memory and editing it should be the same page, like a notes app, so I redesigned it to be edited in place and removed the separate Edit Memory screen. I wrote the layout and styling, the loading logic, the date picker, the delete dialog and the `_stripUnit` helper that separates "Chapter 85" into its type and number. With AI help, I added autosave after typing stops, the save-status label and the bottom-sheet entry type picker. Most of the later changes were to the logic, not the design, and the screen keeps the layout from my first version. The screen loads the memory and its story from Supabase, and deleting asks for confirmation first.

### 3.14 Settings Screen and Text-Size Controls
- **File:** `lib/screens/settings_screen.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/dcfeedd76db9f45ccbb31ed81370e39a5f258c02#diff-01804aeb7da5fa05de3787c3aa6f9ba4af679ece6a4e7a28a990ad6520fb33fa
- The AI gave me the first version of the Settings screen, and I added the parts that protect the user. Signing out and deleting the account both go through one `_confirm` function, and deleting uses warning styling, because it cannot be undone and should never happen on a single tap. I also built the text-size selector (`_TextSizeTile` and `_SizePill`) with Small, Medium and Large. `_setTextSize` applies the size immediately and then saves it to the user's account, so it follows them to other devices. If saving fails, a snackbar says so, and the local size stays applied, so the user is not left confused.

### 3.15 Reusable Empty-State Widget
- **File:** `lib/widgets/empty_state.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/1b3808a15eef62b6084b43f9c847ef245cd657e9#diff-07220d9bbd10805f7e16999b4c7f4067e742eb6dd4c5055b420e139c95dbb79
- The AI gave me a separate empty state on each screen, and the copies looked slightly different. I edited all of them, added the ones that were missing, and combined them into one widget with an icon or custom widget, a title and a message. I added a `bordered` option for use inside a section, while the plain version works for a full-screen empty list. An `assert` makes sure an icon or a custom leading widget is always given. Home, Library, Memories and Story Details all use it now, so "nothing here yet" looks the same everywhere.

### 3.16 Story Search and API Integration
- **Files:** `lib/models/story_search_result.dart`, `lib/services/story_search_service.dart`, `lib/screens/story_search_screen.dart`, `.env.example`, `.github/workflows/deploy-web.yml`, and related Add Story integration
- **Commits:** https://github.com/joysarmiento/story-shelf/commit/73884981f6c10e88291f04883e57f12000fdbe24
- Before writing any code, I asked Claude to explain how external story-search APIs work, so I would understand what I was adding. I registered for TMDB, set up the API key for local development, documented the variable in `.env.example`, and added the GitHub Actions secret for deployment. The search uses Open Library for books, AniList for comics and manga, and TMDB for movies and series. I changed the layout of the search screen because the first version did not use the available space well. I kept manual entry available, because external search may not find every story. Claude helped implement the model, the service and the first version of the screen.

### 3.17 Story Form Search Integration and Manual Entry
- **File:** `lib/widgets/story_form.dart`
- **Commits:** https://github.com/joysarmiento/story-shelf/commit/73884981f6c10e88291f04883e57f12000fdbe24
- I wanted adding a story to be faster than typing every detail, so I updated `StoryForm` to accept a result from the external search. When a result is selected, the title, year, creator or author, cover, medium and total chapters or episodes are filled in when available. I decided the user must still be able to review and edit everything before saving, because search results are not always correct. The first AI-assisted version put a search-bar-like button under the Add Story heading, and I changed it to make searching a clearer option.

### 3.18 Shared User-Friendly Error Messages
- **File:** `lib/utils/error_message.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/9c8d4c67bf08cc630d780385a6a0105cd70c5515#diff-04edce0b33986cd37dc56077ccb0146344cd57f916918e0040447bcbd62207f4
- I noticed that raw error text on the screens was hard to understand, so I asked for a helper that turns common problems into plain messages. `friendlyError` covers connectivity, authentication, database operations and image storage, such as incorrect login details, permission issues, and images that are too large. I decided to keep the wording in one file, so I can change a message without editing every screen. Claude wrote the first version of the helper, and I chose and checked how it is used.

### 3.19 Memory of the Day Selection
- **File:** `lib/utils/memory_of_the_day.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/9c8d4c67bf08cc630d780385a6a0105cd70c5515#diff-0d6e40a8a631e86cb2252eb216961ef6d6785a5647dc3fb4b858d4d818774d48
- The first version of Memory of the Day just showed the first memory, which never changed. I described the behavior I wanted: the choice should stay the same all day and change the next day. `pickMemoriesOfTheDay` uses the current date as a seed, so the selection is stable during the day. It picks memories from up to two different stories when possible, or another memory from the same story if there is only one, and it handles an empty list safely. I checked that the result matched what I asked for. The selection algorithm itself was AI-assisted.

### 3.20 Responsive Medium Filter Chips
- **File:** `lib/widgets/medium_filter_row.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/17a820bd2dfe151a85c949309316105debd287e2#diff-ea21961b27efc6753f8e50c6048663ef25c1d2649a023f9edf8c047e53332106
- While testing Story Shelf on a phone, I noticed that the medium filter chips did not fit the width evenly and the spacing looked uneven on narrower screens. I worked with Claude to fix it. The row measures the label widths, accounts for the gaps and padding, and divides the remaining space between the chips instead of using fixed widths. The labels keep the room they need, and the row fits different screen sizes.

### 3.21 Mood Selection and Mood Filter
- **Files:** `lib/widgets/mood_picker.dart`, `lib/screens/add_memory_screen.dart`, `lib/screens/memory_details_screen.dart`, and `lib/screens/memories_screen.dart`
- **Commits:** https://github.com/joysarmiento/story-shelf/commit/9f8ead4b9f0a957132446e575ce2e564d095b16c
- I wanted a memory to record how a story made me feel, not only what I wrote, so I worked with Claude to add a mood. I decided how it should work in each place. In Add Memory the moods are selectable chips, but in Memory Details I used a bottom-sheet picker, to keep the notes-style page clean. A mood can be cleared if the user changes their mind. `MoodPicker` shows each mood's emoji and label, and `MoodBadge` shows a saved mood on a memory card. The Memories screen has a mood filter, so a user can find entries tied to a feeling.

### 3.22 Sample Data (deleted after I moved the app to Supabase)
- **File:** `lib/data/sample_data.dart` 
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211#diff-f80898601e57870c6b47d1e9e8087d1a44eada23c1c8900ce1e12d6eb4bea783
- I wrote the sample stories and memories by hand, using online sources for the story details. I deliberately mixed media types, statuses and ratings, so I could see how the layouts handled realistic entries before the backend existed. I removed the file after connecting Supabase, because the app now reads its data only from the database.

### 3.23 Edit Memory Screen (deleted when I reworked the memory screens)
- **File:** `lib/screens/edit_memory_screen.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/5ae47d20aa6ab02caec4c2c3a36a5ffdd1919822#diff-1db9b76882ba84602c62cadb6ea6e57316d2b2bcdc8d0c98b76ac5010de72282
- I wrote this screen to edit an existing memory through the shared `MemoryForm`, saving with `updateMemory` so the existing record was updated instead of duplicated. I removed it when I redesigned Memory Details to be edited in place, because a separate Edit screen was no longer needed. The `updateMemory` call stayed in `SupabaseService`, and the notes-style screen now uses it for autosaving.

### 3.24 Shared Memory Form (deleted when I reworked the memory screens)
- **File:** `lib/widgets/memory_form.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/5ae47d20aa6ab02caec4c2c3a36a5ffdd1919822#diff-58d4a88cf4e3d66f68b73e98ce2495a01a90c727e53095878f9681534e2d9aad
- I wrote this form for adding and editing memories. It had entry-type chips, a number field that only appeared for chapters, episodes and volumes, a date picker, and it kept the original ID and rating when editing. I decided to save the type and number together as one text value ("Chapter 85") and wrote `_stripUnit` to separate them again when editing. I removed the form during the notes-style redesign, but I reused this logic in Add Memory and Memory Details, so the entry-type format stayed the same.

### 3.25 Authentication Screens (Start, Log In, Sign Up, Reset Password)

- **Files:** `lib/screens/start_screen.dart`, `lib/screens/login_screen.dart`, `lib/screens/signup_screen.dart`, and `lib/screens/reset_password_screen.dart`
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/fe1109360f0a9b980be32491a41daffc23956925
- I built these four screens myself. I laid them out to match my Story Shelf design and chose the wording, the font sizes and my own logo. The forms check their fields before submitting. The Log In screen has a button to show or hide the password, and an error message appears if logging in fails, so the user is not left wondering. The Reset Password screen tells the user to check their email after the reset link is sent. The screens call `SupabaseService` for the actual sign up, sign in and password reset. That Supabase authentication logic was written with AI help, as recorded in Section 1, and I only connected my screens to it and added my own Supabase project and keys. [TODO: check this entry matches what each screen really does, and add a sentence about a decision you made, for example why the Start screen is laid out the way it is.]

### 3.26 The AI-written part I understand best
- **File:** `lib/services/supabase_service.dart` (`uploadCoverImage` and the memory queries)
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/fe1109360f0a9b980be32491a41daffc23956925#diff-cfd5f784236e61436b75057bec65f04ffc76b7e77df8cb809c4ac52882928608
- **What it does and why we kept it:** `SupabaseService` is the one place where the app talks to Supabase. It is a singleton, so every screen uses the same instance instead of creating its own connection. It handles authentication and stores the profile and the accessibility settings (text size and high contrast) in the user's metadata, so they follow the account to any device. I understand two parts best. `uploadCoverImage` takes the picked image's bytes and file name and checks that the user is signed in. It keeps the file extension only if it is a known image type (jpg, jpeg, png, webp or gif) and falls back to jpg otherwise. It uploads the image to the `covers` bucket under a path made of the user's ID and the current time, so two uploads can never overwrite each other and each user's files stay in their own folder. It returns the public URL, which the story saves as its cover. The memory queries (`getMemoriesForStory`, `getAllMemoriesForUser`, `getMemory`) use `select('*, stories(...)')` to load a memory together with its story's title, cover, creator and medium in a single request, so a memory card can show its story without asking the database again. We kept them because they keep database code out of the screens, they match my tables, and I could explain every line. I only connected the service to my own Supabase project and keys.
