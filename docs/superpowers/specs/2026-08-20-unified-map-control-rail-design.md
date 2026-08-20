# PawConnect — Unified Liquid Glass Map Control Rail & Search Screen Spec

**Date:** 2026-08-20  
**Status:** Approved  
**Target Platform:** Flutter (Android / iOS / Web / macOS)

---

## 1. Executive Summary

PawConnect's interactive map screen currently utilizes two separate floating controls: a `LeftHeaderRail` (containing Search and Map Layers drawer) and a `RightControlRail` (containing Pet Focus, User Location Focus, Add Marker button, and Distance Radar badge). 

This design unifies these floating controls into a single, cohesive **Right Liquid Glass Control Rail** while relocating Search from the map overlay into a dedicated navigation branch in the global **MainShell Tab Bar**, complete with a dedicated **Search Screen (`SearchScreen`)** featuring interactive 2x2 category tiles and local activity stream.

---

## 2. Architecture & Design Principles

### 2.1 Visual Design Language
- **Liquid Glass Aesthetics:** Dark obsidian glass fill (`Color(0xC8121814)`), `BackdropFilter(sigmaX: 20, sigmaY: 20)`, 1.0px white border (`Colors.white.withOpacity(0.14)`), 20-24px border radius, and soft specular glow gradients.
- **Color Accents:**
  - **Pet Focus / Lost Pets:** Accent Red (`#F87171`) / Accent Green (`#34D399`).
  - **User Focus / Navigation:** Accent Blue (`#38BDF8`).
  - **Playgrounds / Dog Parks:** Accent Green (`#34D399`).
  - **Companions:** Accent Yellow (`#FBBF24`).

### 2.2 Component Hierarchy & Navigation Flow

```
+---------------------------------------------------------------------------------+
| MainShell (StatefulShellRoute.indexedStack)                                     |
|                                                                                 |
|   Branch 0: /map      --> MapScreen + Unified RightControlRail                  |
|   Branch 1: /search   --> SearchScreen (2x2 Grid + Filtered Activity Cards)    |
|   Branch 2: /profile  --> PetProfileScreen                                      |
|   Branch 3: /community--> CommunityScreen                                       |
|   Branch 4: /settings --> SettingsScreen                                        |
|                                                                                 |
|   [Global Floating Liquid Glass TabBar: Map | Search | Passport | Feed | Set]   |
+---------------------------------------------------------------------------------+
```

---

## 3. Specifications

### 3.1 Unified Map Control Rail (`RightControlRail`)
The unified `RightControlRail` widget measures `width: 44.0` with `padding: EdgeInsets.all(4.0)`:

1. **Upper Sub-Capsule Enclosure:**
   - Container with `color: Colors.white.withOpacity(0.05)`, `borderRadius: BorderRadius.circular(20.0)`, `border: Border.all(color: Colors.white.withOpacity(0.08))`.
   - Contains 3 stacked circular icon buttons (`32x32`):
     - **Layers Button (`Icons.layers_rounded`):** Toggles the sliding map layer filter drawer (`_isLayersExpanded`). Shows a green active dot badge when filter layers are active.
     - **Pet Focus Button (`Icons.pets_rounded`):** Centers map camera on Pet collar. Displays green glowing active ring (`#34D399`) when `isPetFocus == true`.
     - **User Focus Button (`Icons.my_location_rounded`):** Centers map camera on User GPS position. Displays blue glowing active ring (`#38BDF8`) when `isPetFocus == false` (Default State).

2. **Divider Line & Action Button:**
   - 1.0px height horizontal divider (`margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4)`).
   - **Add Event Button (`Icons.add_rounded`):** Accent green circular button that opens `NewMarkerModal`.

---

### 3.2 Dedicated Search Screen (`SearchScreen`)
Located at route `/search`, the Search Screen provides full-screen discovery using native `GlassContainer` and `GlassCard` widgets:

1. **Header Section:**
   - Screen Title **"Поиск"** + Subtitle `Новосибирск • 10 районов` + District Badge (`📍 Центральный`).
   - Liquid Glass Search Field with `Icons.search_rounded`, query input, and clear button.

2. **Interactive 2x2 Category Grid Tiles:**
   - **`🐾 Пропажи / SOS`:** Accent Red border (`#F87171`), live count badge (`2 активных`).
   - **`🐶 Площадки`:** Accent Green border (`#34D399`), live count badge (`5 площадок`).
   - **`🏥 Ветклиники`:** Accent Blue border (`#38BDF8`), live status badge (`4 рядом`).
   - **`🎾 Компаньоны`:** Accent Yellow border (`#FBBF24`), live count badge (`8 онлайн`).
   - *Behavior:* Tapping any tile highlights it with an active neon glow and filters the activity stream below.

3. **Filtered Results & Activity Stream:**
   - **Lost Pet SOS Cards:** Red border, photo avatar, status badge, distance (`120м от вас`), and button **`[Показать на карте 📍]`** (navigates to `/map` and focuses camera on lost pet marker).
   - **Playground Cards:** Green border, distance (`350м`), equipment tags, and button **`[Построить маршрут 🧭]`** (navigates to `/map` and builds cyan route).
   - **Vet Clinic Cards:** Blue border, 24/7 status badge, address, emergency phone.

---

## 4. MainShell & TabBar Re-Architecture
Update `app_router.dart` and `main_shell.dart` to support 5 branches:
1. **Карта (`/map`):** `Icons.map_outlined` / `Icons.map_rounded`
2. **Поиск (`/search`):** `Icons.search_outlined` / `Icons.search_rounded`
3. **Паспорт (`/profile`):** `Icons.pets_outlined` / `Icons.pets_rounded`
4. **Лента (`/community`):** `Icons.forum_outlined` / `Icons.forum_rounded`
5. **Настройки (`/settings`):** `Icons.settings_outlined` / `Icons.settings_rounded`

---

## 5. File Change Matrix

### 5.1 Modified Files
- `lib/features/map/widgets/right_control_rail.dart`: Unified control rail with Layer Filter drawer & dual blue/green focus states.
- `lib/features/map/map_screen.dart`: Updated to use single `RightControlRail`.
- `lib/routes/app_router.dart`: Added `/search` branch to `StatefulShellRoute.indexedStack`.
- `lib/shell/main_shell.dart`: Added Search tab item to liquid glass bottom tab bar.

### 5.2 New Files
- `lib/features/search/search_screen.dart`: Search Screen implementation with 2x2 grid & results stream.

---

## 6. Verification Plan

### Automated Verification
- Run `dart analyze` to ensure zero compilation errors.

### Manual Verification
- Hot reload via `dtd` tool.
- Test navigation between Map, Search, Passport, Feed, and Settings tabs.
- Verify 2x2 tile filter tapping on Search screen and map navigation buttons.
