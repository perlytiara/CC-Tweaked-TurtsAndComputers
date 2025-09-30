# eHydra - Advanced Turtle Management System

eHydra is a comprehensive turtle management system for CC:Tweaked that provides auto-updating, deployment, and initialization capabilities for advanced mining turtles.

## Features

- **Auto-Updater**: Download and install programs directly from GitHub
- **Turtle Deployment**: Deploy and configure advanced mining turtles from inventory
- **Batch Operations**: Update multiple programs at once
- **Wireless Management**: Configure and control turtles via rednet
- **GPS Integration**: Automatic positioning and coordinate management

## Programs

### autoupdater.lua
Downloads and installs individual programs from GitHub raw links.

```bash
autoupdater <github_raw_url> <local_filename>
```

Example:
```bash
autoupdater https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/stairs/multi.lua stairs-multi
```

### batch_updater.lua  
Updates multiple predefined programs from the GitHub repository.

```bash
batch_updater
```

### init.lua
Main initialization system for turtle deployment and setup.

```bash  
init
```

Options:
1. Deploy Advanced Mining Turtle
2. Deploy Advanced Wireless Chunky Turtle
3. Initialize existing turtle
4. Setup GPS system
5. Full deployment sequence

### turtle_deployer.lua
Advanced turtle placement and fleet management system.

```bash
turtle_deployer
```

Options:
1. Deploy single Advanced Mining Turtle
2. Setup Advanced Wireless Chunky Turtle
3. Deploy Mining Fleet
4. List inventory turtles

### self_update.lua
Self-updating system for all eHydra programs.

```bash
self_update
```

Automatically downloads and updates all eHydra programs from the GitHub repository with backup and restore capabilities.

### restore_backups.lua
Backup restoration system.

```bash
restore_backups
```

Restores eHydra programs from backup files created during updates.

## Quick Start

1. **Install the system**:
   ```bash
   mkdir eHydra
   cd eHydra
   # Copy all .lua files to this directory
   ```

2. **Update programs**:
   ```bash
   batch_updater
   ```

3. **Deploy a mining turtle**:
   ```bash
   init
   # Select option 1 or 2
   ```

4. **Deploy a mining fleet**:
   ```bash
   turtle_deployer
   # Select option 3
   ```

## Requirements

- CC:Tweaked computer/turtle
- Internet access for auto-updater
- Wireless modem for remote turtle management
- Advanced turtles in inventory for deployment

## Supported Turtle Types

- `computercraft:turtle_advanced` - Standard advanced turtle
- `advancedperipherals:chunky_turtle` - Chunky loading turtle
- `computercraft:turtle_normal` - Basic turtle (limited features)

## Network Protocol

eHydra uses rednet for turtle communication with the following commands:

- `{command = "INIT", program = "quarry", autostart = true}`
- `{command = "CONFIG", fuelLevel = 1000, program = "quarry"}`  
- `{command = "START"}` - Start mining operation
- `{command = "STOP"}` - Stop current operation
- `{command = "STATUS"}` - Get turtle status

## Integration

eHydra integrates with existing turtle programs and can deploy:
- Quarry turtles
- Stairs builders  
- tClear systems
- Custom mining programs

Works with GPS systems for automatic positioning and coordinate management.
