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
stairs           -- Interactive prompts
stairs 3         -- Height 3, up to surface
stairs 4 down 50 -- Height 4, down 50 steps
stairs 3 up place -- Height 3, up to surface, place blocks
```

### Multiple Turtles
1. Run `client` on each turtle (or use `startup.lua`)
2. Run `multi` on a computer to send jobs

## Features

- **Smart block placement**: Uses any non-fuel items as building blocks
- **Efficient fuel usage**: Only refuels when needed
- **Simple UI**: Short prompts, clear options
- **Surface detection**: Auto-stops when reaching surface (up only)
- **Remote control**: Control multiple turtles from one computer

## Arguments

Format: `stairs [height] [up/down] [steps] [place]`

- `height` - Headroom above each step (default: 3)
- `up/down` - Direction (default: up to surface)
- `steps` - Number of steps (overrides surface mode)  
- `place` - Place blocks if missing floor

Examples:
- `stairs 3` → Height 3, up to surface
- `stairs 4 down 100` → Height 4, down 100 steps
- `stairs 2 up 50 place` → Height 2, up 50 steps, place floors
