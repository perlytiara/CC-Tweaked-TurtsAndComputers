# tClear with Chunky Pairing - Quick Start

## 🚀 Quick Setup (5 minutes)

### 1. Place Turtles
```
[Chunky] [Mining] ← Your starting position
```
**Note:** Chunky turtle goes to the LEFT of the mining turtle at SAME HEIGHT

### 2. Get IDs
On each turtle: `print(os.getComputerID())`

### 3. Start Operation
**Option A: Direct (Recommended)**
```lua
# Terminal 1 (Chunky Turtle):
tClearChunky

# Terminal 2 (Mining Turtle):
tClear 5 3 2
```

**Option B: Remote Control**
```lua
# On mining turtle:
tClear_listener

# On chunky turtle:
tClear_listener

# On any computer:
tClear_multi
```

## 📋 Common Commands

### Basic Mining
```lua
tClear 10 5 3                    # 10 deep, 5 wide, 3 high
tClear 5 3 2 layerbylayer        # Safer, one layer at a time
tClear 8 4 2 startwithin         # Start inside the area
```

### Multi-Turtle Mining
```lua
tClear_multi                     # Follow prompts for 2-turtle setup
```

## ⚙️ Parameters
- **Depth**: Forward distance (≥1)
- **Width**: Side distance (not -1,0,1)  
- **Height**: Up/down distance (not 0)

## 🛠️ Options
- `layerbylayer` - Safer mining
- `startwithin` - Start inside area
- `stripmine` - Strip mining mode

## 🔧 Troubleshooting

### "No chunky turtle found"
1. Start chunky turtle first: `tClearChunky`
2. Check wireless modems
3. Verify network connectivity

### "No modem found"  
- Attach wireless modem to turtle

### Turtle breaks during mining
- This should not happen with chunky pairing
- Check chunky turtle is following
- Restart both turtles if needed

## 📍 Placement Rules
- Chunky turtle goes to the **LEFT** of mining turtle
- **SAME HEIGHT** as mining turtle
- **SAME FACING DIRECTION** as mining turtle
- Clear path for chunky turtle to follow
- Avoid lava and dangerous areas

## ⛽ Fuel Tips
- Keep both turtles fueled
- Monitor fuel levels during operation
- Have backup fuel ready

## 🆘 Emergency Stop
- Press `Ctrl+T` on any turtle to stop
- Both turtles will stop safely

---
**Need help?** See `USAGE_GUIDE.md` for detailed instructions.
