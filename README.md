# Tiny Tamer: Meadow Path

Tiny Tamer: Meadow Path is a lightweight 2D monster-taming RPG browser prototype built with Godot 4.

The game was developed through an AI-assisted workflow using Hermes Agent to plan, implement, iterate, validate, and export the project. The prototype focuses on rapid game development: overworld exploration, biome-based encounters, turn-based battles, capture mechanics, a Meadow Dex, active companion selection, mobile-friendly controls, and web deployment.

## Current Features

- 2D top-down adventure map
- Larger overworld with multiple biomes:
  - Meadow Fields
  - Whisper Forest
  - Bluebell River
  - Cragpeak Trail / Mountain
- Biome-based random encounters
- Turn-based battle system
- Meadow Orb capture mechanic
- Multiple custom monsters:
  - Spriglet
  - Mossbun
  - Bloomrat
  - Cragcub
  - Aqualit
- Meadow Dex collection screen
- Captured monsters can be selected as active companions
- Options menu with sound toggle
- In-game menu
- Loading transitions
- Desktop keyboard controls
- Mobile/touch controls with auto-detect
- Godot Web export ready for static hosting

## Controls

### Desktop

- Move: `WASD` or arrow keys
- Interact: `E`, `Space`, or `Enter`
- Menu: on-screen `Menu` button

### Mobile

- Touch D-pad appears automatically on touchscreen/mobile devices
- `A` button for interact

## Project Structure

```text
tiny-tamer/
├── godot/
│   ├── project.godot
│   ├── scenes/
│   ├── scripts/
│   └── assets/
├── public/
│   └── Godot Web export output
├── docs/
├── vercel.json
└── package.json
```

## Run Local Web Build

```bash
python3 -m http.server 8000 -d public
```

Open:

```text
http://127.0.0.1:8000/index.html
```

## Godot Version

Built and exported with Godot 4.3 stable.

## Deployment Notes

The `public/` folder contains the exported static web build. It can be deployed to static hosts such as Vercel, Netlify, GitHub Pages, or itch.io.

`vercel.json` includes cross-origin isolation headers required by Godot Web builds.

## Status

Prototype version: final Godot engine archive

Tiny Tamer: Meadow Path is now ended/archived as an engine prototype. The project remains as a playable record of the experiment and the lessons learned: keep future game foundations smaller, cleaner, and focused around one strong core loop before expanding scope.
