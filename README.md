# RumiRoutine

RumiRoutine is a chore tracker with game-like features, designed to help young adults manage shared chores in a fun and motivating way. You can create and assign chores with details like the title, description, due date, XP status, and who’s responsible. The app supports repeating chores and can automatically rotate tasks, so everyone gets a fair share. You can choose from common chores or add your own to fit your household. 

We imagine roommates using RumiRoutine daily to check off chores, keep their streaks going, and earn rewards together. Like duolingo, you’ll earn XP, unlock achievements, and improve the mood of your shared character, Rumi, who reflects how your household is doing. Fun notifications, cosmetic rewards, and clear milestones help everyone feel like they’re making progress as a team. The app combines useful tools with simple game features to make chores less stressful and shared living more enjoyable. 

## Getting Started

### 1) Clone the repository

```bash
git clone <your-repo-url>
cd rumiroutine
```

### 2) Pull the latest changes

Before starting work each day, sync your branch:

```bash
git pull origin <your-branch-name>
```

If you are working directly on `main`:

```bash
git pull origin main
```

### 3) Set up Flutter (if needed)

If Flutter is not installed yet, follow the official setup guide:

- [Flutter installation guide](https://docs.flutter.dev/get-started/install)

Then verify your setup:

```bash
flutter doctor
```

### 4) Install dependencies and run the app

From the `flutter_application` folder:

```bash
cd flutter_application
flutter pub get
flutter run
```

Tip: use a connected phone or emulator when running `flutter run`.

## Application Structure

The project has a Flutter app in `flutter_application/`. Inside that app:

- `lib/main.dart`  
	Minimal entry point that starts the app.

- `lib/app.dart`  
	Root app configuration (`MaterialApp`, theme, and initial route/screen).

- `lib/pages/auth/`  
	Authentication flow screens:
	- `login_page.dart`
	- Will add sign up page here

- `lib/pages/shell/app_shell.dart`  
	Main logged-in shell with bottom navigation (Home, Trophy/Progress, Profile).

- `lib/pages/home/home_page.dart`  
	Home page skeleton.

- `lib/pages/progress/progress_page.dart`  
	Progress page skeleton.

- `lib/pages/profile/profile_page.dart`  
	Profile page skeleton.

