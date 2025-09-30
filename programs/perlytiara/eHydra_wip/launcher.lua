-- eHydra Program Launcher
-- Runs eHydra programs with command-line arguments
-- Usage: launcher <program> <args...>

local args = {...}

if #args == 0 then
    print("eHydra Program Launcher v1.0")
    print("============================")
    print("Available programs:")
    print("  mining_setup <program> <width> <depth> <height> [params]")
    print("  turtle_deployer")
    print("  init")
    print("  batch_updater")
    print("  autoupdater <url> <name>")
    print()
    print("Examples:")
    print("  launcher mining_setup quarry 32 32 16")
    print("  launcher turtle_deployer")
    print("  launcher init")
    return
end

local program = args[1]
local programArgs = {}
for i = 2, #args do
    table.insert(programArgs, args[i])
end

-- Map program names to actual files
local programMap = {
    ["mining_setup"] = "mining_setup.lua",
    ["turtle_deployer"] = "turtle_deployer.lua", 
    ["init"] = "init.lua",
    ["batch_updater"] = "batch_updater.lua",
    ["autoupdater"] = "autoupdater.lua",
    ["self_update"] = "self_update.lua",
    ["startup"] = "startup.lua"
}

local programFile = programMap[program] or (program .. ".lua")

print("🚀 eHydra Launcher")
print("Program: " .. program)
if #programArgs > 0 then
    print("Args: " .. table.concat(programArgs, " "))
end
print()

if fs.exists(programFile) then
    -- Pass arguments to the program
    shell.run(programFile, table.unpack(programArgs))
else
    print("❌ Program not found: " .. program)
    print("Available programs: " .. table.concat({"mining_setup", "turtle_deployer", "init", "batch_updater", "autoupdater"}, ", "))
end
