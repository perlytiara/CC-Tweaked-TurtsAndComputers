# tClear with Chunky Turtle Pairing - Usage Guide

## Overview
The enhanced tClear system now includes automatic chunky turtle pairing to prevent the main mining turtle from breaking due to chunk unloading. The chunky turtle follows the main turtle and keeps chunks loaded.

## Setup Requirements

### Hardware Requirements
- **Main Mining Turtle**: Standard mining turtle with pickaxe and wireless modem
- **Chunky Turtle**: Wireless turtle with wireless modem (no tools needed)
- **Computer/Control Terminal**: For running tClear_multi.lua (optional)

### Software Requirements
All files should be installed on both turtles:
- `tClear.lua` - Main mining program
- `tClearChunky.lua` - Chunky turtle program  
- `tClear_listener.lua` - Communication handler (for remote operation)

## Setup Instructions

### Step 1: Place Your Turtles
```
[Mining] [Chunky] ← Start here
   ↓        ↓
  Turtle   Turtle
```

- Place the **mining turtle** at your desired starting position
- Place the **chunky turtle** one block to the **left** (behind) of the mining turtle
- Both turtles should have wireless modems attached

### Step 2: Get Turtle IDs
On each turtle, run:
```lua
print(os.getComputerID())
```
Note down both IDs for later use.

### Step 3: Install Programs
Copy all the tClear programs to both turtles:
- `tClear.lua`
- `tClearChunky.lua` 
- `tClear_listener.lua`

## Usage Methods

### Method 1: Single Turtle with Chunky Pairing (Recommended)

#### Direct Operation
1. **Start the chunky turtle first:**
   ```lua
   tClearChunky
   ```
   The chunky turtle will display "Waiting for pairing with master turtle..."

2. **Start the main mining turtle:**
   ```lua
   tClear [depth] [width] [height] [options]
   ```
   Example: `tClear 10 5 3 layerbylayer`

3. **The system will automatically:**
   - Find and pair with the chunky turtle
   - Begin mining while the chunky turtle follows
   - Keep chunks loaded throughout the operation

#### Interactive Mode
Simply run:
```lua
tClear
```
Follow the on-screen prompts to configure your mining parameters.

### Method 2: Remote Operation with Listeners

#### Setup Listeners
1. **On the mining turtle, start the listener:**
   ```lua
   tClear_listener
   ```

2. **On the chunky turtle, start the listener:**
   ```lua
   tClear_listener
   ```

#### Remote Control
From any computer on the network:
```lua
tClear_multi
```
Follow the prompts to:
- Enter turtle IDs
- Enter chunky turtle IDs (optional)
- Configure mining parameters

### Method 3: Multi-Turtle Mining

#### Two-Turtle Mining
Use `tClear_multi.lua` for coordinated mining:

1. **Run the multi-launcher:**
   ```lua
   tClear_multi
   ```

2. **Enter the required information:**
   - Number of turtles: `2`
   - Left turtle ID
   - Right turtle ID  
   - Left chunky turtle ID (optional)
   - Right chunky turtle ID (optional)
   - Mining parameters

3. **The system will:**
   - Start chunky turtles first (if specified)
   - Coordinate both mining turtles
   - Divide the work area between them

## Parameters and Options

### Basic Parameters
- **Depth**: How far forward to mine (must be ≥ 1)
- **Width**: How wide to mine (cannot be -1, 0, or 1)
- **Height**: How tall to mine (cannot be 0)

### Advanced Options
- `layerbylayer` - Mine one layer at a time (safer for lava)
- `startwithin` - Start inside the mining area
- `stripmine` - Use for strip mining operations

### Examples
```lua
# Basic mining
tClear 5 3 2

# Layer by layer mining (safer)
tClear 10 4 3 layerbylayer

# Start within the area
tClear 8 6 2 startwithin

# Strip mining
tClear 20 -2 3 stripmine layerbylayer
```

## How Chunky Pairing Works

### Automatic Discovery
1. Main turtle broadcasts "find chunky turtle" message
2. Available chunky turtles respond with their IDs
3. Main turtle pairs with the first available chunky turtle

### Movement Synchronization
- Chunky turtle maintains position one block behind (to the left of) main turtle
- All movements are synchronized (forward, back, up, down, turns)
- Chunky turtle sends periodic chunk loading signals

### Chunk Loading
- Chunky turtle sends chunk load signals every 2 seconds
- Prevents chunks from unloading while mining
- Eliminates risk of turtle breaking due to chunk unloading

## Troubleshooting

### Common Issues

#### "No chunky turtle found"
- Ensure chunky turtle is running `tClearChunky` or `tClear_listener`
- Check that both turtles have wireless modems
- Verify both turtles are on the same network

#### "No modem found"
- Attach a wireless modem to the turtle
- Ensure the modem is properly connected

#### Chunky turtle not following
- Check rednet communication between turtles
- Restart both turtles if needed
- Verify turtle IDs are correct

#### Mining turtle breaks
- This should no longer happen with chunky pairing
- If it still occurs, check that chunky turtle is actually following
- Ensure chunk loading signals are being sent

### Debug Mode
To enable debug output in chunky turtle, edit `tClearChunky.lua`:
```lua
local blnDebugPrint = true
```

### Manual Recovery
If pairing fails:
1. Stop both turtles (Ctrl+T)
2. Restart chunky turtle first: `tClearChunky`
3. Then restart mining turtle: `tClear [parameters]`

## Best Practices

### Placement
- Always place chunky turtle behind (to the left of) mining turtle
- Ensure clear path for chunky turtle to follow
- Avoid placing near lava or dangerous areas

### Operation
- Start chunky turtle before main turtle
- Use layer-by-layer mode for large operations
- Monitor fuel levels on both turtles

### Maintenance
- Keep both turtles fueled
- Ensure wireless modems have good signal
- Clean up any debris that might block chunky turtle

## Advanced Features

### Custom Positioning
The chunky turtle follows the main turtle but you can modify the relative position by editing:
```lua
local chunkyPosition = {x = -1, y = 0, z = 0, facing = 0} -- Behind main turtle
```

### Timing Adjustments
Modify chunk loading interval in `tClearChunky.lua`:
```lua
local chunkLoadingInterval = 2 -- seconds between signals
```

### Multiple Chunky Turtles
For very large operations, you can deploy multiple chunky turtles by modifying the pairing logic in `tClear.lua`.

## Safety Notes

- Always test in a safe area first
- Keep backup fuel for both turtles
- Monitor the operation, especially for large excavations
- The chunky turtle is vulnerable while following - protect it from mobs
- Ensure adequate inventory space for both turtles

## Support

If you encounter issues:
1. Check this guide first
2. Verify all files are properly installed
3. Test with simple parameters first
4. Check turtle fuel and inventory space
5. Ensure proper turtle placement and network connectivity
