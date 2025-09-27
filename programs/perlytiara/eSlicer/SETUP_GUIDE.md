# eSlicer Quick Setup Guide

## Visual Setup Layout

```
Mining Area (to be cleared) - Turtles deploy into this area
┌─────────────────────────────┐
│ ████████████████████████████│
│ ████ TARGET MINING AREA ████│  
│ ████████████████████████████│
│ ████████████████████████████│
└─────────────────────────────┘
          │
          │ (2 blocks gap)
          ▼
   [Disk] [Mining] [Chunky]    <- Deployed row (where turtles go)
   Drive  Turtle   Turtle
     │       │       │
   [Mining] [Server] [Chunky]  <- Setup row
   Chest    Turtle    Chest
```

## Step-by-Step Setup

### 1. Position Base Platform
- Find the **bottom-left corner** of your mining area
- Go **2 blocks behind** (away from mining area)
- Place your setup row: `[Mining Chest] [Server Turtle] [Chunky Chest]`
- Place disk drive **1 block in front and 1 block left** of server turtle (front-left diagonal)

### 2. Fill Storage Chests
- **Left chest** (Mining): Advanced Mining Turtles (with wireless modems + pickaxes)
- **Right chest** (Chunky): Advanced Turtles (with wireless modems)
- **Server inventory**: Some coal/fuel for operations
- **Disk drive**: Floppy disk with all eSlicer programs

### 3. Turtle Crafting Recipe
**Advanced Mining Turtle (for mining):**
```
[ Modem ] [ Turtle ] [ Pickaxe ]
    │         │          │
    └─────────┼──────────┘
              ▼
      Advanced Mining Turtle
```

**Advanced Turtle (for chunky):**
```
[ Modem ] [ Turtle ] [   Any   ]
    │         │          │  
    └─────────┼──────────┘
              ▼
      Advanced Turtle
```

### 4. Load Programs on Disk

Place a computer next to disk drive:
```bash
cd disk/
# Get all eSlicer programs from GitHub
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/startup_mining.lua startup_mining
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/mining_client.lua mining_client
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/startup_chunky.lua startup_chunky
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/chunky_client.lua chunky_client
```

### 5. Setup Server Turtle
```bash
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/server.lua server
server 5  # Start with 5x5 segments
```

### 6. Setup Phone Control (Optional)
On wireless pocket computer:
```bash
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/phone_client.lua phone_client
phone_client
```

## Quick Start Commands

### Basic Mining Operation
1. Position equipment as shown above
2. Run `server` on server turtle  
3. Use phone client or send coordinates directly:
   ```
   # Format: startX startY startZ sizeX sizeY sizeZ
   rednet.send(serverID, "100 64 200 50 30 50")
   ```

### GPS Setup (Required First Time)
If no GPS network exists:
```bash
# On GPS deployment turtle
gps-deploy locate 20  # 20 blocks above current position
```

## Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| No GPS signal | Deploy GPS satellites first |
| Turtles won't deploy | Check turtle chests have correct turtle types |
| Out of fuel | Fill coal chest, turtles auto-refuel |
| Stuck mining | Increase segmentation size (`server 10`) |
| Chunks unloading | Ensure chunky turtles are deploying properly |

## Expected Performance

| Area Size | Segmentation | Turtle Pairs | Est. Time |
|-----------|--------------|--------------|-----------|
| 25x25x10  | 5            | 25           | ~30 min   |
| 50x50x20  | 10           | 25           | ~2 hours  |
| 100x100x30| 20           | 25           | ~8 hours  |
| 200x200x50| 25           | 64           | ~24 hours |

## Pro Tips

1. **Start Small**: Test with 10x10 area first
2. **Fuel Planning**: 1 coal block ≈ 800 blocks mined
3. **Chunk Loading**: Chunky turtles prevent mining interruption
4. **Ender Storage**: Use for automatic item sorting
5. **Backup Power**: Keep server chunk loaded with chunk loaders

## Common Coordinate Mistakes

❌ **Wrong**: Using relative coordinates  
✅ **Correct**: Use absolute coordinates (F3 debug info)

❌ **Wrong**: Starting from center of area  
✅ **Correct**: Start from bottom-left corner

❌ **Wrong**: Placing server inside mining area  
✅ **Correct**: Place server 2+ blocks outside area

## How the Deployment Works

The server turtle automatically:
1. **Clears its inventory** (keeps only fuel)
2. **Gets mining turtle from left chest** → places **in front** towards mining area
3. **Moves to disk drive** (front-left) → writes programs to disk → mining turtle loads them
4. **Returns, turns right to right chest** → gets chunky turtle  
5. **Moves forward** → places chunky turtle **next to mining turtle**
6. **Uses disk drive again** for chunky programs → both turtles get coordinates  
7. **Returns to position** → repeats for each segmented area

The turtles then work as pairs - mining turtle digs using tClear algorithm while chunky turtle follows and keeps chunks loaded.

## File Dependencies

```
server.lua 
├── Deploys: mining_client.lua + startup_mining.lua
├── Deploys: chunky_client.lua + startup_chunky.lua  
└── Uses: disk drive for program transfer

phone_client.lua
└── Connects to: server.lua (wireless)
```
