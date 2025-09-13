-- Husbandry Turtle - General Husbandry Utility
-- Requirements: CC:Tweaked turtle with Advanced Peripherals Husbandry Automata upgrade
-- Provides a guided text UI for common actions: search, inspect, feed/use item, capture/release, breeding

local function supportsColor()
	return term.isColor and term.isColor()
end

local function clearScreen()
	term.clear()
	term.setCursorPos(1, 1)
end

local function writeCentered(text)
	local w, _ = term.getSize()
	local x = math.max(1, math.floor((w - #text) / 2) + 1)
	term.setCursorPos(x, select(2, term.getCursorPos()))
	print(text)
end

local function banner()
	if supportsColor() then term.setTextColor(colors.cyan) end
	writeCentered("==============================")
	writeCentered(" Husbandry Turtle - Assistant ")
	writeCentered("==============================")
	if supportsColor() then term.setTextColor(colors.white) end
	print("")
end

local function prompt(promptText)
	io.write(promptText .. " ")
	return read()
end

local function waitForEnter(msg)
	msg = msg or "Press Enter to continue"
	io.write(msg)
	read()
end

local function confirm(question, defaultYes)
	local def = defaultYes and "Y/n" or "y/N"
	while true do
		local ans = string.lower((prompt(string.format("%s [%s]", question, def)) or ""):gsub("%s+", ""))
		if ans == "" then return defaultYes end
		if ans == "y" or ans == "yes" then return true end
		if ans == "n" or ans == "no" then return false end
		print("Please answer y or n.")
	end
end

-- Peripheral detection (try multiple known names)
local function findHusbandryPeripheral()
	local candidates = {
		"husbandry_automata", -- snake_case variant
		"husbandryAutomata",  -- camelCase variant from docs
		"weak_automata",      -- fallback (older core)
		"automata"            -- very old/other name
	}
	for _, name in ipairs(candidates) do
		local p = peripheral.find(name)
		if p then return p, name end
	end
	return nil, nil
end

-- Inventory helpers
local function getInventorySnapshot()
	local snapshot = {}
	for slot = 1, 16 do
		local detail = turtle.getItemDetail(slot)
		if detail then
			snapshot[#snapshot + 1] = {
				slot = slot,
				name = detail.name,
				count = detail.count or turtle.getItemCount(slot),
				displayName = detail.displayName or detail.name,
			}
		end
	end
	return snapshot
end

local function printInventory(snapshot)
	print("Inventory:")
	if #snapshot == 0 then
		print("  (empty)")
		return
	end
	for _, item in ipairs(snapshot) do
		print(string.format("  [%2d] x%-3d %s (%s)", item.slot, item.count, item.displayName, item.name))
	end
end

local function findPreferredItemSlot(preferredNames)
	if not preferredNames or #preferredNames == 0 then return nil end
	local snapshot = getInventorySnapshot()
	local lowered = {}
	for _, n in ipairs(preferredNames) do lowered[#lowered + 1] = string.lower(n) end
	for _, item in ipairs(snapshot) do
		local lname = string.lower(item.name .. " " .. item.displayName)
		for _, key in ipairs(lowered) do
			if string.find(lname, key, 1, true) then
				return item.slot, item
			end
		end
	end
	return nil
end

local function promptSelectSlot(preferredNames)
	local autoSlot, autoItem = findPreferredItemSlot(preferredNames or {})
	local snapshot = getInventorySnapshot()
	printInventory(snapshot)
	if autoSlot then
		print(string.format("Suggested slot [%d]: %s x%d", autoSlot, autoItem.displayName, autoItem.count))
	end
	while true do
		local ans = prompt("Enter slot number (1-16) or leave empty to use suggestion")
		ans = (ans or ""):gsub("%s+", "")
		if ans == "" and autoSlot then return autoSlot end
		local n = tonumber(ans)
		if n and n >= 1 and n <= 16 then return n end
		print("Invalid slot. Please enter a number 1-16.")
	end
end

-- Action handlers
local function actionSearch(automata)
	print("Scanning for nearby animals...")
	local result, err = automata.searchAnimals()
	if not result then
		print("Error: " .. tostring(err))
		return
	end
	if #result == 0 then
		print("No animals detected nearby.")
		return
	end
	print(string.format("Found %d animals:", #result))
	for i, animal in ipairs(result) do
		-- animal fields can vary; show common ones defensively
		local species = tostring(animal.species or animal.name or animal.id or "unknown")
		local pos = animal.position or {}
		local dx = tonumber(pos.x or 0)
		local dy = tonumber(pos.y or 0)
		local dz = tonumber(pos.z or 0)
		print(string.format("  %2d) %s at (%d,%d,%d)", i, species, dx, dy, dz))
	end
end

local function actionInspect(automata)
	print("Inspecting animal in front...")
	local info, err = automata.inspectAnimal()
	if not info then
		print("Error: " .. tostring(err))
		return
	end
	print("Info:")
	for k, v in pairs(info) do
		local vt = type(v)
		if vt == "table" then
			local parts = {}
			for k2, v2 in pairs(v) do parts[#parts + 1] = tostring(k2) .. ":" .. tostring(v2) end
			print("  " .. tostring(k) .. ": { " .. table.concat(parts, ", ") .. " }")
		else
			print("  " .. tostring(k) .. ": " .. tostring(v))
		end
	end
end

local function actionUseOnAnimal(automata, preferredNames)
	print("Use selected item on animal in front")
	local slot = promptSelectSlot(preferredNames)
	turtle.select(slot)
	local ok, resultOrErr = automata.useOnAnimal()
	if ok then
		print("Interaction success: " .. tostring(resultOrErr))
	else
		print("Interaction failed: " .. tostring(resultOrErr))
	end
end

local function actionCapture(automata)
	print("Capturing animal in front...")
	local ok, err = automata.captureAnimal()
	if ok then
		print("Captured.")
	else
		print("Failed to capture: " .. tostring(err))
	end
end

local function actionRelease(automata)
	print("Releasing captured animal...")
	local ok, err = automata.releaseAnimal()
	if ok then
		print("Released.")
	else
		print("Failed to release: " .. tostring(err))
	end
end

local function actionGetCapturedInfo(automata)
	local info, err = automata.getCapturedAnimal()
	if not info then
		print("No captured animal or error: " .. tostring(err))
		return
	end
	print("Captured Animal:")
	for k, v in pairs(info) do
		print("  " .. tostring(k) .. ": " .. tostring(v))
	end
end

-- Breeding workflow
local BREEDING_MAPPINGS = {
	Cow = {"wheat"},
	Sheep = {"wheat"},
	Pig = {"carrot", "potato", "beetroot"},
	Chicken = {"seed"},
	Wolf = {"meat", "beef", "porkchop", "mutton", "chicken"},
	Cat = {"fish", "cod", "salmon"},
	Fox = {"sweet_berries"},
	Rabbit = {"dandelion", "carrot"},
}

local function actionBreedingWorkflow(automata)
	print("Guided breeding workflow")
	print("Note: Position the turtle directly in front of the animal before feeding.")
	print("")
	print("Known species presets:")
	local speciesList = {}
	for species, _ in pairs(BREEDING_MAPPINGS) do speciesList[#speciesList + 1] = species end
	table.sort(speciesList)
	for i, s in ipairs(speciesList) do
		print(string.format("  %2d) %s", i, s))
	end
	print("  0) Other/Unknown")

	local choice = tonumber(prompt("Choose species preset number")) or 0
	local chosenSpecies = speciesList[choice] or "Other"
	local preferred = BREEDING_MAPPINGS[chosenSpecies] or {}
	if #preferred > 0 then
		print("Preferred breeding items: " .. table.concat(preferred, ", "))
	else
		print("No preset. You will choose an item slot manually.")
	end

	local pairsToBreed = tonumber(prompt("How many pairs to breed? (each pair makes one baby)")) or 1
	if pairsToBreed < 1 then pairsToBreed = 1 end

	for i = 1, pairsToBreed do
		print("")
		print(string.format("Pair %d/%d", i, pairsToBreed))
		-- First mate
		print("Bring first adult in front of the turtle.")
		waitForEnter("Press Enter when ready...")
		local slotA = promptSelectSlot(preferred)
		turtle.select(slotA)
		local okA, msgA = automata.useOnAnimal()
		if not okA then
			print("Feeding first animal failed: " .. tostring(msgA))
			if not confirm("Continue to next pair?", true) then return end
		else
			print("First animal fed: " .. tostring(msgA))
		end

		-- Second mate
		print("Bring second adult in front of the turtle.")
		waitForEnter("Press Enter when ready...")
		local slotB = slotA -- reuse same item by default
		-- Allow change if desired
		if confirm("Use same slot for second mate?", true) then
			turtle.select(slotB)
		else
			slotB = promptSelectSlot(preferred)
			turtle.select(slotB)
		end
		local okB, msgB = automata.useOnAnimal()
		if not okB then
			print("Feeding second animal failed: " .. tostring(msgB))
			if not confirm("Continue to next pair?", true) then return end
		else
			print("Second animal fed: " .. tostring(msgB))
		end

		print("If both were adults and valid mates, a baby should be created shortly.")
	end

	print("Breeding workflow complete.")
end

-- Main menu
local function main()
	clearScreen()
	banner()
	if not turtle then
		print("This program must run on a turtle.")
		return
	end
	local automata, pname = findHusbandryPeripheral()
	if not automata then
		print("Could not find Husbandry Automata peripheral. Make sure the upgrade is installed.")
		print("Tried names: husbandry_automata, husbandryAutomata, weak_automata, automata")
		return
	end
	print("Detected peripheral: " .. tostring(pname))
	print("")

	while true do
		banner()
		print("Choose an action:")
		print("  1) Search nearby animals")
		print("  2) Inspect animal in front")
		print("  3) Use selected item on animal in front")
		print("  4) Capture animal in front")
		print("  5) Release captured animal")
		print("  6) Show captured animal info")
		print("  7) Guided breeding workflow")
		print("  8) Show inventory and select slot")
		print("  9) Exit")
		local choice = tonumber(prompt("Enter choice number")) or -1
		clearScreen()
		banner()
		if choice == 1 then
			actionSearch(automata)
			waitForEnter()
		elseif choice == 2 then
			actionInspect(automata)
			waitForEnter()
		elseif choice == 3 then
			-- Ask for quick presets for common species
			print("Quick presets: 1) Wheat  2) Seeds  3) Carrot  4) Potato  5) None")
			local p = tonumber(prompt("Choose preset")) or 5
			local pref = ({
				[1] = {"wheat"},
				[2] = {"seed"},
				[3] = {"carrot"},
				[4] = {"potato"},
				[5] = {},
			})[p] or {}
			actionUseOnAnimal(automata, pref)
			waitForEnter()
		elseif choice == 4 then
			actionCapture(automata)
			waitForEnter()
		elseif choice == 5 then
			actionRelease(automata)
			waitForEnter()
		elseif choice == 6 then
			actionGetCapturedInfo(automata)
			waitForEnter()
		elseif choice == 7 then
			actionBreedingWorkflow(automata)
			waitForEnter()
		elseif choice == 8 then
			local snapshot = getInventorySnapshot()
			printInventory(snapshot)
			local _ = promptSelectSlot({})
			print("Slot selected. (No action performed)")
			waitForEnter()
		elseif choice == 9 then
			print("Goodbye!")
			return
		else
			print("Invalid choice.")
			waitForEnter()
		end
		clearScreen()
	end
end

-- Entry
local ok, err = pcall(main)
if not ok then
	print("Unexpected error: " .. tostring(err))
end



