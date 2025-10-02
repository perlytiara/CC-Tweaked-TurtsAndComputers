# eDig System

Fast tunnel digger for ComputerCraft turtles with multi-turtle coordination.

## Files

- `edig.lua` - Main tunnel digger program
- `client.lua` - Remote turtle listener
- `multi.lua` - Multi-turtle coordinator
- `startup.lua` - Auto-start client on turtle boot
- `download.lua` - Install system
- `update.lua` - Update all files

## Quick Start

### Installation
```lua
wget https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/programs/perlytiara/eDig/download.lua
download
```

### Usage
```lua
edig dig                    -- Interactive mode
edig dig 3 32 3            -- 3x3x32 tunnel
edig dig 4 50 5 place      -- 4x5x50 tunnel with floors
multi                       -- Multi-turtle coordinator
client                      -- Start turtle client
update                      -- Update all files
```

## Commands

### Single Turtle
- `edig dig [height] [length] [width] [place] [segment]` - Dig tunnels
- `edig help` - Show help

### Multi-Turtle
- `multi` - Send jobs to multiple turtles
- `client` - Start remote listener (run on turtles)

### System
- `download` - Install system
- `update` - Update all files from online
- `startup` - Auto-start client (put in startup file)

## Features

- **Separate programs** - Clean organization
- **Multi-turtle coordination** - Remote control via rednet
- **Smart fueling** - Automatic fuel management
- **Segmentation support** - For large tunnel projects
- **Easy updates** - Quick online updates
- **Interactive modes** - User-friendly prompts

## Update System

To update all files:
```lua
update
```

This downloads the latest versions of all eDig files from the repository.