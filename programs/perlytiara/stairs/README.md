# Stairs System

Simple, fast stair builder for ComputerCraft turtles.

## Files

- `stairs.lua` - Main stair builder program
- `client.lua` - Remote listener for turtle clients  
- `multi.lua` - Send jobs to multiple turtles
- `startup.lua` - Auto-start client on turtle boot
- `download.lua` - Install system to computer/turtle

## Quick Start

### Single Turtle
```lua
stairs              -- Interactive prompts (shows resource scan)
stairs 3            -- Headroom 3, up to surface  
stairs 4 down 50    -- Headroom 4, down 50 steps
stairs 2 up 100     -- Headroom 2, up exactly 100 steps
stairs 3 up auto    -- Headroom 3, up using all available blocks
stairs 2 down 25 place -- Headroom 2, down 25 steps, place floors
```

### Multiple Turtles
1. Run `client` on each turtle (or use `startup.lua`)
2. Run `multi` on a computer to send jobs

## Features

- **Resource scanning**: Automatically scans and counts fuel/blocks in inventory
- **Smart block placement**: Uses any non-fuel items as building blocks
- **Flexible length control**: Set exact steps, use surface detection, or auto-use available blocks
- **Efficient fuel usage**: Only refuels when needed, preserves fuel items
- **Clear UI**: Shows resource counts and build estimates
- **Remote control**: Control multiple turtles from one computer

## Arguments

Format: `stairs [headroom] [up/down] [length] [place]`

- `headroom` - Blocks of clearance above each step (default: 3)
- `up/down` - Direction (default: up)
- `length` - Steps to build, "auto" for max blocks, or surface detection (default: surface for up, 32 for down)
- `place` - Place floor blocks if missing

## Examples

**Basic Usage:**
- `stairs 3` → Headroom 3, up to surface
- `stairs 4 down 50` → Headroom 4, down exactly 50 steps
- `stairs 2 up 100` → Headroom 2, up exactly 100 steps

**Advanced:**
- `stairs 3 up auto place` → Use all available blocks going up, place floors
- `stairs 2 down 25 place` → Down 25 steps with floor placement
- Interactive mode shows: "Resources: 64 fuel, 128 blocks"
