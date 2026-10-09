# Weekly reports for Story Shelf

One entry per week, newest at the top, written **during** that week. Five minutes
each. They are the record of how the project actually went, and they make your
final reflection almost write itself.

Copy this block:

---

## Week 1 (September 22, 2026 to September 26, 2026)

**Done this week**
- Decided the build order: authorization screens first, before touching Supabase wiring or shared widgets in depth.
- In `docs/`: added an assets folder (logo and wordmark images) and a mockups folder (mockup screens), and edited the proposal and mockup markdown files.
- In `lib/`: started the actual coding. Created all files except `main`, which I edited and updated to match the app.
- Built `SupabaseService`, a wrapper around the Supabase client with the auth methods the app needs (`signUp`, `signIn` with email/password, `resetPasswordForEmail`, `signOut`) plus `currentUser` / `isSignedIn` getters, so screens call this instead of Supabase directly.
- Added `.env` for environment variables.
- Edited and updated `pubspec.yaml`.

**In progress**
- Authorization screens (Start, Log In, Sign Up, Reset Password) still need finishing and polish.

**Blocked or stuck on**
- At the start of the week I genuinely didn't know where to start. The widgets, Supabase and the screens all felt like they could be the first step, and not being able to pick one was overwhelming. I stalled on that for a bit before going back through the repository template and thinking it through properly. Once I did, it clicked that authorization had to come first, since nothing else in the app can really be built or tested without a logged-in user.
- Supabase itself was confusing to work through at first. Setting it up and figuring out how the auth methods should fit together took some trial and error before `SupabaseService` came together the way it did.

**Decisions made, and why**
- Authorization comes before every other screen because the rest of the app depends on knowing who the logged-in user is. Home, Library, Story Details and Profile all need a real user to load or save anything against. Building those first on top of an unfinished authorization flow would mean redoing work later.
- Updated the mockups and proposal to reflect the actual screens I'm building instead of the template's placeholders, so I had something accurate to build against.
- Scaffolded all of `lib/` (aside from `main`) up front so the project has its real file structure from the start.
- Built `SupabaseService` first so the auth screens have real sign-up, sign-in and reset logic to call into rather than being built against nothing.
- Added `.env` and updated `pubspec.yaml` to set up the environment variables and dependencies the app, and Supabase auth specifically, will need.

**Hours spent, roughly:** ___

**Next week I will:**
- Finish and polish the authorization screens.
- Build the Home screen: Memory of the Day, Continue Your Stories (progress bars), Recent Memories, bottom nav.
- Build the Library screen: all saved stories, medium tabs, favorites filter, status filter, combinable.
- After that, in order: Add/Edit Story, Story Details, Add/Edit Memory, Memory Details, Search, Profile, Edit Profile, Settings.
- Wire the stories and memories Supabase tables into the app once the core screens exist.
- Add screenshots for section 6 of the README as each screen is finished.
- Stretch goals (Custom Collections, Home Highlights, Dashboard/Statistics, local notification reminders) are not required for the MVP, so revisit only if time allows after the core flow works.

---

## Week 2 (September 27, 2026 to October 3, 2026)

**Done this week**
- Finished Home and Library screens, including Library's filter functionality (medium, favorites, status, all combinable).
- Revised the app's theme for more cohesive colors, text and UI across screens.
- Reworked the bottom nav bar: switched from Column to Stack layout so it floats over content, with rounded corners, border, and a blur effect.
- Added a temporary "skip to Home" button to bypass login during development.
- Switched to placeholder image URLs (e.g. picsum.photos) instead of manually sourced images in sample data.
- Finished the Story Details screen: banner with photo overlay and gradient fade, thumbnail and title overlapping the bottom edge.
- Made the "Currently Reading" status label medium-aware ("Currently Watching" for movies, dramas, anime and TV).
- Reordered the Add/Edit Story form into four stacked full-width sections instead of two side-by-side pairs.
- Polished empty states for the memories list and the Library grid (icon, message, context-aware copy).
- Made Library's medium filter chips draggable via mouse/trackpad.

**In progress**
- Add Memory / Edit Memory screens (currently a "coming soon" snackbar placeholder).
- Add/Edit Story cover picker (still a URL-paste dialog, needs a real image_picker and Supabase Storage upload flow).
- Small polish items on Home and Library.
- Wiring Story Details, Add/Edit Story and Library to Supabase instead of `sampleStories` / `sampleMemories`.

**Blocked or stuck on**
- Logging in repeatedly every time I reran the app during testing became a real bottleneck, so I added a temporary button that jumps straight to the Home screen.
- The bottom navigation bar appeared to float with unwanted extra space beneath it. My first instinct was that `SafeArea` would fix it, but I had it applied in multiple places at once, which stacked extra padding instead of removing it. Part of the gap also wasn't coming from my code at all: DevicePreview's simulated phone frame adds its own inset. I searched for solutions and asked AI for help, but the fixes I tried weren't resolving it. Eventually I switched the screen's layout from `Column` to `Stack`, which let me position the nav bar directly on top of the scrolling content instead of as a separate row. Since it was going to have some floating appearance no matter what, I leaned into that so it reads as a deliberate design choice instead of a bug.
- Release year didn't show on Story Details even after adding it to the widget code, because the sample data entries hadn't been given `releaseYear` values. A reminder to check the data source before assuming the UI logic is at fault.
- The status filter bottom sheet needed a fix: using `Navigator.pop()` with no argument for "All" was indistinguishable from the user dismissing the sheet, since both return null. I solved that by wrapping the result in a small `_StatusChoice` type.

**Decisions made, and why**
- Prioritized Home and Library because they're the first two screens a logged-in user lands on, so getting them functional unblocks testing the rest of the navigation flow.
- Cleaned up the theme now, while only a few screens are built, because it's cheaper than retrofitting consistent styling across many screens later.
- Reworked the bottom nav bar because it appears on nearly every screen and needed to be solid before building more screens on top of it.
- Added the temporary login-bypass button as a practical trade-off for development speed, with a plan to remove it once real authentication is fully wired in.
- Switched to placeholder image URLs because it avoids managing individual image files for every sample story while development is ongoing.
- Finished Story Details next because it's where a user lands after tapping any story, so its layout and data needed to be solid before building Add/Edit Memory on top of it.
- Reordered the Add/Edit Story form into single-column sections as a usability call, since side-by-side pairing read as cluttered once real values replaced placeholders.
- Filled in the empty states because they were still bare text, and this avoids screens feeling broken the first time someone hits a "no results" case.

**Hours spent, roughly:** ___

**Next week I will:**
- Build the real Add Memory / Edit Memory screens.
- Replace the cover picker's URL-paste dialog with `image_picker` and a Supabase Storage upload.
- Do the small polish items on Home and Library.
- Wire Story Details, Add/Edit Story and Library to Supabase (`SupabaseService.instance`).
- Continue down the original screen order: Memory Details, Search, Profile, Edit Profile, Settings.
- Remove the temporary login-bypass button once the real authentication flow is confirmed working end to end.
- Add screenshots for section 6 of the README as each screen is finished.
- Stretch goals (Custom Collections, Dashboard/Statistics, local notification reminders) are not required for the MVP, so revisit only if time allows after the core flow works.

---

## Week 3 (October 4, 2026 to October 9, 2026)

**Done this week**
- Finished the remaining screens: Memories, Add Memory, Memory Details, Profile, Edit Profile and Settings. All 16 mockup screens now exist in the app.
- Connected the whole app to Supabase through `SupabaseService`: stories and memories are loaded, added, updated and deleted from the database; a memory is fetched together with its story in one joined query; cover images are uploaded to a `covers` storage bucket; account deletion runs through a `delete_user` function.
- Removed the sample data file, so Supabase is now the only data source. Home, Library, Story Details and Add/Edit Story all read real data, and "Memory of the Day" pulls from my actual memories.
- Replaced the Add/Edit Story URL-paste dialog with a real cover picker using `image_picker`, from gallery or camera. A pasted URL still works.
- Added the Memories tab, a browsable list of every memory with search, medium chips, date filters (any date, last 7 days, last 30 days, this year, custom range) and newest/oldest sort.
- Changed the bottom nav from Home / Library / Search / Profile to Home / Library / Memories / Profile. Search now lives inside Library and Memories, using one shared `AppSearchBar`.
- Reworked Add Memory and Memory Details into a journal/notes style. Memory Details autosaves after you stop typing and shows a save-state indicator. Add Memory saves only on Save and asks "Discard this memory?" if you leave with unsaved writing. Entry type and number are chosen in a bottom sheet. Editing happens on the details screen, so I deleted `memory_form.dart` and `edit_memory_screen.dart`.
- Built Profile, Edit Profile and Settings. Profile details and preferences are saved in the user's account metadata, so they follow the account across devices. Text size (small/medium/large) and a high-contrast mode apply app-wide through `AppTheme` and `MediaQuery`. Sign out and delete account both have confirmation dialogs.
- Added the page-flip animation for switching tabs, with a fallback to a normal transition if the screen capture fails.
- Added the custom Railey heading font in `pubspec.yaml` and connected it to the heading styles in `app_theme.dart`, with Montserrat for body text. Colors, spacing and text styles are now centralized in one file.
- Combined the repeated empty-state code into one shared `EmptyState` widget, and added a shared `ProfileAvatar` and `StoryPosterCard`.
- Set up the deploy workflow so the Supabase URL and publishable key come from repository secrets, using both a generated `.env` and `--dart-define`. `main.dart` reads either one.
- Removed the temporary "skip to Home" login button now that auth works end to end.
- Wrote up AI-USAGE.md: the log, where the AI got it wrong, and who wrote what.

**In progress**
- README: still the template, needs the name, description, screenshots, features, environment variables, privacy section, status and AI-use section.
- `docs/06-security-and-privacy.md`: still the template, needs what the app stores, where secrets live, and the Supabase RLS policies.

**Blocked or stuck on**
- **Autosave was harder than it looked.** Saving while typing means handling the debounce timer, the save states, and saving when the screen closes without losing the last edit. I used AI help for the timer and save-state logic and wrote the loading, `_stripUnit`, date picker, delete dialog and layout myself.
- **The page-curl painter was beyond what I could write.** It needs a moving fold line, polygon clipping and a mirrored flap. I used the AI's route and painter and wrote the surrounding logic: the `pageSnapshotKey`/`RepaintBoundary` capture, the `_flipping` flag so a second tap can't start another animation, and the async flip function.
- **Moving from sample data to Supabase exposed mismatches.** I had to make the `Story` and `Memory` models match my actual table columns, and set up the tables, bucket and delete function in my own Supabase project.
- **Some AI output didn't fit my project.** The first `app_theme.dart` didn't connect my fonts or logo, Home didn't follow my mockup's content rules, and the nav-bar gap fixes didn't work. I logged these in AI-USAGE.md and fixed each one myself.
- **I started the AI usage log late.** I rebuilt it from my commit history and chat history, and said so at the top of the file.

**Decisions made, and why**
- Built the shared widgets and the nav change first so every screen behaved the same.
- Connected Supabase before polishing, because sample data would have hidden bugs that only show up with real saved data.
- Made search part of Library and Memories instead of its own tab, because a separate search tab duplicated what those two screens already did.
- Rebuilt Add/Edit Memory as a journal page because a form full of fields didn't match what the app is for, which is writing down how a story felt. Removing the separate edit screen and shared form meant one fewer place for add and edit to drift apart.
- Added text size and high contrast settings to make the app easier to read for more people, and saved them to the account so they follow the user.
- Added the page flip because it fits the book theme and gives tab changes a clear identity.
- Removed the login-bypass button because it was only meant for development.

**Hours spent, roughly:** ___

**Next week I will:**
- Write the README, with screenshots of each main screen.
- Fill in `docs/06-security-and-privacy.md`, including the Supabase RLS policies.
- Confirm the GitHub secrets are set and the live Pages deploy loads and logs in.
- Check that no real personal data appears in screenshots, sample entries or the video.
- Stretch goals, such as custom collections and notification reminders, were not implemented because they were not required for the MVP.

---