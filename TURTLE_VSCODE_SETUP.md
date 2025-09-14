# Turtle VS Code Extension Setup Guide

This guide will help you set up VS Code to connect to and manage ComputerCraft turtles using the CraftOS-PC Remote extension.

## Prerequisites

### 1. Required Software
- **Visual Studio Code** (latest version recommended)
- **CraftOS-PC extension** (version 1.1 or later)
- **Lua extension** (for syntax highlighting and IntelliSense)
- **CC: Tweaked** (version 1.85.0 or later, 1.91.0+ recommended)

### 2. Turtle Requirements
- **Wireless Modem** attached to any side of the turtle
- **Advanced Turtle** (recommended for best compatibility)
- **Fuel** available for the turtle to operate

## Installation Steps

### Step 1: Install VS Code Extensions

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for and install:
   - `CraftOS-PC` by JackMacWindows
   - `Lua` by sumneko (for syntax highlighting)

### Step 2: Configure VS Code Settings

The workspace is already configured with the necessary settings in `.vscode/settings.json`:

```json
{
    "http.systemCertificates": false,
    "craftos-pc.autoConnect": true,
    "craftos-pc.showTerminal": true,
    "lua.workspace.library": [
        "${workspaceFolder}/types"
    ],
    "lua.diagnostics.globals": [
        "turtle", "peripheral", "redstone", "gps", "vector", "term", "bit32"
    ]
}
```

### Step 3: Fix Certificate Issues (if needed)

If you encounter "certificate has expired" errors:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Preferences: Open Settings (JSON)"
3. Add this line before the closing `}`:
   ```json
   "http.systemCertificates": false
   ```
4. Restart VS Code

## Connecting to Turtles

### Method 1: Using VS Code Extension

1. **Start the Connection:**
   - Click the CraftOS-PC button in the VS Code sidebar
   - Click "Connect to Remote"
   - A new terminal window will open with a connection command

2. **Connect the Turtle:**
   - Copy the connection command from VS Code
   - Paste it into your turtle's terminal and press Enter
   - The connection will be established

3. **Access Files:**
   - Hover over "ComputerCraft Remote Terminal" in the sidebar
   - Click the "Remote" button (screen icon with arrows)
   - The turtle's file system will be added to your workspace

### Method 2: Using Web Interface

1. Visit https://remote.craftos-pc.cc
2. Click "Connect Now"
3. Copy the provided command to your turtle

## Turtle Management Scripts

The `turtle-manager/` directory contains several utilities:

### 1. `turtle-connector.lua`
- Helps establish VS Code connections
- Checks for required hardware (wireless modem)
- Provides step-by-step connection instructions

### 2. `file-sync.lua`
- Displays turtle file system structure
- Shows disk usage information
- Creates backups of important files

### 3. `program-deployer.lua`
- Creates new program templates
- Lists available programs from your collection
- Helps install programs from the workspace

### 4. `startup.lua`
- Runs automatically when turtle starts
- Provides quick access to all management tools
- Shows available programs and quick actions

## Using the Turtle Manager

### Deploying the Manager to a Turtle

1. **Connect to your turtle** using the VS Code extension
2. **Copy the manager scripts** to the turtle:
   - Copy `turtle-manager/startup.lua` to the turtle's root directory
   - Copy other manager scripts to a `turtle-manager/` directory on the turtle

3. **Set up auto-start** (optional):
   - Rename `startup.lua` to `startup` (remove .lua extension)
   - This will make it run automatically when the turtle starts

### Using the Manager

1. **Run the startup script:**
   ```
   startup
   ```

2. **Choose from the menu:**
   - Connect to VS Code
   - File sync utilities
   - Program deployment
   - Run existing programs

## File Management

### Editing Files in VS Code

1. **Files are synced in real-time:**
   - Changes in VS Code appear on the turtle immediately after saving
   - Changes on the turtle usually appear in VS Code (may need to re-open file)

2. **Creating new files:**
   - Create files in VS Code - they'll appear on the turtle
   - Files created on the turtle won't appear in VS Code until you refresh

3. **Refreshing the workspace:**
   - Click the refresh button in the Explorer panel
   - Or use `Ctrl+Shift+P` → "File: Refresh Explorer"

### Organizing Your Programs

Your workspace contains programs organized by author:
- `programs/perlytiara/` - Advanced mining and clearing utilities
- `programs/Kaikaku/` - Harvesting and farming programs  
- `programs/MerlinLikeTheWizard/` - Mining and automation
- `programs/BigGamingGamers/` - Various automation scripts
- `programs/Silvamord/` - EpicMiningTurtle
- `programs/SimpleBeni/` - Simple farming automation

## Troubleshooting

### Connection Issues

**Problem:** "Certificate has expired" error
**Solution:** Add `"http.systemCertificates": false` to VS Code settings

**Problem:** Connection fails immediately
**Solution:** 
- Ensure turtle has wireless modem attached
- Check that CC: Tweaked version is 1.85.0+
- Try reconnecting

**Problem:** Files don't sync properly
**Solution:**
- Refresh the workspace in VS Code
- Re-open files that aren't syncing
- Check turtle's disk space

### Turtle Issues

**Problem:** Turtle won't respond to connection
**Solution:**
- Ensure wireless modem is attached and working
- Check turtle has fuel
- Try restarting the turtle

**Problem:** Programs won't run
**Solution:**
- Check file permissions
- Ensure programs are in correct directory
- Verify Lua syntax

## Advanced Usage

### Multi-Turtle Management

1. **Connect multiple turtles** using the same VS Code workspace
2. **Use different labels** for each turtle to identify them
3. **Organize programs** by turtle type or purpose

### Program Development Workflow

1. **Develop in VS Code** with full IntelliSense and debugging
2. **Test on turtle** by running the program
3. **Iterate quickly** with real-time file sync
4. **Deploy to multiple turtles** using the program deployer

### Backup and Version Control

1. **Use the file-sync utility** to create backups
2. **Commit your programs** to git from VS Code
3. **Tag releases** for different program versions

## Tips and Best Practices

1. **Always backup** important programs before making changes
2. **Test programs** on a single turtle before deploying to multiple
3. **Use descriptive labels** for your turtles
4. **Keep programs organized** in the workspace structure
5. **Monitor fuel levels** during long operations
6. **Use the startup script** for easy access to management tools

## Support

- **CraftOS-PC Documentation:** https://www.craftos-pc.cc/docs/
- **CC: Tweaked Documentation:** https://tweaked.cc/
- **VS Code Extension Issues:** Report on the CraftOS-PC GitHub repository

---

Happy turtle programming! 🐢⚡
