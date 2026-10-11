# Design system for Story Shelf

Sources: `lib/theme/app_theme.dart` and `lib/widgets/`. Light mode only with an optional High contrast setting and three text sizes (Settings).

## Contents

- [Palette](#palette)
  - [Standard](#standard)
  - [Supporting](#supporting)
  - [High contrast](#high-contrast)
  - [Contrast check (WCAG 2.x)](#contrast-check-wcag-2x)
- [Type scale](#type-scale)
- [Spacing](#spacing)
- [Shape and size](#shape-and-size)
- [Components](#components)
- [Changes since the last version](#changes-since-the-last-version-what-changed-and-why)

![Design system overview](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/images/design-system/story-shelf-design-system.png)

## Palette

### Standard

| Role | Hex | Used for |
|---|---|---|
| primary | #943B41 | Buttons, selected chips, story badges, back button, disabled-state base |
| onPrimary | #FFFFFF | Text and icons on primary; text on covers and memory cards |
| secondary | #9DC3D8 | Unselected chips, memory cards, nav bar, Railey titles, section headers, search bar, progress fill, borders |
| surface | #FBF9EC | Scaffold background (page background) |
| surfaceVariant | #D8E4E4 | Text fields, empty-state panels |
| onSurface | #66769A | Body text, hints, nav outline, selected mood border |
| accent / error | #B02D35 | Memory titles, "All Stories" heading, validation errors, selected nav tab |

### Supporting

| Name | Hex | Used for |
|---|---|---|
| storyTintBeige | #D9BFA0 | 15% tint laid over every story cover |
| star | #D9A441 | Rating stars (story details, story form) |
| Cover fallbacks | #6B7A99, #8A5A5A, #5A8A6E, #7A6B99 | Poster background when a story has no image, chosen by title hash |

### High contrast

Turned on in Settings (`AppTheme.highContrast`). Only these values change:

| Token | Standard | High contrast |
|---|---|---|
| secondary | #9DC3D8 | #73ADCD |
| onSurface | #66769A | #495A82 |
| accent / error | #B02D35 | #8A1620 |
| navSelected | accent | primary (#943B41) |
| Nav bar fill | secondary at 60% | secondary at 90% |
| navUnselected | onPrimary | onPrimary at 85% |

![High contrast](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/images/design-system/story-shelf-high-contrast.png)

### Contrast check (WCAG 2.x)

Body text needs 4.5:1, large text 3:1. Ratios are computed from the hex values above.

| Pair | Standard | High contrast |
|---|---|---|
| onSurface on surface (body) | 4.30:1, large only | 6.47:1, pass |
| onSurface on surfaceVariant (fields) | 3.49:1, large only | 5.26:1, pass |
| primary on surface (headings) | 6.71:1, pass | 6.71:1, pass |
| accent on surface | 6.07:1, pass | 8.96:1, pass |
| onPrimary on primary (buttons, badges) | 7.09:1, pass | 7.09:1, pass |
| onPrimary on secondary (chips, memory meta) | 1.87:1, fail | 2.45:1, fail |
| accent on secondary (memory title) | 3.43:1, large only | 3.87:1, large only |
| secondary on surface (section headers) | 1.77:1, fail | 2.31:1, fail |
| Nav unselected | 1.47:1, fail | 2.00:1, fail |
| Nav selected | 4.38:1, pass | 3.19:1, large only |

Known gaps: white text on secondary fails in both modes, and `onSurface` is just under 4.5:1 in standard mode. Using dark text on secondary surfaces, or a deeper blue wherever white text sits on it, would fix the first. Deepening `onSurface` would fix the second.

## Type scale

Two families: **Railey** (bundled script font, `docs/assets/fonts/Railey-PersonalUse.ttf`) for screen titles, and **Montserrat** (Google Fonts) for everything else, always at weight 600 or 700.

| Style | Flutter slot | Font | Size (sp) | Weight | Color | Used for |
|---|---|---|---|---|---|---|
| Display (script) | headlineLarge | Railey | 38 | Regular | secondary | Screen titles: "Your Shelf.", "Library", "Memories", "Profile" |
| Heading | headlineMedium | Montserrat | 26 | Bold | primary (onPrimary on banners) | Title in the Memory of the Day banner on Home |
| Heading small | headlineSmall | Montserrat | 20 | Bold | primary (accent for "All Stories") | "All Stories" in Library, and form and screen headings such as "Add Story", "Settings", "Welcome Back" |
| Title | titleMedium | Montserrat | 17 | SemiBold | onPrimary | Button labels |
| Body | bodyMedium | Montserrat | 15 | SemiBold | onSurface | Inputs, section headers, memory card titles, story names |
| Caption | bodySmall | Montserrat | 12 | SemiBold | onSurface | Dates, meta, hints, badges, nav labels, poster titles |

Text size setting multiplies every size: Small 0.9, Medium 1.0, Large 1.1. Layouts must wrap and never clip.

## Spacing

Base unit 4.

| Token | Value | Used for |
|---|---|---|
| spaceXxs | 2 | Hairline gaps |
| spaceXs | 4 | Between stacked text |
| spaceSm | 8 | Icon to label, mood chip gaps |
| spaceListGap | 12 | Between list items, memory cards and grid covers |
| spaceMd | 16 | Screen edge padding, nav bar side inset |
| spaceLg | 24 | Larger gaps, empty-state padding |
| spaceSectionGap | 32 | Between sections |

## Shape and size

| Element | Value |
|---|---|
| Corner radius | 12 badges and thumbnails, 16 poster cards, 20 memory cards, nav bar and empty states, 24 chips, 28 buttons and text fields |
| PrimaryButton height | 56 |
| Bottom nav height | 64 (side inset 16, bottom inset 22) |
| Filter chip height | 35, 7 gap between chips |
| Poster card aspect ratio | 7 : 10 (`storyCardAspectRatio`) |
| Memory thumbnail | 56 × 72 |
| Poster progress bar | 5 |

## Components

| Component | File | Constructor parameters | Appears on |
|---|---|---|---|
| PrimaryButton | lib/widgets/primary_button.dart | String label, VoidCallback? onPressed, bool isLoading | Start, Log in, Sign up, Reset password, Edit Profile |
| AppTextField | lib/widgets/app_text_field.dart | String label, String? hint, bool obscureText, Widget? suffixIcon, controller, validator and keyboard options | Log in, Sign up, Reset password, Edit Profile (story fields live in StoryForm) |
| AppSearchBar | lib/widgets/app_search_bar.dart | TextEditingController controller, ValueChanged<String> onChanged, String hint, FocusNode? focusNode | Library, Search, Memories |
| FilterChipPill | lib/widgets/filter_chip_pill.dart | String label, bool selected, VoidCallback onTap, double horizontalPadding | Search, Memories, and inside MediumFilterRow |
| MediumFilterRow | lib/widgets/medium_filter_row.dart | List<Medium?> options, Medium? selected, ValueChanged<Medium?> onSelected | Library, Memories |
| StoryPosterCard | lib/widgets/story_poster_card.dart | Story story, VoidCallback onTap | Home ("Continue your stories"), Library grid |
| MemoryCard | lib/widgets/memory_card.dart | Memory memory, VoidCallback onTap | Home ("Recent memories"), Memories |
| MoodPicker / MoodBadge | lib/widgets/mood_picker.dart | Mood? selected, ValueChanged<Mood?> onChanged / Mood mood | Add Memory, Memory Details / badge in MemoryCard |
| BottomNavBar | lib/widgets/bottom_nav_bar.dart | int currentIndex, ValueChanged<int> onTap | Home, Library, Memories, Profile, Story Details, Memory Details |
| SectionHeader | lib/widgets/section_header.dart | String title, String? actionLabel, VoidCallback? onAction | Home |
| EmptyState | lib/widgets/empty_state.dart | IconData? icon, Widget? leading, String title, String message, bool bordered | Home, Library, Memories, Story Details, Search |
| ProfileAvatar | lib/widgets/profile_avatar.dart | String? imageUrl, double size (default 120) | Profile, Edit Profile |
| AppBackButton | lib/widgets/app_back_button.dart | VoidCallback? onPressed, String label | Story Details, Edit Profile, Search, Reset Password, Settings |
| StoryForm | lib/widgets/story_form.dart | Shared form for adding and editing a story | Add Story, Edit Story |

Bottom nav tabs: Home, Library, Memories, Profile.

*Note: I used AI to help read my code and turn the tokens and widgets into the overview images and tables. The values come from my own theme file, and the AI was only used to assist with summarizing and presenting them.*

## Changes since the last version (What changed, and why)

| Element | Previous doc said | Now says | Why it changed |
|---|---|---|---|
| Type scale | Display 56, Heading 34, Body 20, Caption 15 mapped to displayMedium, headlineSmall, bodyMedium, labelSmall | Six styles from `AppTheme.textTheme`: Railey 38 plus Montserrat 26, 20, 17, 15 and 12 | The earlier sizes were from the mockups. The code uses a different set, so the doc now matches it. |
| Heading sizes | One heading row | 26 is the Memory of the Day title and 20 is "All Stories" | Each size now names the place it is actually used. |
| Spacing | Edge padding 24, base 4 | Edge padding 16 (`spaceMd`), 24 for larger gaps, plus 2 and 32 tokens | Matches the `AppTheme.space*` constants. |
| Contrast | Not covered | Standard and high-contrast values with measured WCAG ratios and known gaps | The app has a High contrast setting, so its values need documenting. |
| Navigation | Home, Library, Search, Profile | Home, Library, Memories, Profile | Search is reached from Library, and the nav now has a Memories tab. |
| Components | 10 widgets, including StatBlock, ProgressBarLabeled and SettingsTile | 14 widgets that exist in `lib/widgets`, with the real constructor parameters | Those three files are not in the project, and several newer widgets were missing. |
| Shape and size | Not covered | Radius, heights, aspect ratio | These values repeat across widgets and belong in the system. |
| Images | Three AI-made palette, type and spacing images | One overview image and one high-contrast image, redrawn from the code | The old images showed the earlier palette and sizes. |
