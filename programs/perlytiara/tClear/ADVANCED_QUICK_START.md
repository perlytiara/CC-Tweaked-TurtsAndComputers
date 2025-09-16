# Advanced Wireless Mining System - Quick Start

## 🚀 5-Minute Setup

### 1. Place Your Turtles
```
[Chunky] [Mining] ← Your starting position
```
**Note:** Chunky turtle goes to the RIGHT of the mining turtle at SAME HEIGHT

### 2. Get IDs
On each device: `print(os.getComputerID())`

### 3. Start Operation
**Step 1: Start Chunky Turtle**
```lua
AdvancedChunkyTurtle
```

**Step 2: Start Mining Turtle**
```lua
AdvancedMiningTurtle
```

**Step 3: Start Controller (on Computer)**
```lua
AdvancedMiningController
```

## 📋 Quick Commands

### Basic Mining
```
Depth: 10
Width: 5
Height: 3
Options: (none)
```

### Safe Mining
```
Depth: 20
Width: 8
Height: 4
Options: layerbylayer
```

### Strip Mining
```
Depth: 50
Width: -2
Height: 3
Options: stripmine layerbylayer
```

## ⚙️ Parameters
- **Depth**: Forward distance (≥1)
- **Width**: Side distance (not -1,0,1)  
- **Height**: Up/down distance (not 0)

## 🛠️ Options
- `layerbylayer` - Safer mining
- `startwithin` - Start inside area
- `stripmine` - Strip mining mode

## 📊 Monitoring
During operation:
- Press `s` for status
- Press `p` to pause
- Press `r` to resume
- Press `q` to quit monitoring

## 🔧 Troubleshooting

### "No mining turtles found"
1. Start mining turtle first: `AdvancedMiningTurtle`
2. Check wireless modems
3. Verify network connectivity

### "No chunky turtles found"  
1. Start chunky turtle first: `AdvancedChunkyTurtle`
2. Check wireless modems
3. Operation can continue without chunky (not recommended)

### "No modem found"
- Attach wireless modem to device

### Turtle breaks during mining
- This should not happen with chunky pairing
- Check chunky turtle is following
- Restart both turtles if needed

## 📍 Placement Rules
- Chunky turtle goes to the **RIGHT** of mining turtle
- **SAME HEIGHT** as mining turtle
- **SAME FACING DIRECTION** as mining turtle
- Clear path for chunky turtle to follow
- Avoid lava and dangerous areas

## ⛽ Fuel Tips
- Keep both turtles fueled
- Monitor fuel levels during operation
- Have backup fuel ready

## 🆘 Emergency Stop
- Press `Ctrl+T` on any device to stop
- Both turtles will stop safely

---
**Need help?** See `ADVANCED_SYSTEM_GUIDE.md` for detailed instructions.
