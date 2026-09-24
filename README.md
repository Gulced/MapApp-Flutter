# MapApp Flutter Client

A Flutter mapping client associated with the MapApp project, using map rendering, local persistence, and provider-based state.

## Overview

A Flutter mapping client associated with the MapApp project, using map rendering, local persistence, and provider-based state. The description and capabilities in this document are limited to behavior that can be verified in the repository source.

## Key Features

- Google Maps-based map UI
- Riverpod state management
- SQLite local persistence
- UI, view-model, provider, model, and service separation

## Tech Stack

- Dart
- Flutter
- Riverpod
- Google Maps
- SQLite
- Path Provider

## Architecture

The client separates UI, view-model, provider, model, and service responsibilities. Riverpod coordinates application state.

## Project Structure

- `lib/ui/` — screens and widgets
- `lib/viewmodels/` — presentation logic
- `lib/providers/` — Riverpod providers
- `lib/models/` — data types
- `lib/services/` — storage/integration services

## Getting Started

Run the commands appropriate to the project root:

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
```

## Technical Highlights

- Google Maps integration
- Riverpod-managed state
- SQLite local persistence

## Possible Improvements

- Add or expand automated tests around core workflows.
- Document deployment and environment-specific configuration.
- Add CI checks for build, linting, and tests where they are not already present.

## Verification Notes

The SQLite helper seeds a demonstration administrator account with a plaintext password. This should be removed or replaced with a secure authentication flow before production use.
