-- Cow Auto-Breeder (Perimeter Walker)
-- Requirements: CC:Tweaked turtle with Advanced Peripherals Husbandry Automata upgrade
-- Place a chest directly behind the turtle at start for refuel/restock/deposit

-- ===================== UI HELPERS =====================
local function supportsColor()
	return term.isColor and term.isColor()
end

local function clearScreen()
	term.clear()
	term.setCursorPos(1, 1)
end

local function banner()
	if supportsColor() then term.setTextColor(colors.lime) end
	print("==============================")
	print(" Cow Auto-Breeder - Perimeter ")
	print("==============================")
	if supportsColor() then term.setTextColor(colors.white) end
end

local function prompt(text, default)
	io.write(text)
	if default ~= nil then io.write(" [" .. tostring(default) .. "]") end
	io.write(": ")
	local ans = read()
	ans = ans and ans:gsub("^%s+", ""):gsub("%s+$", "") or ""
	if ans == "" and default ~= nil then return default end
	return ans
end

local function waitEnter(msg)
	io.write(msg or "Press Enter to continue...")
	read()
end

-- ===================== PERIPHERAL =====================
local function findHusbandryPeripheral()
	local candidates = {"husbandry_automata", "husbandryAutomata", "weak_automata", "automata"}
	for _, name in ipairs(candidates) do
		local p = peripheral.find(name)
		if p then return p, name end
	end
	return nil, nil
end

-- ===================== CONFIG =====================
local Config = {
	fenceSampleSlot = 1,
	cooldownSeconds = 300,
	maxCows = 24,
	cullingEnabled = true,
	targetWheat = 64,
	minFuel = 1000,
}

local function runSetup()
	clearScreen()
	banner()
	print("Setup:")
	print("- Ensure a chest is placed DIRECTLY BEHIND the turtle.")
	print("- Put wheat and coal/charcoal into that chest for restocking/refuel.")
	print("- Place the turtle INSIDE the pen, facing along the fence so the fence is on its RIGHT.")
	print("")
	print("Provide a sample of the pen's fence block in an inventory slot.")
	Config.fenceSampleSlot = tonumber(prompt("Which slot holds the fence sample?", tostring(Config.fenceSampleSlot))) or Config.fenceSampleSlot
	Config.maxCows = tonumber(prompt("Max adult cows to keep (cull if above)", tostring(Config.maxCows))) or Config.maxCows
	Config.cullingEnabled = string.lower(prompt("Enable culling if above max? (yes/no)", Config.cullingEnabled and "yes" or "no")) == "yes"
	local mins = tonumber(prompt("Minutes between breeding cycles", tostring(math.floor(Config.cooldownSeconds / 60)))) or (Config.cooldownSeconds / 60)
	Config.cooldownSeconds = math.floor(mins * 60)
	Config.targetWheat = tonumber(prompt("Target wheat count to keep in inventory", tostring(Config.targetWheat))) or Config.targetWheat
	Config.minFuel = tonumber(prompt("Minimum fuel level to maintain", tostring(Config.minFuel))) or Config.minFuel
	print("")
	print("Setup complete. Starting...")
	os.sleep(1)
end

-- ===================== INVENTORY =====================
local function getItemDetail(slot)
	local d = turtle.getItemDetail(slot)
	if d then
		return {
			slot = slot,
			name = d.name,
			displayName = d.displayName or d.name,
			count = d.count or turtle.getItemCount(slot),
		}
	end
	return nil
end

local function eachItem()
	local i = 0
	return function()
		i = i + 1
		while i <= 16 do
			local d = getItemDetail(i)
			if d then return d end
			i = i + 1
		end
		return nil
	end
end

local function itemMatches(detail, keywords)
	local lname = string.lower((detail.name or "") .. " " .. (detail.displayName or ""))
	for _, key in ipairs(keywords) do
		if string.find(lname, string.lower(key), 1, true) then return true end
	end
	return false
end

local function selectItem(keywords)
	for item in eachItem() do
		if itemMatches(item, keywords) then
			turtle.select(item.slot)
			return true, item
		end
	end
	return false
end

local function countItems(keywords)
	local total = 0
	for item in eachItem() do
		if itemMatches(item, keywords) then total = total + item.count end
	end
	return total
end

local function dropAllExcept(keepKeywords)
	-- Face chest assumed in front
	for slot = 1, 16 do
		local d = getItemDetail(slot)
		if d then
			local keep = itemMatches(d, keepKeywords)
			if not keep then
				turtle.select(slot)
				turtle.drop()
			end
		end
	end
end

local function suckUntil(predicate, maxActions)
	maxActions = maxActions or 64
	local actions = 0
	while actions < maxActions do
		if predicate() then return true end
		if not turtle.suck() then return predicate() end
		actions = actions + 1
	end
	return predicate()
end

local COAL_KEYS = {"coal", "charcoal"}
local WHEAT_KEYS = {"wheat"}
local SWORD_KEYS = {"sword"}

local function faceChest(fn)
	-- Turn around, do fn(), turn back
	turtle.turnLeft(); turtle.turnLeft()
	local ok, err = pcall(fn)
	turtle.turnLeft(); turtle.turnLeft()
	if not ok then error(err) end
end

local function ensureFuel(minFuel)
	local lvl = turtle.getFuelLevel()
	if lvl == "unlimited" or lvl == math.huge then return true end
	if lvl >= minFuel then return true end
	faceChest(function()
		-- Try to refuel using existing coal first
		if not selectItem(COAL_KEYS) then
			-- Pull from chest
			suckUntil(function() return selectItem(COAL_KEYS) end, 128)
		end
		if selectItem(COAL_KEYS) then
			-- Refuel until target
			for _ = 1, 16 do
				local before = turtle.getFuelLevel()
				turtle.refuel(1)
				if turtle.getFuelLevel() >= minFuel then break end
				if turtle.getFuelLevel() == before then break end
			end
		end
		-- Drop back non-keep
		dropAllExcept({"wheat", "coal", "charcoal"})
	end)
	return turtle.getFuelLevel() == "unlimited" or turtle.getFuelLevel() >= minFuel
end

local function ensureWheat(targetCount)
	if countItems(WHEAT_KEYS) >= targetCount then return true end
	faceChest(function()
		-- pull until we reach target or chest empty
		suckUntil(function() return countItems(WHEAT_KEYS) >= targetCount end, 256)
		-- drop back everything except wheat and coal
		dropAllExcept({"wheat", "coal", "charcoal"})
	end)
	return countItems(WHEAT_KEYS) >= math.min(1, targetCount)
end

local function depositNonKeep()
	faceChest(function()
		dropAllExcept({"wheat", "coal", "charcoal"})
	end)
end

-- ===================== MOVEMENT / PERIMETER =====================
local heading = 0 -- 0=N,1=E,2=S,3=W
local startHeading = 0
local posX, posZ = 0, 0
local moveHistory = {}

local function setHeading(h)
	heading = (h % 4 + 4) % 4
end

local function turnRight()
	turtle.turnRight()
	setHeading(heading + 1)
	moveHistory[#moveHistory + 1] = "R"
end

local function turnLeft()
	turtle.turnLeft()
	setHeading(heading - 1)
	moveHistory[#moveHistory + 1] = "L"
end

local function turnRightNoRecord()
	turtle.turnRight()
	setHeading(heading + 1)
end

local function turnLeftNoRecord()
	turtle.turnLeft()
	setHeading(heading - 1)
end

local function forward()
	if turtle.forward() then
		if heading == 0 then posZ = posZ - 1
		elseif heading == 1 then posX = posX + 1
		elseif heading == 2 then posZ = posZ + 1
		else posX = posX - 1 end
		moveHistory[#moveHistory + 1] = "F"
		return true
	end
	return false
end

local function moveBack()
	if turtle.back() then
		if heading == 0 then posZ = posZ + 1
		elseif heading == 1 then posX = posX - 1
		elseif heading == 2 then posZ = posZ - 1
		else posX = posX + 1 end
		moveHistory[#moveHistory + 1] = "B"
		return true
	end
	return false
end

local function resetPose()
	posX, posZ = 0, 0
	startHeading = heading
	moveHistory = {}
end

local fenceName = nil
local function readFenceNameFromSample()
	local d = getItemDetail(Config.fenceSampleSlot)
	if not d then return nil end
	return d.name
end

local function inspectFrontName()
	local ok, data = turtle.inspect()
	if ok and data and data.name then return data.name end
	return nil
end

local function hasFenceRight()
	turnRightNoRecord()
	local name = inspectFrontName()
	turnLeftNoRecord()
	return name == fenceName
end

local function frontBlockedByBlock()
	return turtle.detect()
end

-- Forward declarations for functions referenced before definition
local tryFeedFrontCow
local tryCullFrontCow

local function isFenceAhead()
	if not frontBlockedByBlock() then return false end
	return inspectFrontName() == fenceName
end

local function turnToHeading(target)
	target = (target % 4 + 4) % 4
	local diff = (target - heading) % 4
	if diff == 1 then
		turnRight()
	elseif diff == 2 then
		turnRight(); turnRight()
	elseif diff == 3 then
		turnLeft()
	end
end

local function advanceToWallCurrentHeading(mode)
	local guard = 0
	while not isFenceAhead() and guard < 8192 do
		if mode == "breed" then tryFeedFrontCow() else tryCullFrontCow() end
		local ok, reason = forceForward(mode, 30)
		if not ok and reason == "fence" then break end
		guard = guard + 1
	end
end

-- ===================== ANIMAL INTERACTION =====================
local automata, automataName = nil, nil

local function isCowEntityInfo(info)
	if not info then return false end
	local vals = {
		string.lower(tostring(info.id or "")),
		string.lower(tostring(info.name or "")),
		string.lower(tostring(info.species or "")),
	}
	for _, v in ipairs(vals) do
		if v ~= "" and (v == "minecraft:cow" or v == "cow" or v:find("cow", 1, true)) then return true end
	end
	return false
end

local function isBabyFromInfo(info)
	if not info then return false end
	if info.isBaby == true then return true end
	if type(info.age) == "number" and info.age < 0 then return true end
	if type(info.growingAge) == "number" and info.growingAge < 0 then return true end
	return false
end

tryFeedFrontCow = function()
	local info = select(1, automata.inspectAnimal())
	if not info or not isCowEntityInfo(info) then return false, "no_cow" end
	if isBabyFromInfo(info) then return false, "baby" end
	if not selectItem(WHEAT_KEYS) then return false, "no_wheat" end
	local ok, msg = automata.useOnAnimal()
	return ok or false, msg
end

tryCullFrontCow = function()
	local info = select(1, automata.inspectAnimal())
	if not info or not isCowEntityInfo(info) then return false, "no_cow" end
	if isBabyFromInfo(info) then return false, "baby" end
	-- Attempt a few attacks
	selectItem(SWORD_KEYS)
	local attacked = false
	for _ = 1, 5 do
		if turtle.attack() then attacked = true end
		os.sleep(0.1)
		-- if path clears, break
		if forward() then
			-- stepped into spot; step back to maintain path
			moveBack()
			break
		end
	end
	return attacked, attacked and "attacked" or "blocked"
end

-- Robust movement that forces progress through entities (not blocks)
local function forceForward(mode, maxTries)
    maxTries = maxTries or 30
    if frontBlockedByBlock() and inspectFrontName() == fenceName then
        return false, "fence"
    end
    for i = 1, maxTries do
        if forward() then return true end
        -- entity in front; interact per mode
        if mode == "breed" then
            tryFeedFrontCow()
        else
            tryCullFrontCow()
        end
        os.sleep(0.1)
    end
    return false, "entity_blocked"
end

local function forceBack(maxTries)
    maxTries = maxTries or 20
    for i = 1, maxTries do
        if moveBack() then return true end
        -- fallback: 180 and forward
        turnLeftNoRecord(); turnLeftNoRecord()
        local ok = forward()
        turnLeftNoRecord(); turnLeftNoRecord()
        if ok then return true end
        os.sleep(0.05)
    end
    return false
end

local function countNearbyCows()
	local list = select(1, automata.searchAnimals()) or {}
	local countAdult = 0
	for _, a in ipairs(list) do
		if isCowEntityInfo(a) then
			if not isBabyFromInfo(a) then countAdult = countAdult + 1 end
		end
	end
	return countAdult
end

-- ===================== PERIMETER WALK =====================
local function orientToFenceRight(maxTries)
	maxTries = maxTries or 4
	for _ = 1, maxTries do
		if hasFenceRight() then return true end
		turnRight()
	end
	return false
end

local function handleEntityBlock(mode)
	-- try to feed/attack then attempt to move forward a few times
	if mode == "breed" then tryFeedFrontCow() else tryCullFrontCow() end
	for _ = 1, 6 do
		if forward() then return true end
		os.sleep(0.1)
	end
	return false
end

-- Stable right-hand wall follower around the specified fence
local function perimeterOnce(mode)
	mode = mode or "breed" -- or "cull"
	-- Ensure we start hugging fence on right
	if not orientToFenceRight(8) then
		print("Could not find fence on the right. Adjust turtle position/orientation and press Enter.")
		waitEnter()
		if not orientToFenceRight(8) then return false, "no_fence" end
	end
	resetPose()
	local steps = 0
	local safety = 16000
	while safety > 0 do
		safety = safety - 1
		-- Interact opportunistically if a cow is in front
		if mode == "breed" then tryFeedFrontCow() else tryCullFrontCow() end

		local rightIsFence = hasFenceRight()
		local frontIsBlock = frontBlockedByBlock()
		if not rightIsFence then
			-- no fence on right: turn right and try to go forward
			turnRight()
			if frontBlockedByBlock() then
				-- corner or obstacle, turn left back to continue search
				turnLeft()
			else
				if not forward() then
					-- entity blocking
					handleEntityBlock(mode)
				end
			end
		else
			-- fence is on the right; follow along it
			if frontIsBlock then
				-- turn left around corner
				turnLeft()
			else
				if not forward() then
					-- entity blocking
					handleEntityBlock(mode)
				end
			end
		end
		steps = steps + 1
		-- Loop complete if back to start pose after some movement
		if posX == 0 and posZ == 0 and heading == startHeading and steps > 8 then
			return true
		end
		-- light delay to be friendly
		os.sleep(0.05)
	end
	return false, "safety_exceeded"
end

-- Serpentine traversal within the pen. Returns to home using move history.
local function serpentineOnce(mode)
    mode = mode or "breed"
    resetPose()

    -- Step 1: go straight until first wall in current facing
    local dirFirst = heading
    advanceToWallCurrentHeading(mode)

    -- Step 2: turn right and go to the next wall (corner)
    turnRight()
    local dirSecond = heading
    advanceToWallCurrentHeading(mode)

    -- Define run and lateral directions relative to first/second legs
    local runDir = (dirSecond + 2) % 4      -- opposite of second leg (go away from that wall)
    local lateralDir = (dirFirst + 2) % 4   -- move one block opposite of first leg between runs

    -- Serpentine columns: run to wall, shift 1 laterally, reverse run, repeat
    local flips = 0
    local safety = 20000
    while safety > 0 do
        safety = safety - 1
        -- Run to wall along runDir
        turnToHeading(runDir)
        advanceToWallCurrentHeading(mode)

        -- Shift one block laterally; stop if fence blocks shift
        turnToHeading(lateralDir)
        if isFenceAhead() then break end
        forceForward(mode, 30)

        -- Reverse run direction for next column
        runDir = (runDir + 2) % 4
        flips = flips + 1
        if flips > 8192 then break end
    end

    -- Go home by reversing history
    for i = #moveHistory, 1, -1 do
        local op = moveHistory[i]
        if op == "F" then
            forceBack(15)
        elseif op == "B" then
            forceForward("breed", 15)
        elseif op == "L" then
            turnRightNoRecord()
        elseif op == "R" then
            turnLeftNoRecord()
        end
    end
    moveHistory = {}
    return true
end

-- ===================== MAIN LOOP =====================
local function main()
	if not turtle then
		error("Must run on a turtle")
	end
	automata, automataName = findHusbandryPeripheral()
	if not automata then
		error("Husbandry Automata peripheral not found")
	end
	runSetup()
	fenceName = readFenceNameFromSample()
	if not fenceName then error("Fence sample slot is empty or invalid") end

	-- Initialize pose tracking on demand (perimeterOnce resets pose)

	while true do
		clearScreen(); banner()
		print("Servicing chest and preparing...")
		depositNonKeep()
		ensureWheat(Config.targetWheat)
		ensureFuel(Config.minFuel)

		print("Breeding serpentine pass...")
		local ok, err = serpentineOnce("breed")
		if not ok then print("Traversal error: " .. tostring(err)) end

		-- Wait cooldown BEFORE culling
		local waitSec = Config.cooldownSeconds
		print("Waiting " .. tostring(waitSec) .. "s before next cycle...")
		for s = waitSec, 1, -1 do
			term.setCursorPos(1, 10)
			print(string.format("Next in %ds   ", s))
			os.sleep(1)
		end

		-- Culling pass after waiting
		local count = countNearbyCows()
		print("Detected adult cows: " .. tostring(count))
		if Config.cullingEnabled and count > Config.maxCows then
			print("Culling serpentine pass to target <= " .. tostring(Config.maxCows))
			local safety = 12
			while count > Config.maxCows and safety > 0 do
				local okCull = select(1, serpentineOnce("cull"))
				count = countNearbyCows()
				print("Cows remaining: " .. tostring(count))
				safety = safety - 1
				if not okCull then break end
			end
		end

		print("Depositing drops and refueling/restocking...")
		depositNonKeep()
		ensureFuel(Config.minFuel)
		ensureWheat(Config.targetWheat)
	end
end

local ok, err = pcall(main)
if not ok then
	print("Error: " .. tostring(err))
	warn = warn or print
	warn("Program terminated.")
end


