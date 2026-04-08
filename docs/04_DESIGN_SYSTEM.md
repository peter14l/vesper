# 04 — Vesper: Design System

## Design Philosophy

Vesper's UI is disciplined and restrained everywhere — except where it matters. Sharp geometry, quiet surfaces, and careful typography hold the visual structure. The recording orb breaks that discipline deliberately: it breathes, reacts, and lives. That contrast is intentional.

**Keywords:** Calm. Precise. Alive at the right moment.

**References:** Craft App, Bear, Darkroom, Linear

---

## Color System

### Dark Mode (Primary)

| Token | Value | Usage |
|-------|-------|-------|
| `--bg-base` | `#0E0F14` | App background |
| `--bg-surface` | `#16181F` | Cards, panels |
| `--bg-elevated` | `#1E2029` | Modals, popovers |
| `--bg-subtle` | `#252732` | Input fields, secondary surfaces |
| `--border` | `#2E3040` | Dividers, card borders |
| `--text-primary` | `#F0F0F5` | Primary text |
| `--text-secondary` | `#8B8FA8` | Secondary text, metadata |
| `--text-muted` | `#555870` | Placeholder, disabled |
| `--accent-primary` | `#7C6AF7` | Violet — primary actions, orb, active states |
| `--accent-secondary` | `#C4A55A` | Amber — tags, badges, warmth accents |
| `--accent-glow` | `#7C6AF740` | Violet at 25% opacity — glow effects |
| `--destructive` | `#E05C5C` | Delete, error states |
| `--success` | `#4CAF82` | Completed actions |

### Light Mode

| Token | Value | Usage |
|-------|-------|-------|
| `--bg-base` | `#F7F5F0` | Warm ivory app background |
| `--bg-surface` | `#FFFFFF` | Cards, panels |
| `--bg-elevated` | `#FFFFFF` | Modals (with shadow) |
| `--bg-subtle` | `#EFEDE8` | Input fields, secondary surfaces |
| `--border` | `#DDD9D0` | Dividers, card borders |
| `--text-primary` | `#18181C` | Primary text |
| `--text-secondary` | `#6B6860` | Secondary text, metadata |
| `--text-muted` | `#A8A49C` | Placeholder, disabled |
| `--accent-primary` | `#C4901A` | Amber — primary actions, orb, active states |
| `--accent-secondary` | `#6A5FD4` | Violet — secondary accents |
| `--accent-glow` | `#C4901A40` | Amber at 25% opacity — glow effects |
| `--destructive` | `#CC4444` | Delete, error states |
| `--success` | `#3A9966` | Completed actions |

---

## Typography

### Font Families

| Role | Font | Weight Range | Usage |
|------|------|-------------|-------|
| UI / Interface | **Plus Jakarta Sans** | 400, 500, 600, 700 | All UI elements, labels, buttons, navigation |
| Body / Transcript | **Lora** | 400, 400i, 600 | Transcript text, summaries, note body |
| Monospace | **JetBrains Mono** | 400 | Timestamps, metadata, technical info |

### Type Scale

| Token | Font | Size | Weight | Line Height | Usage |
|-------|------|------|--------|-------------|-------|
| `display-lg` | Plus Jakarta Sans | 32sp | 700 | 1.2 | Screen titles |
| `display-sm` | Plus Jakarta Sans | 24sp | 600 | 1.25 | Section headers |
| `title` | Plus Jakarta Sans | 18sp | 600 | 1.3 | Note titles, card titles |
| `label-lg` | Plus Jakarta Sans | 15sp | 500 | 1.4 | Button labels, tab labels |
| `label-sm` | Plus Jakarta Sans | 13sp | 500 | 1.4 | Tags, badges, metadata |
| `body-lg` | Lora | 17sp | 400 | 1.65 | Transcript body |
| `body-sm` | Lora | 15sp | 400 | 1.6 | Summary text |
| `mono` | JetBrains Mono | 12sp | 400 | 1.5 | Timestamps |
| `caption` | Plus Jakarta Sans | 11sp | 400 | 1.4 | Fine print, helper text |

---

## Spacing System

Base unit: **4dp**

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4dp | Micro gaps |
| `space-2` | 8dp | Tight spacing |
| `space-3` | 12dp | Component internal padding |
| `space-4` | 16dp | Standard padding |
| `space-5` | 20dp | Card padding |
| `space-6` | 24dp | Section gaps |
| `space-8` | 32dp | Large gaps |
| `space-12` | 48dp | Screen-level padding |

---

## Shape & Elevation

### Corner Radius
Vesper uses **sharp corners** throughout — maximum 4dp radius. Most elements use 2dp or 0dp.

| Component | Radius |
|-----------|--------|
| Buttons | 4dp |
| Cards | 4dp |
| Input fields | 4dp |
| Modals / Bottom sheets | 8dp top corners only |
| Tags / Badges | 2dp |
| Orb | Perfect circle (no radius token) |

### Elevation
No heavy shadows. Elevation is communicated through border color and background lightness.

| Level | Method |
|-------|--------|
| Base | `--bg-base` background |
| Surface | `--bg-surface` + 1px `--border` border |
| Elevated | `--bg-elevated` + subtle shadow: `0 4px 24px rgba(0,0,0,0.12)` |

---

## Iconography

**Library:** Phosphor Icons (Flutter: `phosphor_flutter`)  
**Style:** Duotone — primary color at full opacity, secondary element at 40% opacity  
**Size:** 20dp (standard), 24dp (navigation), 16dp (inline/small)

### Icon color usage
- Default: `--text-secondary`
- Active / selected: `--accent-primary`
- Destructive: `--destructive`

---

## Motion & Animation

### Principles
- UI transitions: **spring physics** — fast attack, natural settle. Never linear.
- The orb is the exception — it uses custom bezier curves for organic feel
- Respect system reduce-motion setting — all animations fall back to instant when enabled

### Standard Transitions

| Transition | Duration | Curve |
|-----------|----------|-------|
| Page push | 280ms | Spring (stiffness: 300, damping: 28) |
| Modal appear | 320ms | Spring (stiffness: 260, damping: 24) |
| Fade in | 180ms | ease-out |
| List item appear | 120ms stagger | ease-out |
| Button press | 80ms scale to 0.97 | ease-in-out |

### Recording Orb Animations

| State | Animation | Duration / Loop |
|-------|-----------|----------------|
| Idle | Scale: 1.0 → 1.04 → 1.0, opacity glow pulse | 3s, infinite |
| Recording | Amplitude waves: rings expand outward, opacity 0.6 → 0 | Continuous, speed = amplitude |
| Processing | Rotation shimmer on orb surface | 1.8s, infinite |
| Complete | Rings retract inward, orb flashes once | 400ms, once |
| Paused | All waves freeze, orb dims to 70% opacity | Instant |

---

## Navigation

### Mobile (Android + iOS)

**Floating Tab Bar**
- Position: Bottom of screen, floating above content with margin
- Background: `--bg-elevated` with blur (frosted glass effect)
- Border: 1px `--border` top
- Height: 64dp
- Tabs: 4 items — Vault, Record (centre, orb), Search, Settings
- Active indicator: accent-colored dot below icon, icon shifts to accent color
- The centre tab IS the recording orb — smaller idle version lives in nav bar

### Desktop (Windows + macOS)

**Collapsible Sidebar**
- Default: Expanded (220dp wide) with icon + label
- Collapsed: Icon-only (56dp wide)
- Toggle: Keyboard shortcut (`⌘/Ctrl + \`) + sidebar edge click
- Nav items: Vault, Search, Settings, About
- Recording trigger: Prominent button at top of sidebar
- No floating orb on desktop — recording triggered via button or keyboard shortcut (`Space` when not in text field)

---

## Component Patterns

### Note Card
```
┌─────────────────────────────────────┐
│ [mood badge]              [duration] │
│                                      │
│ Note Title Here                      │  ← title style
│ Summary snippet text appears here    │  ← body-sm style
│ truncated to two lines...            │
│                                      │
│ [tag] [tag] [tag]        12 Jan 2025 │  ← label-sm + mono
└─────────────────────────────────────┘
```
- 1px border, 4dp radius, `--bg-surface` background
- No shadow
- Swipe actions revealed on horizontal swipe (mobile only)

### Transcript View
```
┌─────────────────────────────────────┐
│ 00:00  Speaker 1                     │  ← mono + label-sm
│ The quick brown fox jumps over the  │  ← body-lg (Lora)
│ lazy dog and then some more text    │
│                                      │
│ 00:14  Speaker 2                     │
│ And here is the response to that    │
│ statement made above...             │
└─────────────────────────────────────┘
```
- Currently playing word: background highlight in `--accent-primary` at 20% opacity
- Uncertain words: subtle dashed underline in `--text-muted`
- Speaker label color-coded (Speaker 1 = violet, Speaker 2 = amber, etc.)

### Tag Chip
- Background: `--accent-secondary` at 15% opacity
- Text: `--accent-secondary` at full opacity
- Label-sm, 2dp radius, 8dp horizontal padding, 4dp vertical padding
- No border

### Button — Primary
- Background: `--accent-primary`
- Text: White, label-lg, 600 weight
- Padding: 12dp vertical, 24dp horizontal
- Radius: 4dp
- Press state: scale 0.97

### Button — Secondary
- Background: transparent
- Border: 1px `--border`
- Text: `--text-primary`, label-lg, 500 weight
- Same sizing as primary

---

## Accessibility

- Minimum touch target: 44x44dp on mobile
- All interactive elements have semantic labels
- Color is never the only indicator of state (always paired with icon or text)
- Contrast ratio: minimum 4.5:1 for all text
- Reduce motion: all animations disabled when system preference is set
- Dynamic text size: UI scales with system font size settings
