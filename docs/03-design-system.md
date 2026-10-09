# Design system for Story Shelf

## Palette
| Role | Hex | Used for |
|---|---|---|
| Primary | #943b41 | Main buttons and active states |
| onPrimary | #ffffff | Text and icons on primary |
| Secondary | #9dc3d8 | Highlights, nav bar, chips, and cards |
| surface | #fbf9ec | Scaffold background |
| surfaceVariant | #d8e4e4 | Cards, sheets, and text fields |
| onSurface | #66769a | Body text |
| error | #b02d35 | Accent headings, tags, and destructive |

![Palette](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/images/design-system/01-palette.png)

*Note: I used AI to help summarize the information I provided and turn each part into a visual image. The content and information came from my own work, while AI was only used to assist with summarization and visual presentation.*


## Type scale

| Style | Flutter Slot | Size (sp) | Weight | Used for |
|---|---|---|---|---|
| Display (script) | displayMedium | 56 sp | Bold | "Your Shelf.", "Library" |
| Heading | headlineSmall | 34 sp | Bold | Screen titles and major headings |
| Body | bodyMedium | 20 sp | Regular | Memory card titles, story names |
| Caption | labelSmall | 15 sp | Medium | Timestamps (Date), meta, hints, and badges |

![Type Scale](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/images/design-system/02-type-scale.png)

*Note: I used AI to help summarize the information I provided and turn each part into a visual image. The content and information came from my own work, while AI was only used to assist with summarization and visual presentation.*


## Spacing

- Base unit: 4
- Screen edge padding: 24 (lg)
- Gap between list items: 12, between memory cards and grid covers
- Gap between sections: 32

![Spacing](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/images/design-system/03-spacing.png)

*Note: I used AI to help summarize the information I provided and turn each part into a visual image. The content and information came from my own work, while AI was only used to assist with summarization and visual presentation.*


## Components

| Component | File | Constructor parameters | Appears on |
|---|---|---|---|
| PrimaryButton | lib/widgets/primary_button.dart | String label, VoidCallback? onPressed | Start, Log in, Sign up, Reset password, Story Details (Update), Add Story (Save Story), Add Memory (Save Memory) |
| AppTextField | lib/widgets/app_text_field.dart | String label, String hint, bool obscureText, Widget? suffixIcon | Log in, Sign up, Reset password, Add Story, Add Memory |
| FilterChipPill | lib/widgets/filter_chip_pill.dart | String label, bool selected, VoidCallback onTap | Library (category filters), Search (category filters), Add Memory (type selector: Overall Review/Chapter/Episode/Volume) |
| StoryPosterCard | lib/widgets/story_poster_card.dart | Story story, VoidCallback onTap | Home ("Continue your stories"), Library (grid) |
| MemoryCard | lib/widgets/memory_card.dart | Memory memory, VoidCallback onTap | Home ("Recent memories"), Story Details ("Memories" list) |
| BottomNavBar | lib/widgets/bottom_nav_bar.dart | int currentIndex, ValueChanged<int> onTap | Home, Library, Search, Profile, Story Details, Memory Details |
| SectionHeader | lib/widgets/section_header.dart | String title, String? actionLabel, VoidCallback? onAction | Home, Library, Search, Profile |
| StatBlock | lib/widgets/stat_block.dart | String value, String label | Profile (Stories / Completed / Memories row) |
| ProgressBarLabeled | lib/widgets/progress_bar_labeled.dart | double progress, String? leadingLabel, String? trailingLabel | Story Details (reading progress), Profile ("Stories by Medium" bars) |
| SettingsTile | lib/widgets/settings_tile.dart | IconData icon, String label, Widget? trailing, VoidCallback? onTap | Settings (Edit Profile, Dark Mode, Sign Out, Delete Account rows) |

![Components](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/images/design-system/04-components.png)

*Note: I used AI to help summarize the information I provided and turn each part into a visual image. The content and information came from my own work, while AI was only used to assist with summarization and visual presentation.*


## Changes since the last version (What changed, and why)

| Element | Prelim said | Now says | Why it changed |
|---|---|---|---|
| Color Palette | 7 hand-picked colors using mostly brown, cream, white, and beige tones | A ColorScheme with primary, onPrimary, secondary, surface, surfaceVariant, onSurface error colors | I changed the palette to make the app look more consistent and to work better with Flutter's theming system. The new colors also give the app more contrast and a less plain appearance. |
| Type Scale | 4 text styles: Heading, Subheading, Body, and Caption | 4 styles mapped to Flutter's TextTheme: displayMedium (56, logo/screen titles), headlineSmall (34, headings), bodyMedium (20, body text), labelSmall (15, captions/meta) | I kept 4 styles but renamed and resized them to match Flutter's named slots and the real sizes used in the mockups, so each is called by name instead of a literal font size. |
| Spacing Rule | 8px tight, 16px standard, and 24px screen padding | 4px base unit (xs), with sm=8, md=16, lg=24; 24px screen edge padding, 12px list-item gaps, 32px section gaps | Measuring the actual grid gaps and margins in the mockups showed the padding is finer-grained than three fixed values — a 4px base unit lets every gap be expressed as a multiple of one number. |
| Reusable Components | 11 general components described mainly by their appearance and where they appear | 10 reusable Flutter widgets with specific files, constructor parameters, and screen usage | I matched the list to what actually repeats across the finished wireframes and mockup, and wrote out the parameters each widget needs so it can be built, not just described. |
| Buttons | One Primary Button style using dark brown | PrimaryButton using the new primary color (#943B41), with reusable label and onPressed parameters | Made the button reusable in code instead of a visual-only spec. |
| Cards | Story and Memory Cards shared a similar white and beige appearance | StoryPosterCard and MemoryCard are separate widgets — one takes a Story, the other a Memory | They display different data shapes (poster + badge vs. quote + date), so they need separate widgets rather than one card styled two ways. |
| Navigation / Headers | Included Screen Header and Bottom Navigation as reusable components | Still included: BottomNavBar (currentIndex, onTap) and SectionHeader (title, actionLabel, onAction) remain in the 10-widget list | Both appear on multiple screens (nav bar on all 6 main screens; section headers on Home, Library, Search, Profile), so they stayed in as reusable custom widgets rather than being dropped. |

