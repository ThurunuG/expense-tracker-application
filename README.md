# Expense Tracker (Flutter + Firebase)

A clean, full-featured personal expense tracker built with Flutter and Firebase, created as a practical task submission for the CyphLab Flutter Developer Internship.

## Features Implemented

**Core requirements**
- Add, edit, and delete expenses (with swipe-to-delete + confirmation dialog)
- Category selection (Food, Transport, Shopping, Entertainment, Health, Bills, Education, Other)
- Cloud storage per user via Cloud Firestore (`users/{uid}/expenses/{expenseId}`)
- Current month total, shown on a summary card with month navigation
- Full expense history list, newest first
- Filter by category (chips) and by month (toggle), plus free-text search
- Form validation on title, amount, and note length
- Explicit loading / empty / error states for the expense list, with pull-to-refresh and retry

**Extra features**
- Firebase Authentication (email/password sign up & login, plus "Continue as Guest" anonymous auth)
- Dark mode with a persisted preference (SharedPreferences)
- Category breakdown pie chart for the selected month
- 6-month spending trend bar chart
- Search across title and notes
- Firestore security rules scoping data to the authenticated owner

## Tech Stack / Packages

| Purpose               | Package                |
|-----------------------|-------------------------|
| Backend / database    | `firebase_core`, `cloud_firestore` |
| Auth                  | `firebase_auth`         |
| State management      | `provider`              |
| Charts                | `fl_chart`              |
| Fonts                 | `google_fonts`          |
| Dates / currency      | `intl`                  |
| Unique IDs            | `uuid`                  |
| Local prefs (theme)   | `shared_preferences`    |

## Project Structure

```
lib/
  models/         # Expense data model (Firestore <-> Dart mapping)
  services/       # AuthService, FirestoreService — talk to Firebase directly
  providers/      # AuthProvider, ExpenseProvider, ThemeProvider (ChangeNotifier)
  screens/        # LoginScreen, HomeScreen, AddEditExpenseScreen, SummaryScreen, AuthGate
  widgets/        # Reusable UI: list item, summary card, filter bar, charts, state views
  utils/          # Constants (categories/colors/icons), validators, formatters
  main.dart       # App entry point, theming, provider wiring
```

Architecture is a simple layered approach: **Screens** read state from **Providers**, which call **Services** for Firebase I/O. This keeps UI, state, and data access cleanly separated and easy to test/extend.

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.22+) installed and on PATH
- A Firebase account
- Node.js (for the Firebase CLI) — `npm install -g firebase-tools`

### 2. Get the code running locally
If you cloned this repo and it does **not** yet contain native `android/`, `ios/`, etc. folders (only `lib/` + `pubspec.yaml`), generate them first:
```bash
flutter create --project-name expense_tracker --org com.yourname .
```
This scaffolds the native platform folders without touching the existing `lib/` and `pubspec.yaml`.

Then fetch packages:
```bash
flutter pub get
```

Open `android/app/build.gradle` and set:
```groovy
minSdk = 23
```
(`firebase_auth` requires at least API 23; Flutter's default is lower.)

### 3. Configure Firebase

Enable the backend first, in the [Firebase Console](https://console.firebase.google.com):
1. Create a new project.
2. **Authentication** → Get started → Sign-in method tab → enable **Email/Password**. Then click "Add new provider" and enable **Anonymous** too (powers the app's "Continue as Guest" button).
3. **Firestore Database** → Create database → **Standard edition** → Start in production mode → pick any location → Enable.
4. In Firestore's **Rules** tab, paste in the contents of `firestore.rules` from this repo and click Publish.

Then connect your app to that project. Two ways to do this — pick whichever works for you:

**Option A — FlutterFire CLI (recommended, does every platform in one step)**
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```
Select your Firebase project, then the platforms you want (Android/iOS/web). This overwrites `lib/firebase_options.dart` with your real credentials and wires up the native config files automatically.

If `firebase login` doesn't open a browser correctly, use `firebase login --no-localhost` instead and follow the printed URL/code flow manually.

**Option B — Manual Android setup (if the CLI login won't cooperate)**
1. Firebase console → gear icon → Project settings → Your apps → Add app → Android. Enter your package name (must match `applicationId`/`namespace` in `android/app/build.gradle` exactly, e.g. `com.yourname.expense_tracker`). Register and download `google-services.json`.
2. Place that file at `android/app/google-services.json`.
3. In `android/settings.gradle`, add to the `plugins { }` block:
   ```groovy
   id "com.google.gms.google-services" version "4.4.2" apply false
   ```
4. In `android/app/build.gradle`, add to the `plugins { }` block:
   ```groovy
   id "com.google.gms.google-services"
   ```
5. In `lib/main.dart`, since there's no `firebase_options.dart` involved in this path, change:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
   to:
   ```dart
   await Firebase.initializeApp();
   ```
   (On Android, the SDK reads its config from `google-services.json` automatically.)
6. Run `flutter clean && flutter pub get` before your next build — the Gradle plugin needs a clean build to pick up the new config the first time.

Note: Option B only sets up Android. If you need iOS/web too, use Option A for those platforms.

### 4. Run the app
```bash
flutter run
```

### 5. Build a release APK (optional, for submission)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## AI Tools Used

**Claude (Anthropic)** was used as a development assistant throughout this project, roughly the way I'd use a senior dev pairing with me — generating a first draft, then working through it with me.

- **Initial scaffold**: Claude generated the first version of the project structure (models, services, providers, screens, widgets) and the Firestore data model (`users/{uid}/expenses`).
- **My review and changes**: I went through the generated code to understand the state management flow (Provider/ChangeNotifier), the Firestore read/write logic, and the filtering/search/chart logic, and adjusted parts of it to match how I wanted the app to behave.
- **Testing**: I ran the app on an Android emulator, added/edited/deleted real expenses, and verified data was reaching Firestore correctly and that auth (email/password + guest) worked end-to-end before recording the demo.

## Notes

- Currency is formatted as USD (`$`) by default — change the symbol in `lib/utils/formatters.dart` if needed.
- Data is scoped per authenticated user; Firestore rules (`firestore.rules`) block any cross-user access.
