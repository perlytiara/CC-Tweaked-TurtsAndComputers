# CCommander System

A comprehensive turtle management and deployment system for ComputerCraft: Tweaked.

## Overview

The CCommander system provides automated turtle deployment, management, and communication capabilities. It includes an autoupdater, test boot-up system, turtle deployer, and chest management tools.

## Programs

### Core Programs

1. **autoupdater.lua** - Auto-updates programs based on turtle type detection
2. **test_bootup.lua** - Main test boot-up system with turtle deployment from chests
3. **turtle_deployer.lua** - Advanced turtle deployment system
4. **chest_manager.lua** - Chest management and inventory tracking
5. **startup.lua** - System startup script

### Program Configurations

The autoupdater supports different turtle types:
- **mining_turtle** - Advanced wireless mining turtles
- **chunky_turtle** - Chunky wireless advanced turtles  
- **controller** - Mining controller systems
- **deployment** - Deployment system components
- **all** - All programs

## Test Boot-up System

The test boot-up system (`test_bootup.lua`) provides:

### Features
- **Chest Management**: 
  - Left chest: Advanced mining wireless turtles
  - Right chest: Chunky wireless advanced turtles
  - Below: Coal chest for fuel
- **Automatic Deployment**: Deploys turtles from chests to specified positions
- **Fuel Management**: Automatically fuels deployed turtles
- **Program Startup**: Starts appropriate programs on deployed turtles
- **Status Monitoring**: Tracks deployment status and turtle states

### Usage
1. Place turtles in the appropriate chests
2. Ensure coal chest below computer has fuel
3. Run `test_bootup.lua`
4. Select "Deploy All Turtles" from the menu
5. Monitor deployment progress

### Deployment Positions
- **Mining Turtles**: Deploy to the left (starting at x=-5)
- **Chunky Turtles**: Deploy to the right (starting at x=5)
- **Spacing**: Turtles are spaced 2 blocks apart

## Autoupdater

The autoupdater (`autoupdater.lua`) provides:

### Features
- **Turtle Type Detection**: Automatically detects turtle type based on available tools and programs
- **Program Updates**: Downloads and updates programs from GitHub repository
- **Manual Selection**: Allows manual selection of programs to update
- **Settings Management**: Configurable install paths and options

### Usage
1. Run `autoupdater.lua`
2. Select update option:
   - Update detected turtle type
   - Update all programs
   - Manual selection
3. Configure settings as needed

## Turtle Deployer

The turtle deployer (`turtle_deployer.lua`) provides:

### Features
- **Single Turtle Deployment**: Deploy individual turtles
- **Batch Deployment**: Deploy multiple turtles at once
- **Position Management**: Automatic positioning and spacing
- **Status Tracking**: Monitor deployed turtle status

## Chest Manager

The chest manager (`chest_manager.lua`) provides:

### Features
- **Chest Scanning**: Automatically detect and scan nearby chests
- **Inventory Tracking**: Track turtles and fuel in chests
- **Fuel Distribution**: Manage fuel distribution across chests
- **Detailed Inventory**: View detailed contents of each chest

## Installation

1. Place all files in `programs/perlytiara/cCommander/`
2. Run `startup.lua` to launch the system
3. Use `autoupdater.lua` to keep programs updated

## Configuration

### Chest Positions (relative to computer)
- **Left Chest**: x=-1, y=0, z=0 (mining turtles)
- **Right Chest**: x=1, y=0, z=0 (chunky turtles)  
- **Coal Chest**: x=0, y=-1, z=0 (fuel)

### Deployment Positions
- **Mining Turtles**: Start at x=-5, deploy leftward
- **Chunky Turtles**: Start at x=5, deploy rightward

## Requirements

- ComputerCraft: Tweaked
- Wireless modems (for turtle communication)
- Chests with turtles and fuel
- Appropriate startup programs on turtles

## Repository

Programs are automatically updated from:
`https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/cCommander/`

## Version

Current version: 1.0 (2024-12-19)

## Support

For issues or questions, refer to the main CC-Tweaked-TurtsAndComputers repository.
