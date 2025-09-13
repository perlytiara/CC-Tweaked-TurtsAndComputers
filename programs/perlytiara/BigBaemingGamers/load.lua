-- Bulk loader for CC-Tweaked scripts
-- Downloads scripts from GitHub into matching local folders if missing
-- Usage on turtle/computer:
--   1) Ensure http is enabled in CC config
--   2) run: load (after saving this file as load)

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
        "@gps/gps-client.lua",
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

local function downloadFile(remotePath, localPath)
    local url = BASE .. remotePath .. '?breaker=' .. tostring(math.random(0, 999999))
    local res, err = http.get(url)
    if not res then
        print('ERROR: http.get failed for ' .. remotePath .. ' - ' .. tostring(err))
        return false
    end
    local code = res.readAll()
    res.close()

    local handle = fs.open(localPath, 'w')
    handle.write(code)
    handle.close()
    return true
end

local function loadFiles(dir, files)
    local downloaded = 0
    local skipped = 0
    local localDir = '/' .. dir
    ensureDir(localDir)

    for i = 1, #files, 1 do
        local fname = files[i]
        local remotePath = dir .. '/' .. fname
        local localPath = localDir .. '/' .. fname
        ensureParentDir(localPath)
        if fs.exists(localPath) then
            skipped = skipped + 1
        else
            if downloadFile(remotePath, localPath) then
                downloaded = downloaded + 1
                print('Downloaded: ' .. localPath)
            end
        end
    end

    print(string.format('Done. Downloaded %d, skipped %d (already present).', downloaded, skipped))
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
    print('== Load Menu ==')
    print('1) Load all missing (BigBaemingGamers)')
    print('2) Load a single file')
    print('3) Exit')
    io.write('Choose: ')
    local ch = read()
    return tonumber(ch)
end

local function loadAll()
    for dir, files in pairs(manifest) do
        loadFiles(dir, files)
    end
end

local function loadSingle()
    -- Select directory first
    local dirs = {}
    for d, _ in pairs(manifest) do table.insert(dirs, d) end
    print('Select directory:')
    local dirIdx = promptSelect(dirs)
    if not dirIdx then
        print('Invalid selection')
        return
    end
    local dir = dirs[dirIdx]
    local files = manifest[dir]
    print('Select a file to load:')
    local idx = promptSelect(files)
    if not idx then
        print('Invalid selection')
        return
    end
    loadFiles(dir, { files[idx] })
end

if not http then
    print('ERROR: http API not available. Enable in mod config.')
else
    if #arg >= 1 then
        -- CLI usage: load <filename>|all
        local target = tostring(arg[1])
        if target == 'all' then
            loadAll()
        else
            local found = false
            for dir, files in pairs(manifest) do
                for i = 1, #files, 1 do
                    if files[i] == target then
                        loadFiles(dir, { target })
                        found = true
                        break
                    end
                end
                if found then break end
            end
            if not found then
                print('Unknown file: ' .. target)
            end
        end
    else
        while true do
            local ch = showMenu()
            if ch == 1 then
                loadAll()
            elseif ch == 2 then
                loadSingle()
            else
                break
            end
        end
    end
end
