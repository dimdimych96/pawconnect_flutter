# Design Specification: Map Search & Layer Filter Rail (LeftHeaderRail)

**Date**: 2026-08-16  
**Status**: Approved  
**Target Feature**: `lib/features/map/widgets/left_header_rail.dart` & `lib/features/map/map_screen.dart`

---

## 1. Overview & Architecture

The **LeftHeaderRail** introduces a minimalist, dual-action Liquid Glass control unit positioned in the top-left corner of the `MapScreen` (`left: 14.0`, `top: SafeArea top + 8.0`). 

It provides 100% architectural, visual, and geometric symmetry with the right-side control rail (`RightControlRail`), replacing legacy text-heavy headers with clean vector icons and fluid side-sliding glass drawers.

---

## 2. Component Design & Geometry

### 2.1 Base Container (`LeftHeaderRail`)
- **Container**: Floating capsule `Color(0xC8121814)` with `BackdropFilter` 20px blur and `BorderRadius.circular(24)`.
- **Border**: `1px` solid `rgba(255, 255, 255, 0.14)`.
- **Inner Buttons**: Two 1:1 round buttons (`BoxShape.circle`, `width: 32, height: 32`):
  1. **Top Button — Search**: `Icons.search_rounded` (white icon in idle state).
  2. **Bottom Button — Map Layers**: `Icons.layers_rounded` (white icon in idle state, highlighted with emerald glow `#00E676` and an LED active dot when active).

---

## 3. Expansion Interactions

### 3.1 Search Input Expansion (Tap on `Icons.search_rounded`)
- Tapping the search icon smoothly expands the top container to the right into a 240px wide horizontal Liquid Glass search bar (`AnimatedContainer`, 250ms curve).
- **Search Bar Content**:
  - `Icons.search_rounded` in accent emerald `#00E676`.
  - `TextField` with `HintText: "Поиск по карте..."`, custom emerald cursor, white text.
  - Clear / Close button (`Icons.close_rounded`), tapping which clears text or collapses the search bar.

### 3.2 Map Layers Drawer Expansion (Tap on `Icons.layers_rounded`)
- Tapping the layers icon slides out a 240px wide Liquid Glass drawer card (`glass-card-drawer`) to the right with `BorderRadius.circular(20)` and 20px blur.
- **Drawer Header**: `"Слои карты"` with subtitle `"3 активны"`.
- **3 Monochrome Category Rows** (uniform `background: rgba(255, 255, 255, 0.04)` & `border: 1px solid rgba(255, 255, 255, 0.08)`):
  1. `Icons.warning_amber_rounded` + `"Потерянные питомцы"` + Green iOS Toggle Switch (`lost_pet`).
  2. `Icons.park_rounded` + `"Площадки для собак"` + Green iOS Toggle Switch (`playground`).
  3. `Icons.people_alt_rounded` + `"Поиск компаньонов"` + Green iOS Toggle Switch (`companion`).

---

## 4. State Integration
- Integrates directly with Riverpod `mapNotifierProvider` (`activeFilters` list).
- Toggling any switch immediately updates map marker visibility on `flutter_map`.

---

## 5. Verification Plan
- **Static Analysis**: `flutter analyze` with 0 issues.
- **Widget Testing**: `flutter test` passing clean.
