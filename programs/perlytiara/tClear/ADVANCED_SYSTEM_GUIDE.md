# Advanced Wireless Mining System - Complete Guide

## 🚀 Overview

The Advanced Wireless Mining System is a comprehensive solution for automated mining operations using ComputerCraft turtles. It features a computer-controlled master system that coordinates mining turtles and chunky turtles for optimal performance and safety.

## 🏗️ System Architecture

```
[Computer] ← Master Controller
    ↓
[Wireless Network]
    ↓
[Mining Turtle] ← Left Corner Position
    ↓
[Chunky Turtle] ← Right Side (1 block right of mining turtle)
```

## 📋 Components

### 1. AdvancedMiningController.lua
- **Purpose**: Master controller running on a computer
- **Features**: 
  - Automatic turtle discovery
  - Real-time operation monitoring
  - Pause/resume controls
  - Status reporting
  - Multi-turtle coordination

### 2. AdvancedMiningTurtle.lua
- **Purpose**: Enhanced mining turtle with wireless communication
- **Features**:
  - Remote control capability
  - Real-time status updates
  - Chunky turtle coordination
  - Pause/resume support
  - Error handling and recovery

### 3. AdvancedChunkyTurtle.lua
- **Purpose**: Enhanced chunky turtle for chunk loading
- **Features**:
  - Improved following behavior
  - Better error handling
  - Status reporting
  - Automatic recovery from movement failures

## 🛠️ Setup Instructions

### Step 1: Hardware Requirements

**Computer (Master Controller):**
- ComputerCraft computer
- Wireless modem
- Monitor (optional, for better interface)

**Mining Turtle:**
- Advanced mining turtle
- Wireless modem
- Pickaxe (or other mining tool)
- Fuel (coal, charcoal, etc.)

**Chunky Turtle:**
- Wireless turtle
- Wireless modem
- No tools required
- Fuel (coal, charcoal, etc.)

### Step 2: Placement

```
[Chunky] [Mining] ← Start here
   ↓        ↓
  Turtle   Turtle
```

1. Place the **mining turtle** at the left corner of your desired mining area
2. Place the **chunky turtle** one block to the **right** of the mining turtle
3. Both turtles should be at the **same height** and **facing the same direction**
4. Ensure both turtles have wireless modems attached

### Step 3: Software Installation

Copy the following files to the appropriate devices:

**On the Computer:**
- `AdvancedMiningController.lua`

**On the Mining Turtle:**
- `AdvancedMiningTurtle.lua`

**On the Chunky Turtle:**
- `AdvancedChunkyTurtle.lua`

### Step 4: Get Device IDs

On each device, run:
```lua
print(os.getComputerID())
```

Note down all three IDs:
- Computer ID
- Mining Turtle ID  
- Chunky Turtle ID

## 🎮 Usage Guide

### Quick Start

1. **Start the Chunky Turtle:**
   ```lua
   AdvancedChunkyTurtle
   ```
   The chunky turtle will display "Waiting for pairing with master turtle..."

2. **Start the Mining Turtle:**
   ```lua
   AdvancedMiningTurtle
   ```
   The mining turtle will display "Waiting for controller commands..."

3. **Start the Master Controller:**
   ```lua
   AdvancedMiningController
   ```
   Follow the on-screen prompts to:
   - Discover and select turtles
   - Configure mining parameters
   - Start the operation

### Operation Parameters

**Basic Parameters:**
- **Depth**: How far forward to mine (must be ≥ 1)
- **Width**: How wide to mine (cannot be -1, 0, or 1)
- **Height**: How tall to mine (cannot be 0)

**Advanced Options:**
- `layerbylayer` - Mine one layer at a time (safer for lava)
- `startwithin` - Start inside the mining area
- `stripmine` - Use for strip mining operations

### Example Commands

```lua
# Basic mining operation
Depth: 10
Width: 5
Height: 3
Options: (none)

# Safe mining with layer-by-layer
Depth: 20
Width: 8
Height: 4
Options: layerbylayer

# Strip mining
Depth: 50
Width: -2
Height: 3
Options: stripmine layerbylayer
```

## 📊 Monitoring and Control

### Real-time Monitoring

During operation, you can:
- Press `s` for status updates
- Press `p` to pause the operation
- Press `r` to resume the operation
- Press `q` to quit monitoring (operation continues)

### Status Information

The system provides real-time information about:
- Current position of mining turtle
- Mining progress
- Fuel levels
- Inventory status
- Chunky turtle status

## 🔧 Advanced Features

### Automatic Discovery

The system automatically discovers available turtles on the network:
- Scans for mining turtles
- Scans for chunky turtles
- Displays fuel and inventory information
- Allows selection of specific turtles

### Error Handling

**Mining Turtle:**
- Automatic fuel management
- Movement retry logic
- Error reporting to controller
- Graceful operation shutdown

**Chunky Turtle:**
- Movement failure recovery
- Digging when blocked
- Retry logic for failed movements
- Status reporting

### Communication Protocols

The system uses multiple communication protocols:
- `advanced-mining` - Main control protocol
- `tclear-chunky` - Chunky turtle specific protocol
- Automatic fallback to legacy protocols

## 🚨 Troubleshooting

### Common Issues

**"No mining turtles found"**
- Ensure mining turtle is running `AdvancedMiningTurtle.lua`
- Check wireless modem is attached and working
- Verify both devices are on the same network

**"No chunky turtles found"**
- Ensure chunky turtle is running `AdvancedChunkyTurtle.lua`
- Check wireless modem is attached and working
- Operation can continue without chunky turtle (not recommended)

**"No modem found"**
- Attach a wireless modem to the device
- Ensure modem is properly connected
- Check modem is not damaged

**Chunky turtle not following**
- Check rednet communication between turtles
- Restart both turtles if needed
- Verify turtle IDs are correct
- Check for obstacles blocking chunky turtle

**Mining turtle breaks during operation**
- This should not happen with chunky pairing
- Check that chunky turtle is actually following
- Ensure chunk loading signals are being sent
- Verify both turtles have adequate fuel

### Debug Mode

To enable debug output, edit the respective script files:
```lua
local blnDebugPrint = true
```

### Manual Recovery

If the system fails:
1. Stop all devices (Ctrl+T)
2. Restart chunky turtle first: `AdvancedChunkyTurtle`
3. Restart mining turtle: `AdvancedMiningTurtle`
4. Restart controller: `AdvancedMiningController`

## 📈 Performance Tips

### Optimal Placement
- Place chunky turtle exactly one block to the right of mining turtle
- Ensure clear path for chunky turtle to follow
- Avoid placing near lava or dangerous areas
- Keep both turtles at the same height

### Fuel Management
- Keep both turtles well-fueled
- Monitor fuel levels during operation
- Have backup fuel ready
- Use efficient fuel sources (coal, charcoal)

### Network Optimization
- Ensure good wireless signal strength
- Avoid interference from other wireless devices
- Keep devices within reasonable range
- Use wired modems for long-distance operations

## 🔒 Safety Considerations

### Operation Safety
- Always test in a safe area first
- Monitor the operation, especially for large excavations
- Keep backup fuel for both turtles
- Ensure adequate inventory space

### Turtle Safety
- The chunky turtle is vulnerable while following
- Protect chunky turtle from mobs
- Avoid dangerous areas (lava, void, etc.)
- Keep both turtles fueled and maintained

### Emergency Procedures
- Press Ctrl+T on any device to stop
- Both turtles will stop safely
- Manual recovery procedures available
- System can be restarted after issues

## 📚 API Reference

### Message Types

**Discovery Messages:**
- `discover` - Controller requests turtle discovery
- `mining_turtle_available` - Mining turtle responds to discovery
- `chunky_turtle_available` - Chunky turtle responds to discovery

**Control Messages:**
- `start_mining` - Start mining operation
- `start_chunky` - Start chunky turtle pairing
- `pause_operation` - Pause current operation
- `resume_operation` - Resume paused operation
- `stop_operation` - Stop current operation

**Status Messages:**
- `status_request` - Request status update
- `status_update` - Send status information
- `operation_complete` - Operation finished
- `operation_error` - Operation failed

**Chunky Messages:**
- `move` - Move chunky turtle to position
- `chunk_load` - Send chunk loading signal
- `chunky_ready` - Chunky turtle ready confirmation

## 🆘 Support

If you encounter issues:
1. Check this guide first
2. Verify all files are properly installed
3. Test with simple parameters first
4. Check turtle fuel and inventory space
5. Ensure proper turtle placement and network connectivity
6. Enable debug mode for detailed logging

## 📝 Version History

**v2.0 (2024-12-19)**
- Complete rewrite with advanced wireless communication
- Enhanced error handling and recovery
- Real-time monitoring and control
- Improved chunky turtle following behavior
- Multi-protocol communication support

**v1.0 (Original tClear)**
- Basic mining functionality
- Simple chunky turtle pairing
- Limited wireless communication

---

**Need help?** Check the troubleshooting section or enable debug mode for detailed logging.
