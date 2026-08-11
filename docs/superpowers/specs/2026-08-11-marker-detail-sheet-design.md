# Spec: Interactive Pull-Up Marker Detail Sheet (Apple Liquid Glass)

**Date**: 2026-08-11
**Topic**: Map Marker Details Sheet UX/UI Refactoring

---

## 🎯 Goal
Improve the UX/UI of the map marker details sheet by migrating from a static floating card to a native iOS-style pull-up sheet (`DraggableScrollableSheet`) with glassmorphic Liquid Glass design. It will support single-scroll detailed information about playgrounds, lost pets, and companion dogs.

---

## 📱 UI/UX & Layout States

### 1. Sheet Dimensions & Snap Positions
We use `DraggableScrollableSheet` with:
* `minChildSize: 0.16` (approx 120px): Minimum collapsed view showing only the drag handle and title.
* `initialChildSize: 0.32` (approx 250px): Default visible height when tapping a marker, containing core meta-info and quick actions (Route, Contact).
* `maxChildSize: 0.85`: Fully expanded height displaying scrollable sections.

### 2. Design Aesthetics (Apple Liquid Glass)
* **Background**: Semi-transparent slate (`#1C1C1E` with opacity) with `BackdropFilter` blur (sigma: 15.0).
* **Borders**: Translucent white border (`rgba(255,255,255,0.08)`).
* **Accent highlights**: Bottom border or accent highlights tinted with the category color:
  * `lost_pet` -> System Red (`#FF453A`)
  * `playground` -> System Green (`#30D158`)
  * `companion` -> System Blue (`#0A84FF`)

---

## 📝 Scrollable Content Structure (Single Scroll List)

When the user pulls the sheet up to `maxChildSize`, the following sections scroll into view inside a single list:
1. **Drag Handle & Header**: 
   - Translucent rounded capsule handle.
   - Category badge with colored background/border.
   - Close button (X) in top-right.
2. **Core Info Block**:
   - Title, Breed/Age details (if any), Distance from user (e.g., `~450 м от вас`), Rating or safety indicator.
3. **Primary Action Row**:
   - "Маршрут" button (Filled accent color, black text).
   - "Связаться" button (Transparent glass background, white text/border).
4. **Description Card**:
   - Text paragraph with details (notes, characteristics, playground rules).
5. **Horizontal Gallery Card**:
   - Title: `Фотографии`
   - Horizontal scrolling list of mock image thumbnails representing the pet or playground.
6. **Location/Address Card**:
   - Title: `Адрес и координаты`
   - Detailed text address and coordinates (latitude, longitude).
7. **Tips & Reviews Block**:
   - Title: `Отзывы и советы`
   - Custom list of mock reviewer comments (user names, stars, short text).

---

## ⚙️ Technical Details

### Files to Modify
* `lib/features/map/widgets/marker_detail_sheet.dart`: Rewrite this component to use `DraggableScrollableSheet`, `ScrollController`, and new UI cards.
* `lib/features/map/map_screen.dart`: Adjust the positioning of the sheet. Remove the hardcoded `Positioned(bottom: 80, ...)` wrapper because the draggable sheet sits directly at the bottom of the screen.

### Data Model Integration
Map details are dynamically retrieved from `MapMarkerModel` instances. Standard fields map as follows:
* `marker.title` -> Header Title
* `marker.description` -> Description Card
* `marker.breed` & `marker.age` -> Breed/Age metadata line
* `marker.image` -> Main thumbnail image (and first gallery picture)
* `marker.type` -> Accent color and category badge

---

## 🧪 Verification Plan

### Manual Verification
1. Open the app on the Chrome device.
2. Click on a marker (e.g. playground or lost pet).
3. Verify that the bottom sheet pops up in the `initialChildSize` state (covering ~32% of the screen).
4. Drag the sheet up to the top and verify it slides smoothly and stops at 85% height.
5. Scroll through the content and verify the Description, Gallery, Location, and Reviews cards display correctly.
6. Drag the sheet back down to collapse it or click the Close button to dismiss it.
