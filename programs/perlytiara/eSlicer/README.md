# eSlicer - Enhanced Mining System

eSlicer is an advanced turtle mining system that pairs mining turtles with chunky turtles for efficient large-scale mining operations. It uses the tClear triple-digging algorithm and automatic chunk loading for optimal performance.

## Features

- **Paired Mining**: Each mining turtle is paired with a chunky turtle for chunk loading
- **Triple Digging**: Uses tClear's efficient 3-layer mining algorithm  
- **Smart Segmentation**: Automatically divides large areas among multiple turtle pairs
- **Inventory Management**: Auto-deposits to Ender Storage chests
- **GPS Navigation**: Precise positioning and pathfinding
- **Automatic Deployment**: Server deploys turtles and programs via disk drive
- **Remote Control**: Wireless pocket computer interface

## Setup Requirements

### Hardware Setup

1. **Server Platform** (positioned 2 blocks behind bottom-left corner of mining area):
   ```
   [Mining Area - Turtles deploy forward into this area]
   
   [D] [T] [T]  <- Deployed turtles row (T=turtles, D=disk drive)
   
   [M] [S] [C]  <- Setup row (server faces mining area)
   ```
   Where:
   - `S` = Server turtle (Advanced, with wireless modem) 
   - `M` = Left chest with Mining turtles (Advanced Mining + wireless modems)
   - `C` = Right chest with Chunky turtles (Advanced + wireless modems)
   - `D` = Disk drive in front-left position with all programs
   - `T` = Deployed turtle positions (mining turtle center, chunky turtle right)

2. **Turtle Specifications**:
   - **Left Chest**: Advanced Mining Turtles (with wireless modems + pickaxes)
   - **Right Chest**: Advanced Turtles (with wireless modems for chunk loading)
   - **Server Inventory**: Coal/fuel for operations

3. **GPS Satellites**: Required for precise positioning (see GPS setup section)

### Software Installation

#### Step 1: Prepare Disk Drive
1. Place a computer next to the disk drive
2. Insert a disk and run:
   ```
   cd disk/
   wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/startup_mining.lua startup_mining
   wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/mining_client.lua mining_client
   wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/startup_chunky.lua startup_chunky
   wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/main/programs/perlytiara/eSlicer/chunky_client.lua chunky_client
   ```

#### Step 2: Server Setup
1. On the server turtle, run:
   ```
   pastebin get [PASTEBIN_ID] server
   ```

#### Step 3: Phone Client (Optional)
1. On a wireless pocket computer:
   ```
   pastebin get [PASTEBIN_ID] phone_client
   ```

## Usage Instructions

### Quick Start

1. **Position Equipment**: 
   - Place server turtle 2 blocks behind bottom-left corner of mining area (facing the mining area)
   - Place left chest next to server with Advanced Mining Turtles (wireless + pickaxe)
   - Place right chest next to server with Advanced Chunky Turtles (wireless)
   - Place disk drive behind server turtle with floppy disk containing all programs
   - Give server turtle some coal/fuel in inventory

2. **Start Server**:
   ```
   server [segmentation_size]
   ```
   Default segmentation is 5x5. For larger areas, use higher values (10-50).

3. **Send Mining Request**:
   - Use phone client to send coordinates, OR
   - Use rednet to send: `X Y Z WIDTH HEIGHT DEPTH`

### Advanced Usage

#### Custom Segmentation
- Small areas (< 50x50): `server 5`
- Medium areas (50x200): `server 10` 
- Large areas (200x500): `server 25`
- Massive areas (500+): `server 50`

#### Mining Patterns
The system uses tClear's serpentine pattern:
1. Enter mining area
2. Mine in S-pattern (left-right-left-right)
3. Triple dig (current + up + down blocks)
4. Return to start and descend 3 levels
5. Repeat until complete

#### Chunk Loading Strategy
- Chunky turtles follow 2 blocks behind mining turtles
- Perform anti-idle movements to keep chunks active
- Coordinate via wireless messaging

## GPS Setup

eSlicer requires GPS satellites for precise positioning. Use the included GPS deployment script:

1. **Setup GPS Deployment Turtle**:
   - Slot 1: Fuel (coal/charcoal)
   - Slot 2: 4+ Advanced Computers  
   - Slot 3: 4+ Wireless Modems
   - Slot 4: 1-4 Disk Drives (depending on turtle type)
   - Slot 5: 1 Floppy Disk

2. **Deploy GPS Network**:
   ```
   gps-deploy X Y Z [height_offset]
   ```
   Where X Y Z are the EXACT coordinates of the deployment turtle.

3. **Auto-Location** (if existing GPS available):
   ```
   gps-deploy locate [height_offset]
   ```

## Turtle Specifications

### Mining Turtles
- **Type**: Advanced Mining Turtle
- **Required**: Wireless Modem (left side), Diamond Pickaxe (right side)
- **Fuel**: Auto-managed, pulls from server area
- **Inventory**: Auto-managed with Ender Storage

### Chunky Turtles  
- **Type**: Advanced Turtle
- **Required**: Wireless Modem
- **Purpose**: Chunk loading and coordination
- **Fuel**: Minimal requirements, auto-managed

## Troubleshooting

### Common Issues

1. **"No GPS signal"**
   - Ensure GPS satellites are deployed and running
   - Check that satellites are at different heights (auto-configured)

2. **"No mining turtle available"**
   - Check left chest has Advanced Mining Turtles
   - Ensure turtles have wireless modems

3. **Turtles get stuck**
   - Usually due to insufficient fuel
   - Check coal chest has adequate fuel supply

4. **Chunks not loading properly**
   - Ensure chunky turtles are properly deployed
   - Check wireless communication between turtle pairs

### Debug Commands

On server turtle:
```lua
-- Check modem
peripheral.isPresent("right")

-- Check chests
peripheral.getNames()

-- Check GPS
gps.locate()
```

## Performance Tips

1. **Segmentation Sizing**:
   - Too small: Overhead from many turtle pairs
   - Too large: Risk of chunk unloading
   - Optimal: 5x5 to 25x25 depending on area

2. **Fuel Management**:
   - Use coal blocks for long operations
   - Pre-calculate fuel needs: ~1 coal per 80 blocks mined

3. **Inventory Management**:
   - Configure Ender Storage for automatic sorting
   - Set up void chests for unwanted materials

## System Architecture

```
Phone Client ──┐
               ├─► Server Turtle ──┐
Rednet/Modem ──┘                   ├─► Mining Turtle ──┬─► Chunky Turtle
                                   └─► Mining Turtle ──┴─► Chunky Turtle
                                       [More pairs...]
```

Communication Channels:
- `420`: Server ↔ Clients
- `421`: Mining ↔ Chunky coordination  
- `69`: Phone ↔ Server

## File Structure

```
eSlicer/
├── server.lua           # Main server program
├── mining_client.lua    # Mining turtle client
├── chunky_client.lua    # Chunky turtle client  
├── startup_mining.lua   # Mining turtle startup
├── startup_chunky.lua   # Chunky turtle startup
├── phone_client.lua     # Remote control interface
└── README.md           # This file
```

## Credits

Based on:
- **tClear** by Kaikaku - Triple digging algorithm
- **Maengorn Mining System** - Multi-turtle coordination
- **GPS Deploy** by BigSHinyToys/neonerZ - Satellite deployment

Enhanced with paired turtle coordination and chunk loading capabilities.

## Version History

- **v1.0**: Initial release with paired mining/chunky system
- **v1.1**: Enhanced inventory management and GPS integration
- **v1.2**: Added phone client and remote control features
