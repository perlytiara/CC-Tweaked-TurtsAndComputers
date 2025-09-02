-- ==================================================
-- Thank you for using Beni's Farm Script!
-- ==================================================
--------------------------------------------------
-- CONFIGURATION VARIABLES
--------------------------------------------------
local fuelSuckCount = 10         -- Number of fuel items (e.g., coal) to suck at start.
local lowFuelThreshold = fuelSuckCount * 8

--------------------------------------------------
-- GLASS PANE COLOR SETUP
--------------------------------------------------
local args = {...}
local glassColor = args[1] or "green"
local targetGlassPane = "minecraft:" .. glassColor .. "_stained_glass_pane"
--------------------------------------------------
-- CLEAR CONSOLE
term.clear()
term.setCursorPos(1, 1)
--------------------------------------------------
print("Using " .. glassColor .. " stained glass pane for positioning.")

--------------------------------------------------
-- POSITIONING ROUTINE
--------------------------------------------------
local function positionTurtle()
  local positioned = false
  local attemptCounter = 0

  while not positioned do
    attemptCounter = attemptCounter + 1

    local successDown, dataDown = turtle.inspectDown()
    if successDown and dataDown.name == "minecraft:water" then
      local successFront, dataFront = turtle.inspect()
      if successFront and dataFront.name == "minecraft:chest" then
        print("Position OK.")
        positioned = true
      else
        -- If there's water below, but no chest in front, keep trying to move/turn.
        if successFront then
          if dataFront.name == "minecraft:air" then
            turtle.forward()
          elseif dataFront.name == "minecraft:glass" or dataFront.name == "minecraft:glass_pane" then
            turtle.turnLeft()
          elseif dataFront.name == targetGlassPane then
            turtle.down()
          else
            turtle.forward()
          end
        else
          turtle.forward()
        end
      end
    else
      -- No (or wrong) water below; keep searching
      local successFront, dataFront = turtle.inspect()
      if successFront then
        if dataFront.name == "minecraft:air" then
          turtle.forward()
        elseif dataFront.name == "minecraft:glass" or dataFront.name == "minecraft:glass_pane" then
          turtle.turnLeft()
        elseif dataFront.name == targetGlassPane then
          turtle.down()
        else
          turtle.forward()
        end
      else
        turtle.forward()
      end
    end

    -- If we’ve been trying for a while, warn the user.
    if attemptCounter > 20 and not positioned then
      print("WARNING: Turtle is not finding water below + chest in front!")
      print("Ensure your farm setup has:")
      print(" - Still water directly beneath the turtle.")
      print(" - A chest directly in front of the turtle.")
      print(" - The correct color stained glass pane above that chest.")
      print(" - A fuel chest to the right of the turtle if it needs refueling.")
      print("Retrying...")
      sleep(10)
      attemptCounter = 0
    end
  end
end

--------------------------------------------------
-- FUEL CHECK ROUTINE
--------------------------------------------------
local function fuelCheck()
  local fuel = turtle.getFuelLevel()
  if fuel < lowFuelThreshold then
    print("Fuel low (" .. fuel .. "); refueling...")
    turtle.turnRight()   -- Face refuel Ender Chest.
    turtle.suck(fuelSuckCount)
    for slot = 1, 16 do
      turtle.select(slot)
      turtle.refuel()
    end
    turtle.turnLeft()    -- Restore original facing.
  else
    print("Fuel level sufficient (" .. fuel .. ").")
  end
end

--------------------------------------------------
-- DEPOSIT OPERATIONS
--------------------------------------------------
local function depositOperations()
  -- Deposit the entire inventory into the chest in front.
  for slot = 1, 16 do
    turtle.select(slot)
    turtle.drop()
  end
  print("Inventory deposited.")
end

--------------------------------------------------
-- INVENTORY MANAGEMENT HELPERS
--------------------------------------------------
local function isInventoryFull()
  for slot = 1, 16 do
    if turtle.getItemDetail(slot) == nil then
      return false
    end
  end
  return true
end

local function organizeSeeds(cropBlock)
  -- We only organize seeds for wheat and beetroots (which use dedicated slots)
  local seedType, dedicatedSlot
  if cropBlock == "minecraft:wheat" then
    seedType = "minecraft:wheat_seeds"
    dedicatedSlot = 1
  elseif cropBlock == "minecraft:beetroots" then
    seedType = "minecraft:beetroot_seeds"
    dedicatedSlot = 4
  else
    return  -- No organization for carrots or potatoes.
  end

  turtle.select(dedicatedSlot)
  local dedicatedItem = turtle.getItemDetail(dedicatedSlot)
  local space = 0
  if dedicatedItem then
    space = 64 - dedicatedItem.count  -- Assume a stack size of 64.
  else
    space = 64
  end

  for slot = 1, 16 do
    if slot ~= dedicatedSlot then
      turtle.select(slot)
      local detail = turtle.getItemDetail(slot)
      if detail and detail.name == seedType then
        if space > 0 then
          local count = detail.count
          local transferCount = math.min(count, space)
          turtle.transferTo(dedicatedSlot, transferCount)
          turtle.select(dedicatedSlot)
          local newDetail = turtle.getItemDetail(dedicatedSlot)
          if newDetail then
            space = 64 - newDetail.count
          else
            space = 64
          end
        else
          print("Dedicated slot for " .. seedType .. " is full; dropping extra seeds from slot " .. slot)
          turtle.drop()  -- Drop excess seeds.
        end
      end
    end
  end
  turtle.select(dedicatedSlot)
end

--------------------------------------------------
-- ATTEMPT TO PLANT A SPECIFIC CROP
--------------------------------------------------
local function attemptToPlant(cropBlock)
  -- Map the crop block to the seed item and dedicated slot.
  local seedType, dedicatedSlot
  if cropBlock == "minecraft:wheat" then
    seedType = "minecraft:wheat_seeds"
    dedicatedSlot = 1
  elseif cropBlock == "minecraft:carrots" then
    seedType = "minecraft:carrot"
    dedicatedSlot = 2
  elseif cropBlock == "minecraft:potatoes" then
    seedType = "minecraft:potato"
    dedicatedSlot = 3
  elseif cropBlock == "minecraft:beetroots" then
    seedType = "minecraft:beetroot_seeds"
    dedicatedSlot = 4
  else
    -- Default to wheat if unknown.
    seedType = "minecraft:wheat_seeds"
    dedicatedSlot = 1
  end

  -- Check the dedicated slot.
  turtle.select(dedicatedSlot)
  local slotItem = turtle.getItemDetail(dedicatedSlot)
  if slotItem and slotItem.name ~= seedType then
    -- The dedicated slot contains the wrong item; try to move it.
    local emptySlot = nil
    for s = 1, 16 do
      if s ~= dedicatedSlot and not turtle.getItemDetail(s) then
        emptySlot = s
        break
      end
    end
    if emptySlot then
      turtle.transferTo(emptySlot)
    else
      turtle.drop()
    end
  end

  -- If the slot is empty or wrong, search the inventory for the correct seed.
  slotItem = turtle.getItemDetail(dedicatedSlot)
  if not slotItem or slotItem.name ~= seedType then
    local found = false
    for s = 1, 16 do
      if s ~= dedicatedSlot then
        local detail = turtle.getItemDetail(s)
        if detail and detail.name == seedType then
          turtle.select(s)
          turtle.transferTo(dedicatedSlot)
          found = true
          break
        end
      end
    end
    if not found then
      return false
    end
  end

  -- Attempt to plant.
  turtle.select(dedicatedSlot)
  local finalItem = turtle.getItemDetail(dedicatedSlot)
  if finalItem and finalItem.name == seedType and finalItem.count > 0 then
    turtle.placeDown()
    return true
  else
    return false
  end
end

--------------------------------------------------
-- PLANT SEED WITH FALLBACK
--------------------------------------------------
local function plantSeedWithFallback(requestedBlock)
  -- Try the requested crop first.
  if attemptToPlant(requestedBlock) then
    return
  end

  local fallbackOrder = { "minecraft:wheat", "minecraft:carrots", "minecraft:potatoes", "minecraft:beetroots" }
  for _, fallbackBlock in ipairs(fallbackOrder) do
    if fallbackBlock ~= requestedBlock then
      if attemptToPlant(fallbackBlock) then
        print("Planted fallback crop: " .. fallbackBlock)
        return
      end
    end
  end

  print("No viable seeds found; skipping planting.")
end

--------------------------------------------------
-- HELPER: CHECK IF CROP IS MATURE
--------------------------------------------------
local function isCropMature(blockName, age)
  -- Maturity levels:
  -- wheat: 7, carrots: 8, potatoes: 8, beetroots: 3
  if blockName == "minecraft:wheat" then
    return age == 7
  elseif blockName == "minecraft:carrots" then
    return age == 7
  elseif blockName == "minecraft:potatoes" then
    return age == 7
  elseif blockName == "minecraft:beetroots" then
    return age == 3
  end
  return false
end

--------------------------------------------------
-- PLANT GROWTH CHECK ROUTINE
--------------------------------------------------
local function checkPlantGrowth()
  -- Check two adjacent tiles.
  while true do
    turtle.turnLeft()
    local success1, data1 = turtle.inspect()
    local firstOk = true
    if success1 then
      if data1.name == "minecraft:wheat" or data1.name == "minecraft:carrots" or data1.name == "minecraft:potatoes" or data1.name == "minecraft:beetroots" then
        if not isCropMature(data1.name, data1.state.age) then
          firstOk = false
        end
      end
    end

    if not firstOk then
      print("First adjacent crop not fully grown; waiting 5 minutes.")
      turtle.turnRight()  -- Revert orientation.
      sleep(300)
    else
      turtle.turnLeft()
      local success2, data2 = turtle.inspect()
      local secondOk = true
      if success2 then
        if data2.name == "minecraft:wheat" or data2.name == "minecraft:carrots" or data2.name == "minecraft:potatoes" or data2.name == "minecraft:beetroots" then
          if not isCropMature(data2.name, data2.state.age) then
            secondOk = false
          end
        end
      end

      if not secondOk then
        print("Second adjacent crop not fully grown; waiting 5 minutes.")
        turtle.turnRight()
        turtle.turnRight()  -- Revert to original orientation.
        sleep(300)
      else
        turtle.turnRight()  -- Return to original orientation.
        turtle.turnRight()
        break
      end
    end
  end
end

--------------------------------------------------
-- MAIN FARMING PROCESS
--------------------------------------------------
local function mainFarmingProcess()
  print("Starting main farming process.")
  turtle.up()
  turtle.turnLeft()
  turtle.forward()

  local row = 1
  local lastPlantedCrop = nil
  while true do
    print("Processing row " .. row)
    while true do
      local successDown, dataDown = turtle.inspectDown()
      if successDown then
        if dataDown.name == "minecraft:torch" then
        elseif dataDown.name == "minecraft:wheat" or dataDown.name == "minecraft:carrots" or dataDown.name == "minecraft:potatoes" or dataDown.name == "minecraft:beetroots" then
          if isCropMature(dataDown.name, dataDown.state.age) then
            if isInventoryFull() then
              if dataDown.name == "minecraft:wheat" or dataDown.name == "minecraft:beetroots" then
                organizeSeeds(dataDown.name)
              end
            end
            turtle.digDown()  -- Harvest the mature crop.
            lastPlantedCrop = dataDown.name
            plantSeedWithFallback(dataDown.name)
          else
          end
        else
        end
      else
        if lastPlantedCrop then
          plantSeedWithFallback(lastPlantedCrop)
        else
          plantSeedWithFallback("minecraft:wheat")
        end
      end

      local successFront, dataFront = turtle.inspect()
      if successFront and (dataFront.name == "minecraft:glass" or dataFront.name == "minecraft:glass_pane") then
         break  -- End of current row.
      end
      turtle.forward()
    end

    if row % 2 == 1 then
      turtle.turnLeft()
      local successCheck, dataCheck = turtle.inspect()
      if successCheck and (dataCheck.name == "minecraft:glass" or dataCheck.name == "minecraft:glass_pane") then
        break
      else
        turtle.forward()
        turtle.turnLeft()
      end
    else
      turtle.turnRight()
      local successCheck, dataCheck = turtle.inspect()
      if successCheck and (dataCheck.name == "minecraft:glass" or dataCheck.name == "minecraft:glass_pane") then
        break
      else
        turtle.forward()
        turtle.turnRight()
      end
    end

    row = row + 1
  end

  print("Main farming process complete.")
end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------
while true do
  print("Thank you for using Beni's Farm Script!")
  positionTurtle()
  fuelCheck()
  depositOperations()
  checkPlantGrowth()
  mainFarmingProcess()
  print("Thank you for using Beni's Farm Script!")
  print("Cycle complete; repositioning...")
  positionTurtle()
end
