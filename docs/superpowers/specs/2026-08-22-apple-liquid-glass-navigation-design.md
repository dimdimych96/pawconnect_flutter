# Apple Liquid Glass Navigation Design Specification

## 1. Overview & Goals
Upgrade PawConnect map navigation into a modern, native-feeling experience inspired by **Apple Maps**, **Yandex Maps**, and **2GIS** using Apple Liquid Glass design standards (Obsidian `#0A0A0C`, slate glass cards `#1C1C1E`, `BackdropFilter` sigma 24, fine hairline borders, pure vector icons, zero emojis).

## 2. Core Navigation Modes & UX Architecture

```
                                  [ Map Screen ]
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        ▼                               ▼                               ▼
  1. Idle / Explore             2. Route Preview              3. Active Turn-by-Turn
  • Collapsed quick bar          • Half/Full Glass Sheet       • Fullscreen Navigation HUD
  • Poi category filters         • 3 Transport profiles        • Top Maneuver Capsule
  • RightControlRail HUD         • Interactive map polyline    • Bottom ETA & Exit bar
  • Collar pulse aura            • CTA: "Start Navigation"     • Camera follows user heading
```

### Mode 1: Idle & POI Discovery (Свободный обзор)
- **Top Controls**: Search capsule with vector search icon and quick category filters (Playgrounds, Lost pets, Companions).
- **Right Rail (`RightControlRail`)**: Z-index adjusted floating controls (Compass/North, My Location, "Where is Max?" collar focus, Layers drawer, Zoom `+`/`-`).
- **Map Viewport**: Live pulsing GPS collar marker with neon aura, safe zone radius circle (350m), 24h walk trail polylines.

### Mode 2: Route Preview Sheet (Предпросмотр маршрута)
- Triggered by tapping on any POI marker or collar marker, or selecting a route target.
- **Glass Sheet (Half Snap ~320px / Full Snap 90%)**:
  - Drag handle / grabber.
  - Destination header (Title, address, distance, walking duration, battery & safe zone status if pet).
  - Pure Vector Transport Profile Chips (no emojis):
    - `Walk` (🚶 Vector icon): Shortest pedestrian path.
    - `Park Safe` (🌳 Vector icon): Dog-friendly safe walking path through parks/green alleys avoiding major roads.
    - `Drive` (🚗 Vector icon): Vehicle route for emergency vet visits.
  - Primary CTA: Prominent Apple Green `#30D158` button **«В путь / Начать навигацию»**.
  - Camera automatically fits route bounding box with smooth padding.

### Mode 3: Active Turn-by-Turn Navigation HUD (Активное ведение)
- Triggered by tapping **«В путь»**.
- Floating bottom tab bar (`MainShell`) smoothly transitions into the **Navigation HUD**:
  - **Top Maneuver Capsule**: Large glass container with high-contrast turn indicator icon (turn left, turn right, slight left, straight, arrive), turn distance (e.g., *«Через 80 м направо»*), and street/alley name.
  - **Live Step Indicator**: Walking speed/pace pill (e.g. *«4.8 км/ч • темп шага»*).
  - **Bottom ETA Bar**: Large prominent duration (e.g., *«3 мин • 240 м»*), estimated arrival time (e.g., *«Прибытие в 18:14»*), and Red Glass **«Завершить»** button with vector close icon.
  - **Dynamic Camera Follow**: Camera centers on the user's location with orientation along the route trajectory.

---

## 3. Data Models & State Structure

```dart
enum ManeuverType {
  straight,
  turnLeft,
  turnRight,
  slightLeft,
  slightRight,
  arrive,
}

class NavigationStep {
  final String instruction;
  final String streetName;
  final double distanceMeters;
  final ManeuverType maneuverType;
  final LatLng location;

  const NavigationStep({
    required this.instruction,
    required this.streetName,
    required this.distanceMeters,
    required this.maneuverType,
    required this.location,
  });
}

class ActiveRouteModel {
  final String id;
  final String destinationTitle;
  final String destinationType;
  final LatLng startPoint;
  final LatLng endPoint;
  final int distanceMeters;
  final int durationMinutes;
  final String transportMode; // 'walk', 'park_safe', 'drive'
  final List<LatLng> waypoints;
  final List<NavigationStep> steps;
  ...
}
```

### MapState Extensions:
- `bool isNavigating`: Whether active turn-by-turn mode is engaged.
- `int currentStepIndex`: Current active maneuver step.
- `String activeTransportProfile`: Currently selected mode (`walk`, `park_safe`, `drive`).

---

## 4. Visual & Component Specifications

- **Background**: Deep Obsidian `#0A0A0C`.
- **Cards & Sheets**: Dark Slate `#1C1C1E` at 85-90% opacity with `BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24))`.
- **Borders**: Subdued white `Colors.white.withValues(alpha: 0.12)` with optional glow accents.
- **Accents**:
  - Safe & Success / Start: `#30D158` (Apple Green)
  - Info & Active Mode: `#0A84FF` (Apple Blue)
  - Stop / Breach: `#FF453A` (Apple Red)
  - Caution / Warnings: `#FFD60A` (Apple Yellow)
- **Typography**: Crisp iOS Dynamic Type hierarchy with font tracking and weights.
- **Icons**: 100% Vector icons via `LucideIcons` / Cupertino / Material. No emojis in UI components.

---

## 5. Offline Fallback & Mock Data Integrity
- Pure Dart models without code generation (`NO build_runner`).
- OSRM route builder fallback to local waypoint calculations ensuring zero backend dependency.
- Responsive layout supporting mobile screens and web viewports.
