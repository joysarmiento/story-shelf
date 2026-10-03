# AI usage

This project was built with AI assistance. This file is the record of it. It is
graded as the finals badge, and it is worth 100 points.

Start it in week 1 and keep it up as you go. The commit history of this file is
part of the evidence: a file written all at once the night before the deadline
looks exactly like what it is.

## 1. How I used AI
> **Note:** I started this log late. I reconstructed these entries on 2026-10-03 from my commit history and my chat history. Entry dates are the dates of the commits where the work landed, and each entry describes something I really did.

### 2026-09-23 - Planning and building the authentication screens

- **Tool:** Claude
- **What I asked for:** Help planning and implementing the authentication screens for Story Shelf: Start, Log In, Sign Up, and Reset Password.
- **What it gave back:** Flutter widget structures, reusable text fields and buttons, and Supabase authentication logic.
- **What I kept, what I changed, and why:** I kept some of the suggested structure and the overall Supabase authentication approach. I changed the wording, font sizes, content, and mainly the UI of every screen so it matches my Story Shelf design. The suggested styling didn't fit my project, so I wrote `app_theme` myself, with only a little help from online sources, and it became the file I rewrote the most. The font also didn't fit: I added my own chosen font and my own logo instead of the defaults. I haven't changed the Supabase logic itself. I only set up my own Supabase project and added the `.env` file with my own keys.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/fe1109360f0a9b980be32491a41daffc23956925

### 2026-09-23 - Home and Library Screens

- **Tool:** Claude
- **What I asked for:** Help planning and implementing the Home and Library Screens.
- **What it gave back:** Flutter widget structures, navigation between the screens, models, and the Home and Library screens themselves.
- **What I kept, what I changed, and why:** I kept some of the suggested structure and the overall screen layouts. I replaced the text headers ("Your Shelf" and "Library") with images so they use the custom font I wanted. I changed the sizes and spacing throughout, and fixed the size of the story poster cards so nothing gets cut off. Some of the information needed for the "memory of the day" section was missing, so I added it and fixed its format. I also reworked the UI on both screens. For the sample data, I wrote my own story entries and built that file myself, using online sources for reference.
- **Commit:** https://github.com/joysarmiento/story-shelf/commit/12dd16b32dc7807d679c5c76c5285065bd163211

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
