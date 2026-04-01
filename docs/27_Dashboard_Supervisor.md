# Supervisor Dashboard Specification (Mobile · Dark Theme)

## Objective

Build a dedicated supervisor dashboard screen with a modern dark UI, matching the style language used in supervisor pages, and optimized for mobile interaction.

This spec is the implementation blueprint before coding `supervisor_dashboard_screen.dart`.

---

## 1) Entry & Navigation

### 1.1 Entry from Supervisor Home

- On `supervisor_home_screen.dart`, the summary card (currently `Team Supervision`) should include a CTA button:
  - Label: `Open Dashboard`
  - Action: Navigate to `supervisor_dashboard_screen.dart`

### 1.2 Top Header (Dashboard Screen)

- Keep top section structurally consistent with `supervisor_home_screen.dart`.
- Text content:
  - Heading: `Welcome to Dashboard Supervisor`
- Right icon: user avatar icon.
- Avatar tap route: `profile_screen.dart`.

---

## 2) KPI Cards Section (Horizontal, Modern Card Slider)

### 2.1 Design Goal

- Show two KPI cards in a horizontal slider.
- Card #1 appears dominant (almost full width).
- Card #2 is partially visible on right (teaser), encouraging swipe.
- User can swipe to center card #2.

### 2.2 Card A — Area KPI

- Icon: area/location icon.
- Main value: example `14 Areas`.
- Description (EN):
  - `Patrol reports across all Aksama Adi Andana areas.`

### 2.3 Card B — HSE Staff KPI

- Icon: user/team icon.
- Main value: example `15 HSE Staff`.
- Description (EN):
  - `HSE personnel who submit reports from each location.`

### 2.4 Interaction

- Tapping Card A activates **Area Mode** content panel.
- Tapping Card B activates **Staff Mode** content panel.
- Mode switch should animate subtly and preserve selected filters if still valid.

---

## 3) Content Panel Under KPI Cards

Two mutually exclusive modes are shown under cards:

1. **Area Report Mode** (when Area card selected)
2. **Staff Report Mode** (when Staff card selected)

Both modes share these UI elements:

- Top tabs (context tabs: areas or staff names)
- Date range filters (`Date From`, `Date To`)
- Report list/table
- Pagination + items-per-page selector

---

## 4) Area Report Mode

### 4.1 Area Tabs

Tabs list (scrollable):

- Area Produksi 1 - Mesin Bubut
- Koridor Evakuasi Barat
- Gudang Penyimpanan B
- Area Parkir Timur
- Ruang Rapat Utama
- Kantin Karyawan
- Area Loading Dock

### 4.2 Date Filters

- Row under tabs:
  - `Date From`
  - `Date To`
- Default behavior: no restriction (all dates visible).

### 4.3 Report Columns (Area Mode)

Display data columns in order:

1. Status
2. Task Name
3. Risk Level (dot only; color-coded)
4. Root Cause
5. Reported Staff
6. Date Created

### 4.4 Empty State

- If no records after filters:
  - Centered icon + text: `No reports found for selected filters.`

---

## 5) Staff Report Mode

### 5.1 Staff Tabs

Tabs generated dynamically from data, example:

- HSE Staff Demo
- HSE Staff Demo 2

### 5.2 Date Filters

- Same filter row behavior as Area mode:
  - `Date From`
  - `Date To`

### 5.3 Report Columns (Staff Mode)

Display data columns in order:

1. Status
2. Area
3. Risk Level (dot only; color-coded)
4. Notes
5. Root Cause
6. Date Created

### 5.4 Empty State

- Same pattern as Area mode.

---

## 6) Risk Level Dot Color Rules

Use same visual semantics as create-task risk context:

- Ringan / Low → blue tone
- Menengah / Medium → yellow tone
- Berat / High → orange/red tone
- Kritis / Critical → strong red
- Unknown → neutral gray

The dashboard should use existing app color tokens where available.

---

## 7) Pagination + Page Size

### 7.1 Pagination

- Bottom-left section:
  - Prev button
  - Current page indicator (e.g. `Page 1 of 4`)
  - Next button

### 7.2 Page Size Dropdown

- Bottom-right section selector:
  - `5 items per page`
  - `10 items per page` (default)
  - `20 items per page`

### 7.3 Behavior

- Any tab/filter/page-size change resets page to 1.
- Pagination calculated from filtered data set.

---

## 8) Data Mapping Contract

Expected source fields from task maps:

- `id`
- `title` (optional; fallback generation allowed)
- `status`
- `riskLevel`
- `rootCause`
- `notes`
- `staffName`
- `area`
- `date`

Fallback title rule:

- Use `title` if available and non-empty.
- Else: `Inspeksi <area> - Masalah: <rootCause>`.

---

## 9) Mobile Layout Strategy

Because data has many columns, implementation should be mobile-friendly while preserving requested fields:

- Prefer horizontal-scrollable table block inside each mode.
- Keep sticky-like header style if feasible.
- Ensure columns remain readable and not cramped.

Minimum usability:

- Tap target >= 44px
- Text contrast for dark mode
- Ellipsis handling for long values

---

## 10) Visual Consistency Requirements

- Dashboard uses dark mode as default screen background.
- Cards and controls use existing typography and spacing system.
- Status chips and list/table readability should match quality of petugas task screens.
- KPI cards should feel modern (rounded, layered, subtle contrast).

---

## 11) Functional Acceptance Criteria

1. Supervisor can open dashboard via CTA in supervisor home summary card.
2. Dashboard header shows `Welcome to Dashboard Supervisor` and profile icon navigation.
3. KPI slider has 2 cards with partial preview interaction.
4. Area mode supports area tabs + date filters + data columns + pagination + page size selector.
5. Staff mode supports staff tabs + date filters + data columns + pagination + page size selector.
6. Risk level represented with colored dot.
7. UI stays readable on mobile widths and remains dark-theme consistent.

---

## 12) Implementation Sequence (Next Coding Step)

1. Build `supervisor_dashboard_screen.dart` scaffold + header.
2. Implement KPI card slider + mode switching state.
3. Add Area mode tabs + filters + table/list + pagination controls.
4. Add Staff mode tabs + filters + table/list + pagination controls.
5. Add risk-dot renderer and fallback formatters.
6. Wire summary-card CTA route from `supervisor_home_screen.dart`.
7. Validate with `flutter analyze` and UI checks.
