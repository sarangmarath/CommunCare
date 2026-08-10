# CommunCare

**Civic issue reporting made simple.** CommunCare is a two-sided platform that lets citizens report infrastructure problems — potholes, pipe leaks, waste management issues, gutter damage — with a geo-tagged photo, while giving local municipal staff a real system to review, track, and resolve them.

Built for the **Build Beyond Hackathon 2026**.

---

## Demo

[Watch the demo video](https://www.youtube.com/watch?v=VYv8jBRUH2s)

---

## Inspiration

We've seen it firsthand near our hometown — potholes, broken pipes, damaged roads that just sit there for months, sometimes years. Not because no one notices, but because there's no real way to report them. Most people don't even know who to call. And when someone does complain, it usually just disappears into nothing — no tracking, no follow-up, no accountability.

We wanted to fix that gap directly: give citizens a simple, direct way to document and report an issue with actual proof — a photo, a location, a category — and give local authorities a structured system to see what's been reported, act on it, and be accountable for the outcome.

---

## What It Does

### For citizens (mobile app)
- **Register/login** with a real account (Supabase Auth)
- **Take a geo-tagged photo** of an issue directly through the in-app camera — GPS coordinates captured automatically
- **Select an issue category**: Pothole, Pipe Leakage, Waste Management, Gutter Issue, Road Damage, or Other
- **Add a description** and submit — instantly logged with a unique reference number
- **Track report status** through a personal history: Pending → Under Review → Resolved
- View recent activity right from the home screen

### For municipal staff (web dashboard)
- View all incoming reports with photo, GPS location, category, and description
- Approve valid reports and move them into an active review pipeline
- Mark issues as resolved once fixed
- See everything sync in real time with the mobile app, since both read from the same database

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| Camera & GPS | `image_picker`, `geolocator` |
| Backend | Supabase (PostgreSQL, Auth, Storage) |
| Authentication | Supabase Auth (email/password) |
| Admin dashboard | HTML, CSS, JavaScript |
| Version control | Git / GitHub |

All backend infrastructure runs on Supabase's free tier — no billing setup required, making the stack realistically deployable for an actual small municipality with no budget.

---

## 🗄️ Database Schema

Two core tables in Supabase (PostgreSQL):

**`users`**
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key, linked to Supabase Auth |
| name | text | |
| email | text | |
| profile_photo_url | text | |
| role | text | Default: `citizen` |
| created_at | timestamptz | |

**`report`**
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | Foreign key → users.id |
| photo_url | text | Supabase Storage public URL |
| latitude / longitude | float8 | Captured via `geolocator` |
| category | text | e.g. Pothole, Pipe Leakage |
| description | text | |
| status | text | Default: `Pending` |
| created_at | timestamptz | |

Photos are stored in a public Supabase Storage bucket (`report-photos`), with the resulting URL saved on the report row.

---

## App Screens

- **Splash Screen** — app branding, checks auth session
- **Login / Register** — real authentication via Supabase Auth
- **Home Screen** — capture photo, fill out report form, view recent activity, submit
- **Success Screen** — confirmation with reference number
- **Logs Screen** — full history of a user's submitted reports with live status
- **Profile Screen** — user info and account options

---

## Project Structure

CommunCare/
├── communcare/ # Flutter mobile app
│ ├── lib/
│ │ ├── main.dart
│ │ └── screens/
│ │ ├── splash_screen.dart
│ │ ├── login_screen.dart
│ │ ├── register_screen.dart
│ │ ├── home_screen.dart
│ │ ├── report_form_screen.dart
│ │ ├── success_screen.dart
│ │ ├── logs_screen.dart
│ │ └── profile_screen.dart
│ ├── assets/
│ └── pubspec.yaml
└── admin-website/ # Municipal review dashboard
└── communcare-review.html

---

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio (with an emulator or a physical Android device)
- A free [Supabase](https://supabase.com) project

### Mobile app
```bash
cd communcare
flutter pub get
flutter run
```

Update `lib/main.dart` with your own Supabase Project URL and anon/publishable key if setting up a fresh backend.

### Admin dashboard
Open `admin-website/communcare-review.html` directly in a browser, or serve it with any static file server. It connects to the same Supabase project as the mobile app.

---

## Challenges We Ran Into

- Setting up a full mobile development environment (Flutter, Android Studio, an emulator) from scratch, with no prior mobile development experience
- Debugging Android's Gradle build system and repeated device-connection errors caused by limited local machine resources
- Designing a database schema that correctly linked citizen reports to user accounts via foreign keys, with Row Level Security in mind
- Iterating through multiple UI redesigns — from a default Material look to a custom forest-green, glassmorphism-inspired interface

---

## What We're Proud Of

- Going from zero Flutter experience to a fully working, end-to-end mobile app in a matter of days
- A complete real-world data loop: photo + GPS capture → database → municipal review → status update back to the citizen
- Real user authentication, not a stubbed-out login
- An entirely free-tier stack, making the project realistically adoptable by an actual local government

---

## What's Next

- Public accountability metrics — how fast local authorities resolve reported issues
- Duplicate-report detection for issues reported by multiple nearby citizens
- Push notifications when a report's status changes
- AI-based photo classification to auto-suggest the issue category
- Expanding beyond a single hometown pilot to other underserved municipalities

---

