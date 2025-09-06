-- resetComputer.lua
-- Safely reset a ComputerCraft computer/turtle to factory defaults by wiping the local HDD.
-- Preserves ROM and any mounted disks. Supports confirmation, dry-run, and keep-list.

local function printUsage()
  print("Usage: resetComputer [options]")
  print("")
  print("Options:")
  print("  --yes, -y         Proceed without interactive confirmation")
  print("  --dry-run         Show what would be deleted, but do not delete")
  print("  --keep <path>     Preserve a file/dir (can be used multiple times)")
  print("  --clear-label     Clear the computer label after reset")
  print("  --no-reboot       Do not reboot automatically after reset")
  print("  --help, -h        Show this help")
end

local function normalizePath(path)
  if not path or path == "" then return "/" end
  if string.sub(path, 1, 1) ~= "/" then
    return "/" .. path
  end
  return path
end

local function parseArgs(tArgs)
  local options = {
    assumeYes = false,
    dryRun = false,
    clearLabel = false,
    noReboot = false,
    keeps = {},
    help = false,
  }

  local i = 1
  while i <= #tArgs do
    local a = tArgs[i]
    if a == "--yes" or a == "-y" then
      options.assumeYes = true
    elseif a == "--dry-run" then
      options.dryRun = true
    elseif a == "--clear-label" then
      options.clearLabel = true
    elseif a == "--no-reboot" then
      options.noReboot = true
    elseif a == "--help" or a == "-h" then
      options.help = true
    elseif a == "--keep" then
      if i == #tArgs then
        print("Error: --keep requires a path argument")
        options.help = true
        break
      end
      local keepPath = normalizePath(tArgs[i + 1])
      options.keeps[keepPath] = true
      i = i + 1
    else
      -- Unrecognized positional may be treated as keep for convenience
      local keepPath = normalizePath(a)
      options.keeps[keepPath] = true
    end
    i = i + 1
  end

  return options
end

local function isKept(path, keeps)
  if keeps[path] then return true end
  -- Also keep if any ancestor is marked keep
  -- and if any kept path is a child of this path, we skip deleting parent entirely
  for keepPath, _ in pairs(keeps) do
    if string.sub(path, 1, #keepPath) == keepPath then
      return true
    end
    if string.sub(keepPath, 1, #path) == path and (string.len(keepPath) > string.len(path)) then
      return true
    end
  end
  return false
end

local function listTopLevelDeletions(keeps)
  local toDelete = {}
  for _, name in ipairs(fs.list("/")) do
    local full = "/" .. name
    local drive = fs.getDrive(full)
    if drive == "hdd" then
      if not isKept(full, keeps) then
        table.insert(toDelete, full)
      end
    else
      -- Skip ROM and mounted disks
    end
  end
  table.sort(toDelete)
  return toDelete
end

local function deletePath(path)
  if fs.isReadOnly(path) then return false, "read-only" end
  if not fs.exists(path) then return true end
  local ok, err = pcall(function()
    fs.delete(path)
  end)
  if not ok then return false, err end
  return true
end

local function confirmPrompt(summary)
  print("")
  print(summary)
  print("Type 'RESET' to confirm, or anything else to cancel.")
  write("> ")
  local input = read()
  return input == "RESET"
end

-- capture program arguments at the top-level chunk (varargs allowed here)
local topArgs = {...}

local function main(tArgs)
  local opts = parseArgs(tArgs)
  if opts.help then
    printUsage()
    return
  end

  term.clear()
  term.setCursorPos(1, 1)
  print("Reset Computer / Turtle")
  print("This will wipe the local HDD (excluding ROM and mounted disks).")

  local toDelete = listTopLevelDeletions(opts.keeps)
  if #toDelete == 0 then
    print("Nothing to delete (local HDD already clean or everything kept).")
    return
  end

  print("")
  print("Targets:")
  for _, p in ipairs(toDelete) do
    print("  " .. p)
  end

  if opts.dryRun then
    print("")
    print("Dry-run: No changes made.")
    return
  end

  local proceed = opts.assumeYes
  if not proceed then
    proceed = confirmPrompt("About to delete " .. tostring(#toDelete) .. " top-level item(s).")
  end
  if not proceed then
    print("Cancelled.")
    return
  end

  print("")
  print("Deleting...")
  local failures = 0
  for _, p in ipairs(toDelete) do
    local ok, err = deletePath(p)
    if ok then
      print("deleted " .. p)
    else
      print("FAILED  " .. p .. " (" .. tostring(err) .. ")")
      failures = failures + 1
    end
  end

  if opts.clearLabel then
    local ok, _ = pcall(function()
      if os.setComputerLabel then
        os.setComputerLabel(nil)
      end
    end)
    if ok then
      print("Cleared computer label.")
    end
  end

  print("")
  if failures == 0 then
    print("Reset complete.")
  else
    print("Reset complete with " .. tostring(failures) .. " failure(s).")
  end

  if not opts.noReboot then
    print("Rebooting in 2 seconds...")
    sleep(2)
    os.reboot()
  else
    print("Skipping reboot as requested.")
  end
end

main(topArgs)


