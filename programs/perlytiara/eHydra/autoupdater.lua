-- eHydra Auto-Updater System
-- Downloads and installs programs from GitHub raw links
-- Usage: autoupdater <github_raw_url> <local_filename>

local args = {...}

if #args < 2 then
    print("Usage: autoupdater <github_raw_url> <local_filename>")
    print("Example: autoupdater https://raw.githubusercontent.com/user/repo/main/file.lua my-program")
    return
end

local url = args[1]
local filename = args[2]
local programsPath = "programs/" .. filename .. ".lua"

-- Ensure programs directory exists
if not fs.exists("programs") then
    fs.makeDir("programs")
end

print("eHydra Auto-Updater v1.0")
print("========================")
print("URL: " .. url)
print("Target: " .. programsPath)
print()

-- Delete existing file if it exists
if fs.exists(programsPath) then
    print("Removing existing file...")
    fs.delete(programsPath)
end

-- Download the file
print("Downloading...")
local response = http.get(url)

if not response then
    print("Error: Failed to download from " .. url)
    print("Check your internet connection and URL")
    return
end

print("Download successful!")

-- Write the file
local file = fs.open(programsPath, "w")
if not file then
    print("Error: Could not create file " .. programsPath)
    response.close()
    return
end

file.write(response.readAll())
file.close()
response.close()

print("File saved to: " .. programsPath)
print("Installation complete!")

-- Make file executable if it's a startup file
if filename == "startup" then
    print("Setting up startup file...")
end

print()
print("You can now run: " .. filename)
