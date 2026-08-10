# PawConnect — System Instructions & Architecture for AI Agents

Welcome AI Agent (Antigravity, Cursor, Windsurf, Claude Code, ChatGPT)!

## 📌 Project Overview
PawConnect is a cross-platform Flutter application built with an **Apple Liquid Glass** design language (Obsidian dark background `#0A0A0C`, slate cards `#1C1C1E`, `BackdropFilter` glassmorphic overlays).

Full specification available in [`pawconnect_flutter_spec.md`](./pawconnect_flutter_spec.md).

## ⚡ Zero-Boilerplate (Vibe Coding) Rules
1. **NO Code Generators**: NO `build_runner`, `freezed`, `json_serializable`, or `hive_generator`. All models are plain Dart classes with explicit manual `fromJson` and `toJson` methods.
2. **Maps via `flutter_map`**: Maps use `flutter_map` + `latlong2` with **CartoDB Dark Matter** tiles (`https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png`). Markers are standard Flutter widgets (`Marker(child: Widget)`).
3. **Offline Mock Fallback**: All `Dio` HTTP calls catch errors and immediately fall back to local `MockData` so the app is 100% functional without a backend.
4. **State Management**: `flutter_riverpod` using `StateNotifier` and standard `Provider` / `StateNotifierProvider`.

## 📁 Key File Structure
- `lib/core/theme/colors.dart`: Liquid Glass obsidian palette & border styles.
- `lib/core/widgets/glass_widgets.dart`: `GlassContainer`, `GlassCard`, `GlassCapsule`.
- `lib/models/`: Plain Dart data models (`MapMarkerModel`, `GpsDeviceModel`, `PetReminderModel`, `CommunityPostModel`).
- `lib/providers/`: Riverpod providers (`map_provider.dart`, `reminders_provider.dart`, `community_provider.dart`, `user_provider.dart`).
- `lib/routes/app_router.dart`: `GoRouter` with `StatefulShellRoute.indexedStack`.
- `lib/shell/main_shell.dart`: Floating Liquid Glass bottom bar & top `BreachAlertBanner`.
- `lib/features/map/`: Interactive map screen, collar pulse animation, search bar, filters, detail sheet.
- `lib/features/profile/`: Pet passport, GPS collar controls, geofence radius tuner, vet calendar.
- `lib/features/community/`: Novosibirsk 10 districts feed, category filters, Heart Pop likes.
- `lib/features/settings/`: Owner profile, push toggles, system diagnostics, alert simulator.
