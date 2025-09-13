-- Bulk loader for CC-Tweaked scripts
-- Downloads scripts from GitHub into matching local folders if missing
-- Usage on turtle/computer:
--   1) Ensure http is enabled in CC config
--   2) run: load (after saving this file as load)

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

local function loadManifest()
    local downloaded = 0
    local skipped = 0

    for dir, files in pairs(manifest) do
        local localDir = '/' .. dir
        ensureDir(localDir)
        for i = 1, #files, 1 do
            local fname = files[i]
            local remotePath = dir .. '/' .. fname
            local localPath = localDir .. '/' .. fname

            if fs.exists(localPath) then
                skipped = skipped + 1
            else
                if downloadFile(remotePath, localPath) then
                    downloaded = downloaded + 1
                    print('Downloaded: ' .. localPath)
                end
            end
        end
    end

    print(string.format('Done. Downloaded %d, skipped %d (already present).', downloaded, skipped))
end

if not http then
    print('ERROR: http API not available. Enable in mod config.')
else
    loadManifest()
end


