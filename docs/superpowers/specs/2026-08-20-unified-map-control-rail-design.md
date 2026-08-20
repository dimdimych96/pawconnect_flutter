# PawConnect — Unified Liquid Glass Map Control Rail Design Spec

**Date:** 2026-08-20  
**Status:** Approved  
**Target Platform:** Flutter (Android / iOS / Web / macOS)

---

## 1. Executive Summary

PawConnect's interactive map screen currently utilizes two separate floating controls: a `LeftHeaderRail` (containing Search and Map Layers drawer) and a `RightControlRail` (containing Pet Focus, User Location Focus, Add Marker button, and Distance Radar badge). 

This design unifies these floating controls into a single, cohesive **Right Liquid Glass Control Rail** while relocating Search from the map overlay into a dedicated navigation branch in the global **MainShell Tab Bar**.

---

## 2. Architecture & Design Principles

### 2.1 Visual Design Language
- **Liquid Glass Aesthetics:** Dark obsidian glass fill (`Color(0xC8121814)`), `BackdropFilter(sigmaX: 20, sigmaY: 20)`, 1.0px white border (`Colors.white.withOpacity(0.14)`), 24px border radius, and soft drop shadows.
- **Color Accents:**
  - **Pet Focus Active:** Accent Green (`#34D399`) glowing ring & paw icon.
  - **User Focus Active (Default):** Accent Blue (`#38BDF8`) glowing ring & crosshair target icon.
  - **Add Event (+):** Accent Green (`#34D399`) glowing ring & plus icon.
  - **Inactive State:** Slate grey (`rgba(255, 255, 255, 0.60)`).

### 2.2 Component Hierarchy & Geometry

```
+-------------------------------------------------------------+
| MapScreen (Stack)                                           |
|                                                             |
|   [FlutterMap Canvas]                                       |
|                                                             |
|   (Sliding Layers Drawer)  <-  +------------------------+   |
|   +---------------------+      | Unified Control Rail   |   |
|   | Map Layers Filter   |      |  +------------------+  |   |
|   |  - Lost Pets [x]    |      |  | Sub-Capsule:     |  |   |
|   |  - Playgrounds [x]  |      |  |  [Layers 🥞]     |  |   |
|   |  - Companions [x]   |      |  |  [Pet Focus 🐾]  |  |   |
|   +---------------------+      |  |  [User Focus 🎯] |  |   |
|                                |  +------------------+  |   |
|   (Sliding Radar Badge)  <-    |  | --- Divider ---  |  |   |
|   +---------------------+      |  |  [Add Event ➕]  |  |   |
|   | Max: 120m [Route]   |      |  +------------------+  |   |
|   +---------------------+      +------------------------+   |
|                                                             |
|   [Global Floating Liquid Glass TabBar: Map | Search | Pet] |
+-------------------------------------------------------------+
```

---

## 3. Specifications & State Transitions

### 3.1 Control Rail Structure
The unified `RightControlRail` widget measures `width: 44.0` with `padding: EdgeInsets.all(4.0)`:

1. **Upper Sub-Capsule Enclosure:**
   - Container with `color: Colors.white.withOpacity(0.05)`, `borderRadius: BorderRadius.circular(20.0)`, `border: Border.all(color: Colors.white.withOpacity(0.08))`.
   - Contains 3 stacked circular icon buttons (`32x32`):
     - **Layers Button (`Icons.layers_rounded`):** Toggles the sliding map layer filter drawer (`_isLayersExpanded`). Shows a green active dot badge when filter layers are active.
     - **Pet Focus Button (`Icons.pets_rounded`):** Centers map camera on Pet collar (Latitude/Longitude). Displays green glowing active ring when `isPetFocus == true`.
     - **User Focus Button (`Icons.my_location_rounded`):** Centers map camera on User GPS position. Displays blue glowing active ring when `isPetFocus == false` (Default State).

2. **Divider Line:**
   - 1.0px height horizontal divider (`margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4)`), `color: Colors.white.withOpacity(0.10)`.

3. **Lower Action Button:**
   - **Add Event Button (`Icons.add_rounded`):** Accent green circular button that opens `NewMarkerModal` to report lost pets or add new dog park markers.

### 3.2 Sliding Drawers & Badges
- **Map Layers Drawer:** When `_isLayersExpanded == true`, a 240px wide glass card slides out to the left (`right: 52.0`) of the control rail, allowing users to toggle Lost Pets, Dog Parks, and Companions filters.
- **Distance Radar Badge:** When `isPetFocus == true`, the `PetName: Distance` radar capsule slides out to the left (`right: 52.0`) of the Pet Focus button with a quick route creation button.

---

## 4. Re-architecting Main Shell Navigation
- Search functionality (`Icons.search_rounded`) is removed from floating map overlays and added as an explicit navigation branch in `MainShell` tab bar:
  1. **Map Branch (`/map`):** Interactive FlutterMap + Unified Liquid Glass Control Rail.
  2. **Search Branch (`/search`):** Full-screen search & discovery tab for pets, places, and Novosibirsk districts.
  3. **Passport Branch (`/profile`):** Pet passport, GPS collar controls, geofence tuner.
  4. **Feed Branch (`/community`):** District community posts & local feed.
  5. **Settings Branch (`/settings`):** Owner profile & diagnostics.

---

## 5. File Change Matrix

### 5.1 Modified Files
- `lib/features/map/widgets/right_control_rail.dart`: Updated to incorporate the Layer Filter button, layer drawer slider, and dual blue/green focus states.
- `lib/features/map/map_screen.dart`: Updated to use the single consolidated `RightControlRail` and remove `LeftHeaderRail`.
- `lib/shell/main_shell.dart`: Navigation shell updated for tab bar items.

### 5.2 Deleted / Replaced Files
- `lib/features/map/widgets/left_header_rail.dart`: Unused header rail component removed/cleaned up.

---

## 6. Verification Plan

### Automated Verification
- Run `dart analyze` to ensure zero compilation or type errors.

### Runtime Verification
- Connect via `dtd` tool to hot-reload changes on running app instance.
- Validate Liquid Glass blur filters, active focus ring color switches (Blue $\leftrightarrow$ Green), and layer drawer expansion.
