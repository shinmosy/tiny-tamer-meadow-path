# Tiny Tamer MVP Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task if execution is delegated.

**Goal:** Build a browser-playable 2D top-down turn-based RPG MVP called Tiny Tamer: Meadow Path.

**Architecture:** Godot 4 project with separate scenes for boot/main routing, title screen, overworld, player, dialogue, and battle. The MVP uses simple generated 2D placeholder art so it can be playable without external paid assets.

**Tech Stack:** Godot 4.x, GDScript, HTML5/Web export, Vercel static hosting.

---

## MVP Acceptance Criteria

- Player opens the game in browser or Godot and sees a title screen.
- Start button enters a small meadow overworld.
- Player moves in 4 directions with arrow keys or WASD.
- NPC dialogue appears when interacting near the NPC.
- Tall grass area can trigger random encounter.
- Battle scene supports Attack, Skill, Heal, and Run.
- Player monster Spriglet and enemy Mossbun have HP and simple stats.
- Win, lose, and run return to overworld.
- Project includes Vercel config for Godot Web headers.

---

## Task 1: Create Project Skeleton

**Objective:** Create the Godot folder structure, docs folder, and deploy files.

**Files:**
- Create: `godot/project.godot`
- Create: `godot/scenes/`
- Create: `godot/scripts/`
- Create: `godot/assets/sprites/`
- Create: `public/`
- Create: `vercel.json`
- Create: `README.md`

**Verification:**
- `godot/project.godot` exists.
- `vercel.json` contains COOP/COEP/CORP headers for Godot 4 Web.

---

## Task 2: Add Game State Autoload

**Objective:** Store current scene state, player HP, and simple monster stats.

**Files:**
- Create: `godot/scripts/GameState.gd`
- Modify: `godot/project.godot`

**Implementation Notes:**
- Add autoload `GameState`.
- Store player monster: Spriglet, HP 32, attack 7, skill damage 12.
- Store enemy monster: Mossbun, HP 26, attack 5, skill damage 9.
- Include helper methods to reset battle stats.

**Verification:**
- Godot can load `GameState.gd` as autoload.

---

## Task 3: Build Main Router Scene

**Objective:** Create a root scene that can switch between title, overworld, and battle.

**Files:**
- Create: `godot/scenes/Main.tscn`
- Create: `godot/scripts/Main.gd`

**Implementation Notes:**
- Main node loads `TitleScreen.tscn` on ready.
- Expose methods: `go_to_title()`, `go_to_overworld()`, `go_to_battle()`.

**Verification:**
- Running project displays title screen once Task 4 is complete.

---

## Task 4: Build Title Screen

**Objective:** Add a simple title UI with Start button.

**Files:**
- Create: `godot/scenes/TitleScreen.tscn`
- Create: `godot/scripts/TitleScreen.gd`

**Implementation Notes:**
- Background pastel green/blue.
- Title: Tiny Tamer.
- Subtitle: Meadow Path.
- Start button calls root main router `go_to_overworld()`.

**Verification:**
- Clicking Start enters overworld.

---

## Task 5: Build Overworld Scene

**Objective:** Create a small playable meadow map using simple ColorRect/Sprite2D placeholders.

**Files:**
- Create: `godot/scenes/Overworld.tscn`
- Create: `godot/scripts/Overworld.gd`
- Create: `godot/scenes/Player.tscn`
- Create: `godot/scripts/PlayerMovement.gd`

**Implementation Notes:**
- Viewport-friendly 960x540 layout.
- Grass background.
- Brown path.
- Tall grass rectangle area.
- Trees/boulders as placeholder colored shapes.
- Player moves with WASD/arrow keys and is clamped inside the screen.

**Verification:**
- Player can move smoothly and cannot leave viewport.

---

## Task 6: Add NPC Dialogue

**Objective:** Add one NPC with interaction text.

**Files:**
- Modify: `godot/scenes/Overworld.tscn`
- Modify: `godot/scripts/Overworld.gd`

**Implementation Notes:**
- NPC stands near path.
- When player is close and presses Enter/Space/E, show dialogue panel.
- Text: "Welcome to Meadow Path! Wild critters live in the tall grass."

**Verification:**
- Dialogue toggles only near NPC.

---

## Task 7: Add Random Encounter

**Objective:** Trigger battle when player walks in tall grass.

**Files:**
- Modify: `godot/scripts/Overworld.gd`

**Implementation Notes:**
- If player is inside tall grass, roll encounter chance on movement tick.
- Use low chance to avoid instant spam.
- On encounter, call `go_to_battle()`.

**Verification:**
- Walking in tall grass eventually enters battle scene.

---

## Task 8: Build Battle Scene

**Objective:** Implement basic turn-based battle UI and logic.

**Files:**
- Create: `godot/scenes/Battle.tscn`
- Create: `godot/scripts/BattleManager.gd`

**Implementation Notes:**
- Display Spriglet on left and Mossbun on right using placeholder shapes.
- Display HP labels.
- Buttons: Attack, Skill, Heal, Run.
- Attack: player deals 7, enemy replies 5.
- Skill: player deals 12, enemy replies 5.
- Heal: player heals 10 capped at max HP, enemy replies 5.
- Run: return to overworld.
- Win: show message, return to overworld.
- Lose: show message, reset HP, return to overworld.

**Verification:**
- All four actions work.
- HP updates correctly.
- Win/lose/run return to overworld.

---

## Task 9: Prepare Browser Export and Vercel

**Objective:** Make the repo deploy-ready for static web hosting.

**Files:**
- Create: `godot/export_presets.cfg`
- Modify: `vercel.json`
- Modify: `README.md`

**Implementation Notes:**
- Configure web export path to `../public/index.html`.
- Keep `public/.gitkeep` until real export exists.
- Vercel headers: COOP same-origin, COEP require-corp, CORP same-origin.

**Verification:**
- `vercel.json` validates as JSON.
- Godot export preset points to public folder.

---

## Task 10: Verify Locally

**Objective:** Confirm the MVP can run in Godot or exported browser build.

**Commands:**
- If Godot exists: `godot --path /home/mosy/tiny-tamer/godot --headless --quit`
- If export templates exist: `godot --headless --path /home/mosy/tiny-tamer/godot --export-release Web ../public/index.html`
- Serve static build: `python3 -m http.server 8000 -d /home/mosy/tiny-tamer/public`

**Verification:**
- Browser opens title screen.
- Start, movement, NPC, encounter, and battle work.

---

## Deferred Features

These are intentionally postponed:

- 3D version.
- Capture system.
- Leveling and EXP.
- Inventory.
- Save/load.
- More monsters/maps.
- Polished custom art.
- Mobile controls.

