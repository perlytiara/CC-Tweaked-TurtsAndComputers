# cc-tweaked-turtsandcomputers

A curated collection of ComputerCraft: Tweaked programs for turtles and computers. This repo aggregates work from multiple creators; credit is preserved in directory names and files. See `docs/` for additional usage notes.

## Programs overview
- `programs/perlytiara/dome_tunnels/` — Dome-shaped tunnel miners (`dome_tunnels.lua`, `dome_tunnels_size2.lua`).
- `programs/perlytiara/entrance_carver.lua` — Entrance/tunnel carver.
- `programs/perlytiara/room_carver.lua` — Room carving utility.
- `programs/perlytiara/tClear/` — tClear utilities:
  - `tClear.lua` (core clearer; see also `programs/Kaikaku/tClear.lua`)
  - `tClear_multi.lua` (master: dispatches jobs to multiple turtles)
  - `tClear_listener.lua` (turtle: receives jobs and runs `tClear`)
- `programs/Silvamord/EpicMiningTurtle.lua` — Parallel tunnel miner.
- `programs/Kaikaku/` — Harvesting, tree farm, mob farm, loader, and a `tClear.lua` variant.
- `programs/MerlinLikeTheWizard/` — `mastermine.lua`, `turtlogenesis.lua`.

## Quick start: multi‑turtle tClear
Use an advanced computer as the master and two turtles as workers.

1) On each turtle (workers)
- Attach a wireless modem.
- Copy and run `programs/perlytiara/tClear/tClear_listener.lua`.
- Ensure fuel is available (e.g., in slot 16 if your `tClear.lua` expects it).

2) On the computer (master)
- Attach a wireless modem.
- Run `programs/perlytiara/tClear/tClear_multi.lua`.
- Enter the LEFT and RIGHT turtle IDs, then depth, total width, height, and any options (e.g., `layerbylayer startwithin`).

Behavior
- The master splits width across the two turtles (odd widths give the extra block to the right turtle).
- Messages are sent with a `tclear-run` protocol and as plain strings for compatibility.

## Credits (by directory)
- `programs/perlytiara/*` — perlytiara
- `programs/Silvamord/*` — Silvamord
- `programs/Kaikaku/*` — Kaikaku
- `programs/MerlinLikeTheWizard/*` — MerlinLikeTheWizard

Original authors retain credit for their respective files. If you are an author listed here and want changes to attribution or links, please open an issue or PR.

## Community ComputerCraft repos
Helpful, inspirational, or related repositories:

- [awesome-computercraft](https://github.com/tomodachi94/awesome-computercraft) — A comprehensive Awesome list of CC/CC:T resources.
- [John-Turtle-Programs](https://github.com/johnneijzen/John-Turtle-Programs)
- [Equbuxu/mine](https://github.com/Equbuxu/mine)
- [Sv443/ComputerCraft-Projects](https://github.com/Sv443/ComputerCraft-Projects)
- [kepler155c/opus](https://github.com/kepler155c/opus)
- [louino2478/computercraft-programe](https://github.com/louino2478/computercraft-programe)
- [Starkus/quarry](https://github.com/Starkus/quarry)
- [ottomated/turtle-gambit](https://github.com/ottomated/turtle-gambit)
- [merlinlikethewizard/Mastermine](https://github.com/merlinlikethewizard/Mastermine)
- [yazug/computercraft](https://github.com/yazug/computercraft)

## Docs
See `docs/` for per-program usage notes.
