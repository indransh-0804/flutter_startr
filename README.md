# Flutter Android Starter Template 

## Overview

This is a minimal Flutter Android-only starter project configured for NixOS using a flake-based development environment. It avoids iOS, web, and desktop clutter, focusing solely on Android development.


## Prerequisites

* NixOS with **flakes enabled** (`nix.enableFlakes = true`)
* Android SDK installed
* Flutter installed (via nix or manual setup)
* Emulator or physical Android device for testing


## Getting Started

1. Clone the repository:

```bash
git clone <repo-url>
cd <project-name>
```

2. Enter the flake development shell:

```bash
direnv allow
```


## Renaming the App

If you want to rename your project (e.g., changing app/package name), update the following files:

| File / Folder                                     | What to Change                         |
| ------------------------------------------------- | -------------------------------------- |
| `android/app/src/main/AndroidManifest.xml`        | `package` attribute in `<manifest>`    |
| `android/app/build.gradle`                        | `applicationId` under `defaultConfig`  |
| `lib/main.dart`                                   | Class names / import paths if needed   |
| `pubspec.yaml`                                    | `name:` field for Flutter package name |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Package declaration at top of file     |

**Tip:** Make sure the `package` in `AndroidManifest.xml` matches the `applicationId` in `build.gradle`.

