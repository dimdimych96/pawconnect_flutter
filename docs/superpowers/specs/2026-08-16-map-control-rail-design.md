# Design Spec: PawConnect Map Control Rail (Right Liquid Glass Rail)

**Date**: 2026-08-16  
**Status**: Approved by User  
**Target Feature**: PawConnect Flutter Interactive Map Controls  

---

## 1. Executive Summary
This design specification replaces the legacy, space-consuming horizontal map overlays (`Где Макс?`, `Маршрут`, `313 м до Макс` pills, standalone compass button, and separate FAB) with an ultra-minimalist, unified **Right Liquid Glass Control Rail** (Variation 2.2).

The new control rail consolidates pet camera focus, user location centering, and event/marker creation into a single vertical glass capsule on the right edge of the screen, perfectly aligned with PawConnect's Apple Liquid Glass design system.

---

## 2. Key Interface & UX Requirements

### 2.1 Right Vertical Glass Rail (`RightControlRail`)
- **Placement**: Positioned floating on the right side of `MapScreen` (`right: 14.0`, `bottom: 80.0` above the global `MainShell` tab bar).
- **Styling**:
  - Background: Liquid Obsidian Dark `Color(0xC8121814)`.
  - Blur: `BackdropFilter` with `sigmaX: 20, sigmaY: 20`.
  - Corner Radius: `BorderRadius.circular(22)`.
  - Border: `Border.all(color: Colors.white.withOpacity(0.14), width: 1.0)`.
  - Box Shadow: `BoxShadow(color: Colors.black.withOpacity(0.65), blurRadius: 24, offset: Offset(0, 8))`.

### 2.2 Segmented Focus Control (Upper Section)
- **Pet Focus Switch (`🐕`)**:
  - Icon: `Icons.pets_rounded` (or `Icons.pets`).
  - Active State: Highlighted with emerald gradient `LinearGradient(colors: [Color(0x4000E676), Color(0x2000E676)])` and border `Color(0xFF00E676)`.
  - Tapping animates map camera to pet (`MapNotifier.centerOnPet()`).
- **User Location Switch (`🎯`)**:
  - Icon: `Icons.my_location_rounded`.
  - Active State: Highlighted when map is centered on user location.
  - Tapping animates map camera to user position (`MapNotifier.centerOnUser()`).
- **Divider**: 1px subtle horizontal divider (`Colors.white.withOpacity(0.1)`).

### 2.3 Add Event Button (Lower Section)
- **Icon**: `Icons.add_rounded` / `Icons.add_location_alt_rounded`.
- **Styling**: Accent Emerald highlight (`Color(0xFF00E676)`).
- **Behavior**: Tapping opens the `NewMarkerModal` dialog to place a new safety hazard, dog meeting, or community marker on the map.

### 2.4 Animated Distance Badge
- **Behavior**: When Pet Focus mode is active, an animated glass badge (`313 м`) slides out smoothly from the left side of the Pet Focus button (`AnimatedSlide` + `AnimatedOpacity`).
- **Styling**: `Color(0xE6121814)` background, `Color(0xFF00E676)` pulsating indicator dot, and distance text (`${distance.round()} м`).

---

## 3. Architecture & Cleanup

### 3.1 Deleted Legacy Overlays
- Remove bottom-left horizontal action buttons (`Где Макс?`, `Маршрут`).
- Remove standalone bottom-left distance pill (`313 м до Макс`).
- Remove standalone top-right compass button (`CompassWidget`).
- Remove standalone bottom-right green FAB (`+`).

### 3.2 File Structure
- `lib/features/map/widgets/right_control_rail.dart`: New reusable Liquid Glass control rail widget.
- `lib/features/map/map_screen.dart`: Update layout stack to host `RightControlRail`.

---

## 4. Verification & Testing Plan
- Verify clean rendering on mobile viewports without overlapping the floating `MainShell` tab bar.
- Test smooth animation when toggling camera focus between user location and pet collar.
- Test slide-in/slide-out transition of the distance badge.
- Verify `NewMarkerModal` opens seamlessly upon tapping the `+` section of the rail.
