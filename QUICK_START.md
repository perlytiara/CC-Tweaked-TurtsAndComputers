# Quick Start: Turtle VS Code Setup

Get your ComputerCraft turtles connected to VS Code in 5 minutes!

## 🚀 Fast Setup (5 minutes)

### 1. Install Extensions (2 minutes)
1. Open VS Code
2. Install these extensions:
   - **CraftOS-PC** (search: `jackmacwindows.craftos-pc`)
   - **Lua** (search: `sumneko.lua`)

### 2. Prepare Your Turtle (1 minute)
1. Attach a **wireless modem** to any side of your turtle
2. Ensure your turtle has **fuel**
3. Make sure you're using **CC: Tweaked 1.85.0+**

### 3. Connect (2 minutes)
1. **In VS Code:** Click the CraftOS-PC button in sidebar → "Connect to Remote"
2. **On Turtle:** Copy the connection command from VS Code and paste it into the turtle's terminal
3. **In VS Code:** Click the "Remote" button next to the terminal to access turtle files

## 🛠️ Deploy Turtle Manager (Optional)

For easy turtle management, copy these files to your turtle:

```
turtle-manager/
├── startup.lua          # Main management interface
├── turtle-connector.lua # Connection helper
├── file-sync.lua        # File management
└── program-deployer.lua # Program installation
```

### Quick Deploy:
1. Connect to turtle via VS Code
2. Copy `turtle-manager/startup.lua` to turtle's root directory
3. Copy other files to `turtle-manager/` folder on turtle
4. Run `startup` on the turtle for management interface

## ⚡ Quick Actions

### Connect Turtle to VS Code
```lua
-- Run on turtle
shell.run("turtle-manager/turtle-connector")
```

### View Turtle Files
```lua
-- Run on turtle  
shell.run("turtle-manager/file-sync")
```

### Create New Program
```lua
-- Run on turtle
shell.run("turtle-manager/program-deployer")
```

## 🔧 Troubleshooting

**"Certificate expired" error?**
- Add `"http.systemCertificates": false` to VS Code settings

**Connection fails?**
- Check wireless modem is attached
- Ensure turtle has fuel
- Verify CC: Tweaked version is 1.85.0+

**Files not syncing?**
- Refresh VS Code Explorer
- Re-open files in VS Code

## 📚 Next Steps

- Read the full [TURTLE_VSCODE_SETUP.md](TURTLE_VSCODE_SETUP.md) for detailed instructions
- Explore the programs in the `programs/` directory
- Check out the documentation in `docs/` for specific program guides

---

**Need help?** Check the troubleshooting section in the full setup guide!
