-- Bulk updater for CC-Tweaked scripts
-- Overwrites local scripts with the latest from GitHub
-- Usage: run: update

local BASE = 'https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/'

local manifest = {
    ["programs/perlytiara/BigBaemingGamers"] = {
        -- client
        "client/client-bomb.lua",
        "client/client-dig.lua",
        "client/client-quarry.lua",
        "client/client.lua",
        -- farm
        "farm/cactus-farm.lua",
        "farm/harvest_0.lua",
        "farm/harvest_1.lua",
        -- phone
        "phone/phone-app-mine.lua",
        "phone/phone-bombing.lua",
        -- server
        "server/server-phone.lua",
        -- tasks
        "tasks/quarry-miner.lua",
        "tasks/simple-quarry.lua",
        -- tnt
        "tnt/tnt-deployer.lua",
        "tnt/tnt-igniter.lua",
        -- update helpers
        "update/update_bamboo.lua",
        "update/update_dispense.lua",
        "update/update_lift.lua",
        "update/update_pos.lua",
        -- utils
        "utils/block-placer.lua",
        "utils/detectids.lua",
        "utils/item-counter.lua",
        "utils/lava-refueler.lua",
        "utils/ore-keeper.lua",
        "utils/ractor.lua",
        "utils/refuel-test.lua",
        "utils/upward-quarry-test.lua",
        -- loader and updater aliases
        "@load.lua",
        "@update.lua",
        "load.lua",
        "update.lua",
    },
    ["programs/perlytiara/BigBaemingGamers/@gps"] = {
        -- @gps scripts
        "@gps/gps.lua",
        "@gps/gps-host.lua",
    },
}

local function ensureDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

local function ensureParentDir(localPath)
    local parent = string.match(localPath, "(.+)/[^/]+$")
    if parent then ensureDir(parent) end
end

local function fetch(remotePath)
    local url = BASE .. remotePath .. '?breaker=' .. tostring(math.random(0, 999999))
    local res, err = http.get(url)
    if not res then
        print('ERROR: http.get failed for ' .. remotePath .. ' - ' .. tostring(err))
        return false, nil
    end
    local code = res.readAll()
    res.close()
    return true, code
end

local function writeFile(path, contents)
    local handle = fs.open(path, 'w')
    handle.write(contents)
    handle.close()
end

local function readFile(path)
    if not fs.exists(path) then return '' end
    local h = fs.open(path, 'r')
    local c = h.readAll()
    h.close()
    return c or ''
end

local function bytesDiff(a, b)
    return string.len(b) - string.len(a)
end

local function progressBar(current, total, label)
    local width = 28
    local filled = math.floor((current / total) * width)
    local bar = string.rep('#', filled) .. string.rep('-', width - filled)
    print(string.format('[%s] %d/%d %s', bar, current, total, label or ''))
end

local function removeStale(localDir, keepSet)
    if not fs.exists(localDir) then return end
    local function walk(dir, relPrefix)
        local items = fs.list(dir)
        for i = 1, #items, 1 do
            local name = items[i]
            local full = dir .. '/' .. name
            local relPath = (relPrefix ~= '' and (relPrefix .. '/' .. name)) or name
            if fs.isDir(full) then
                walk(full, relPath)
                -- remove empty dir
                if #fs.list(full) == 0 then fs.delete(full) end
            else
                -- Do not delete the loader/updater themselves at root
                if relPath ~= 'load.lua' and relPath ~= 'update.lua' and relPath ~= '@load.lua' and relPath ~= '@update.lua' and not keepSet[relPath] then
                    fs.delete(full)
                    print('Removed stale: ' .. full)
                end
            end
        end
    end
    walk(localDir, '')
end

local function updateDir(dir, files)
    local updated, same = 0, 0
    local localDir = '/' .. dir
    ensureDir(localDir)

    local keep = {}
    for i = 1, #files, 1 do keep[files[i]] = true end

    local total = #files
    for i = 1, #files, 1 do
        local fname = files[i]
        local remotePath = dir .. '/' .. fname
        local localPath = localDir .. '/' .. fname
        local ok, code = fetch(remotePath)
        if ok and code then
            local old = readFile(localPath)
            if old == code then
                same = same + 1
            else
                ensureParentDir(localPath)
                writeFile(localPath, code)
                local diff = bytesDiff(old, code)
                local change = (diff >= 0 and (tostring(math.abs(diff)) .. ' bytes added')) or (tostring(math.abs(diff)) .. ' bytes removed')
                print('Updated: ' .. localPath .. ' (' .. change .. ')')
                updated = updated + 1
            end
        end
        progressBar(i, total, fname)
        sleep(0)
    end

    removeStale(localDir, keep)
    print(string.format('Done. Updated %d, unchanged %d.', updated, same))
end

local function promptSelect(options)
    for i = 1, #options, 1 do
        print(string.format('%d) %s', i, options[i]))
    end
    io.write('Select number: ')
    local choice = read()
    local idx = tonumber(choice)
    if idx and idx >= 1 and idx <= #options then
        return idx
    end
    return nil
end

local function showMenu()
    print('== Update Menu ==')
    print('1) Auto update all (clean stale)')
    print('2) Update a single file')
    print('3) Remove a local file')
    print('4) Exit')
    io.write('Choose: ')
    local ch = read()
    return tonumber(ch)
end

local function updateAll()
    for dir, files in pairs(manifest) do
        updateDir(dir, files)
    end
end

local function updateSingle()
    local dirs = {}
    for d, _ in pairs(manifest) do table.insert(dirs, d) end
    print('Select directory:')
    local dirIdx = promptSelect(dirs)
    if not dirIdx then print('Invalid selection') return end
    local dir = dirs[dirIdx]
    local files = manifest[dir]
    print('Select file to update:')
    local idx = promptSelect(files)
    if not idx then print('Invalid selection') return end
    updateDir(dir, { files[idx] })
end

local function removeOne()
    local dirs = {}
    for d, _ in pairs(manifest) do table.insert(dirs, d) end
    print('Select directory:')
    local dirIdx = promptSelect(dirs)
    if not dirIdx then print('Invalid selection') return end
    local dir = dirs[dirIdx]
    local files = manifest[dir]
    print('Select file to remove locally:')
    local idx = promptSelect(files)
    if not idx then print('Invalid selection') return end
    local localDir = '/' .. dir
    local localPath = localDir .. '/' .. files[idx]
    if fs.exists(localPath) then
        fs.delete(localPath)
        print('Removed: ' .. localPath)
    else
        print('Not found: ' .. localPath)
    end
end

if not http then
    print('ERROR: http API not available. Enable in mod config.')
else
    if #arg >= 1 then
        -- CLI usage:
        -- update all | update <filename> | rm <filename>
        local cmd = tostring(arg[1])
        if cmd == 'all' then
            updateAll()
        elseif cmd == 'rm' and arg[2] then
            local target = tostring(arg[2])
            local found = false
            local foundDir = nil
            for dir, files in pairs(manifest) do
                for i = 1, #files, 1 do
                    if files[i] == target then
                        found = true
                        foundDir = dir
                        break
                    end
                end
                if found then break end
            end
            if found and foundDir then
                local localDir = '/' .. foundDir
                local localPath = localDir .. '/' .. target
                if fs.exists(localPath) then fs.delete(localPath) print('Removed: ' .. localPath) else print('Not found: ' .. localPath) end
            else
                print('Unknown file: ' .. target)
            end
        else
            -- assume single-file update by name
            local target = cmd
            local found = false
            local foundDir = nil
            for dir, files in pairs(manifest) do
                for i = 1, #files, 1 do
                    if files[i] == target then
                        found = true
                        foundDir = dir
                        break
                    end
                end
                if found then break end
            end
            if found and foundDir then updateDir(foundDir, { target }) else print('Unknown file: ' .. target) end
        end
    else
        while true do
            local ch = showMenu()
            if ch == 1 then
                updateAll()
            elseif ch == 2 then
                updateSingle()
            elseif ch == 3 then
                removeOne()
            else
                break
            end
        end
    end
end