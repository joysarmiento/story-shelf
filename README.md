# Story Shelf

> One personal place to track the books, manga, movies, dramas and anime you love, and to journal how each one made you feel.

**Live demo:** https://joysarmiento.github.io/story-shelf/

**Demo video:** `docs/demo.mp4`  (link it here once it exists)

**Course:** Applications Development and Emerging Technologies (6ADET), Holy Angel University

**Author:** Maria Anne Joy T. Sarmiento

This repository lives in the author's own GitHub account and is public on purpose. There is no `student.json` here and there should not be one: see [`docs/06-security-and-privacy.md`](docs/06-security-and-privacy.md) for what a public repo means for secrets and personal data.

---

## Screenshots

See all screens in [docs/02-mockup.md](https://github.com/joysarmiento/story-shelf/blob/main/docs/02-mockup.md):

| Home | Library | Story details | Memory details |
| --- | --- | --- | --- |
| ![Home](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/final_screens/05_Home.png) | ![Library](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/final_screens/06_Library.png) | ![Story details](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/final_screens/08_Story_Details.png) | ![Memory details](https://github.com/joysarmiento/story-shelf/blob/main/docs/assets/final_screens/11_Memory_Details.png) |

## What it does

People who read and watch many kinds of stories usually keep their progress, ratings and thoughts scattered across different apps, or rely on memory. Story Shelf keeps them together, with a cozy journal at the heart of it. After a chapter or an episode, you can write down what you felt, what surprised you and what you want to remember. Your shelf tracks where you are, and your journal keeps how it felt.

- **Build your library.** Add books, comics (manga, manhwa, webtoons), movies and series (dramas, anime, TV shows) with a cover, creator, release year, status (Not Started, Started, Completed), progress, rating and favorite flag.
- **Write memories.** Journal entries tied to a story: an overall review, or a note on a specific chapter, episode or volume, with an optional title, rating and favorite quote.
- **Find things fast.** Search, filter by medium and sort in both the Library and the Memories tabs.
- **Pick up where you left off.** The Home screen shows the stories you are in the middle of, your recent memories, and "A Memory From This Day", which rotates between two of your stories each day.
- **Make it readable for you.** Choose a text size and turn on high contrast; both are saved to your account and applied on every sign-in.
- **Own your account.** Sign up, log in, reset your password, edit your profile and avatar, or delete your account and data.

## Built with

| | |
| --- | --- |
| Framework | Flutter (Dart) |
| State | `setState` |
| Backend and storage | Supabase (auth, Postgres database, storage bucket for cover images) |
| Other packages | `supabase_flutter` (backend client), `flutter_dotenv` (reads `.env` keys), `google_fonts` (typography), `image_picker` (cover and avatar uploads), `device_preview` (phone frame while developing in a browser) |
| Fonts and assets | Railey (custom display font, personal-use licence), own logo and wordmark |
| Hosting | GitHub Pages, deployed by `.github/workflows/deploy-web.yml` on every push to `main` |

## Running it yourself

```bash
flutter pub get
cp .env.example .env      # then fill in your own Supabase values, see below
flutter run -d web-server --web-port 8080
```

Then open http://localhost:8080. Requires Flutter 3.44 or newer (run `flutter --version` to check).

### Environment variables

This project reads its configuration from a `.env` file that is **not** in the repository. Copy `.env.example`, fill in your own values, and never commit the result.

| Variable | What it is | Where to get one |
| --- | --- | --- |
| `SUPABASE_URL` | The URL of your Supabase project | Supabase dashboard > Project Settings > API |
| `SUPABASE_PUBLISHABLE_KEY` | The publishable (anon) key for that project | Same page, under the project API keys |

Both values are designed to be shipped inside a client app. Your database is protected by Row Level Security policies, not by hiding these two values. The deploy workflow reads the same names from repository secrets (Settings > Secrets and variables > Actions).

## Privacy and secrets

- **What is stored:** your email, display name, username and optional avatar; the stories and memories you write; cover images you upload; and your text-size and contrast preferences. All of it is stored in the author's Supabase project, tied to your user ID.
- **Where the secrets live:** locally in `.env` (git-ignored) and in repository secrets for the deploy workflow. Only the Supabase URL and publishable key reach the web build. No secret or service-role key is used anywhere in the app. Access to the data is controlled by Supabase Row Level Security; see [`docs/06-security-and-privacy.md`](docs/06-security-and-privacy.md) for the policies.
- **Sample data:** the sample data, screenshots and demo video contain no real personal information.

## Project documentation

| Document | |
| --- | --- |
| [Proposal](docs/01-proposal.md) | the problem, the users, the scope |
| [Mockup and wireframes](docs/02-mockup.md) | what it looks like, and the screen flow |
| [Design system](docs/03-design-system.md) | colors, type, spacing, components |
| [Weekly reports](docs/04-weekly-reports.md) | what happened each week |
| [Demo video](docs/05-demo-video.md) | the recording and what it shows |
| [Security and privacy](docs/06-security-and-privacy.md) | the checklist, filled in |
| [Security Checklist](docs/07-security-checklist.md) | the checklist, filled in |
| [AI usage](AI-USAGE.md) | how AI was used, where it got things wrong, who wrote what |

## Status and what is next

**Works today:** sign up, log in and password reset; add, edit and delete stories and memories; cover image upload; search, filter and sort in Library and Memories; the Home dashboard with the daily rotating memory; profile editing; text-size and high-contrast settings; account deletion; page-flip animation between tabs.

**Known limitations**

- The app needs a network connection; there is no offline mode or local cache.
- Lists load when you open a screen and do not refresh on pull-down yet.
- The deployed demo is wrapped in a phone frame by `device_preview`.
- Automated test coverage is small.
- Story progress uses a current-versus-total format, which may not be suitable for every type of media.

**Ideas for next**

- Pull-to-refresh on Home, Library and Memories
- Reading stats on the Profile screen (stories finished, memories written, average rating)
- A one-tap "+1 chapter/episode" button on in-progress stories
- A Favorites filter in the Library
- Improve progress tracking for movies by using minutes watched out of the total runtime instead of the current-versus-total format.

## Credits

- Packages: see `pubspec.yaml`
- Railey font: personal-use licence; check the licence terms before using it commercially
- Logo, wordmark and screen designs: made by the author
- Backend: [Supabase](https://supabase.com)

## AI use

![Built with AI assistance](https://img.shields.io/badge/built%20with-AI%20assistance-0b5fff)

I used Claude as a coding assistant throughout the project. It produced first versions of the screens, models, navigation, theme and Supabase wiring, and I then rewrote, restyled and extended them to fit my own design and data. The full, dated account (what I asked, what I kept or changed, where the AI got it wrong, and who wrote what) is in [AI-USAGE.md](AI-USAGE.md).

## Licence

MIT, see [LICENSE](LICENSE).
