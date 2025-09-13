-- Bulk updater for CC-Tweaked scripts
-- Overwrites local scripts with the latest from GitHub
-- Usage: run: update

local BASE = 'https://raw.githubusercontent.com/perlytiara/CC-Tweaked-TurtsAndComputers/refs/heads/main/'

local manifest = {
    ["programs/BigGamingGamers"] = {
        "block-placer.lua",
        "cactus-farm.lua",
        "client-bomb.lua",
        "client-dig.lua",
        "client-quarry.lua",
        "client.lua",
        "detectids.lua",
        "harvest_0.lua",
        "harvest_1.lua",
        "item-counter.lua",
        "lava-refueler.lua",
        "ore-keeper.lua",
        "phone-app-mine.lua",
        "phone-bombing.lua",
        "phone-server.lua",
        "quarry-miner.lua",
        "ractor.lua",
        "refuel-test.lua",
        "simple-quarry.lua",
        "tnt-deployer.lua",
        "tnt-igniter.lua",
        "update_bamboo.lua",
        "update_dispense.lua",
        "update_lift.lua",
        "update_pos.lua",
        "upward-quarry-test.lua",
    },
    ["programs/Michael-Reeves808"] = {
        "bamboo.lua",
        "harvest.lua",
        "lift.lua",
        "pos.lua",
    },
}

local function ensureDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
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

local function updateAll()
    local updated, same = 0, 0
    for dir, files in pairs(manifest) do
        local localDir = '/' .. dir
        ensureDir(localDir)
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
                    writeFile(localPath, code)
                    local diff = bytesDiff(old, code)
                    local change = (diff >= 0 and (tostring(math.abs(diff)) .. ' bytes added')) or (tostring(math.abs(diff)) .. ' bytes removed')
                    print('Updated: ' .. localPath .. ' (' .. change .. ')')
                    updated = updated + 1
                end
            end
        end
    end
    print(string.format('Done. Updated %d, unchanged %d.', updated, same))
end

if not http then
    print('ERROR: http API not available. Enable in mod config.')
else
    updateAll()
end


