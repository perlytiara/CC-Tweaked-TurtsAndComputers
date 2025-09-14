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
- [Zephira58/CC-Tweaked-Scripts (Xanthus58)](https://github.com/Zephira58/CC-Tweaked-Scripts/tree/main/Xanthus58)
- [ComputerCraft Forums: Turtle Programs](https://forums.computercraft.cc/index.php?board=5.0) — Community-made turtle programs, mining scripts, automation, and more.
- [Fatboychummy-CC/Dog](https://github.com/Fatboychummy-CC/Dog) — "Dog" uses block scanning peripherals to efficiently find and mine large amounts of ore. Includes installer, flexible include/exclude/only block lists, and advanced options for depth, fuel, and geoscanner range.
- [exa-byte/CCTurtleRemoteController](https://github.com/exa-byte/CCTurtleRemoteController) — Node.js server and browser UI for remote controlling ComputerCraft turtles via HTTP API. Features live control, inventory/fuel display, block/item textures, and keyboard shortcuts. See setup instructions in their README for details.
- [BigGamingGamers's Pastebin](https://pastebin.com/u/BigGamingGamers) — Collection of ComputerCraft scripts by Michael Reeves, including automation and farm programs.
- [Michael-Reeves808's Gists](https://gist.github.com/Michael-Reeves808) — Collection of ComputerCraft scripts including `lift.lua`, `pos.lua`, `bamboo.lua`, and `harvest.lua`.


### Michael Reeves' Turtle Code

A popular mining turtle script by Michael Reeves was shared on Reddit ([source](https://www.reddit.com/r/MichaelReeves/comments/jz4soa/minecraft_turtle_code/)). This script is designed for ComputerCraft turtles in Minecraft and automates mining in a straight tunnel, handling obstacles and inventory.

**Key features:**
- Mines a 3x2 tunnel forward.
- Handles fuel and inventory management.
- Avoids lava and places torches if configured.

**How to use:**
1. Place the script on your turtle (e.g., `mine.lua`).
2. Ensure the turtle has fuel and torches (if needed).
3. Run the script with the desired tunnel length:  
   ```
   lua mine.lua 100
   ```
   (Replace `100` with your desired tunnel length.)

**Example script:**  
You can find the original and discussion [here](https://www.reddit.com/r/MichaelReeves/comments/jz4soa/minecraft_turtle_code/).  
A cleaned-up version is also available in [Michael-Reeves808's Gists](https://gist.github.com/Michael-Reeves808).


## Remote Mining Setup Guide

For more detailed instructions, see the [Remote miners setup guide](https://docs.google.com/document/d/1Ni4TG92eK2tLnDUl6Sh1mCXobvsoB0QAUr0Rn_HyVfk/edit?tab=t.0).

**Quick steps:**
1. **Prepare Turtles (Workers):**
   - Attach a wireless modem to each turtle.
   - Place fuel in the expected slot (commonly slot 16).
   - Copy and run `programs/perlytiara/tClear/tClear_listener.lua` on each turtle.

2. **Prepare Master Computer:**
   - Attach a wireless modem.
   - Run `programs/perlytiara/tClear/tClear_multi.lua`.
   - Enter the IDs of the worker turtles and mining parameters as prompted.

**Tips:**
- Ensure all devices are within wireless modem range.
- Use advanced computers/turtles for best compatibility.
- For troubleshooting, check modem status with `peripheral.isPresent("left")` or `right`.

See the [Google Doc](https://docs.google.com/document/d/1Ni4TG92eK2tLnDUl6Sh1mCXobvsoB0QAUr0Rn_HyVfk/edit?tab=t.0) for screenshots and advanced configuration.




## Docs
See `docs/` for per-program usage notes.
