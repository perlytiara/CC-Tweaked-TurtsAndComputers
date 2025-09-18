--{program="tClear",version="1.10",date="2024-10-22"}
---------------------------------------
-- tClear              by Kaikaku
-- 2024-10-22, v1.10   UI fix
-- 2021-03-28, v1.00   three-way digging
-- 2016-03-13, v0.90   dig on way back
-- 2014-09-27, v0.80   dig sand
-- 2013-09-01, v0.10   initial
---------------------------------------

---------------------------------------
---- DESCRIPTION ----------------------
---------------------------------------
-- Mining turtle digs specified cuboid
--   (x,y,z) without leaving the area,
--   using tripple dig :)
-- Incl. option to missus as strip miner.


---------------------------------------
---- ASSUMPTIONS ----------------------
---------------------------------------
-- Requires a mininng turtle


---------------------------------------
---- VARIABLES: template --------------
---------------------------------------
local cVersion            = "v1.10"
local cPrgName            = "tClear"
local cMinFuel            = 110
local blnAskForParameters = true
local blnShowUsage        = false
local blnDebugPrint       = false --true
local blnTurtle
local isComputer          = false
local baseColor           = colors.blue


---------------------------------------
---- VARIABLES: specific --------------
---------------------------------------
local slotFuel        = 16

local digDeep         = 3 -- all but 0 are okay
local digWide         = 3 -- all but -1,0,1 -- if wide <=-1 then depth needs to be >=2
local digHeight       = 1 -- all but 0
local digWideOrg
local digDeepOrg
local blnLayerByLayer = false
local blnStartWithin  = false
local blnStripMine    = false

-- Chunky turtle variables
local chunkyTurtleId  = nil
local blnUseChunky    = false
local chunkyPosition  = { x = 0, y = 0, z = -1, facing = 0 } -- relative position of chunky turtle (to the left)

---------------------------------------
---- Early UI functions ---------------
---------------------------------------
local function swapColors()
  local backColor = term.getBackgroundColor()
  local textColor = term.getTextColor()

  term.setBackgroundColor(textColor)
  term.setTextColor(backColor)
end

local function printUI(strInput)
  if strInput == ni then strInput = "" end

  if strInput == "header" then
    term.write("+-------------------------------------")
    print("+")
  elseif strInput == "line" then
    term.write("+-------------------------------------")
    print("+")
  elseif strInput == "footer" then
    term.write("+-------------------------------------")
    print("+")
  else
    term.write("|")
    strInput = strInput .. "                                     "
    term.write(string.sub(strInput, 1, 37))
    print("|")
  end
end

local function coloredTextAt(inputText, outputRow, outputCol, textColor, backColor)
  -- writes and colors text to coordinates
  local oldRow, oldCol = term.getCursorPos()
  local oldTextColor = term.getTextColor()
  local oldBackColor = term.getBackgroundColor()
  if textColor == nil then textColor = term.getTextColor() end
  if backColor == nil then backColor = term.getBackgroundColor() end

  term.setTextColor(textColor)
  term.setBackgroundColor(backColor)
  term.setCursorPos(outputRow, outputCol)
  term.write(inputText)
  term.setCursorPos(oldRow, oldCol)
  term.setTextColor(oldTextColor)
  term.setBackgroundColor(oldBackColor)
end

---------------------------------------
---- tArgs ----------------------------
---------------------------------------
local tArgs = { ... }
term.clear()
term.setCursorPos(1, 1)

local parameterShowSleep = 1

if #tArgs ~= 0 then
  -- header
  blnAskForParameters = false
  term.clear()
  term.setCursorPos(1, 1)
  printUI("header")
  printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku. Enjoy!")
  printUI("line")
  coloredTextAt(cPrgName, 2, 2, baseColor)
  print("Starting...")

  if tArgs[1] ~= nil then
    digDeep = math.floor(tonumber(tArgs[1]))
    if digDeep <= 0 then
      print("Parameter correction (depths must be >=1)!")
      sleep(2)
      parameterShowSleep = parameterShowSleep + 2
      digDeep = 1
    end
  end
  if tArgs[2] ~= nil then
    digWide = math.floor(tonumber(tArgs[2]))
    if digWide == 0 or digWide == 1 or digWide == -1 then
      print("Parameter correction (width not 0 or 1)!")
      sleep(2)
      parameterShowSleep = parameterShowSleep + 2
      digWide = 2
    end
  end
  if tArgs[3] ~= nil then
    digHeight = math.floor(tonumber(tArgs[3]))
    if digHeight == 0 then
      print("Parameter correction (height not 0)!")
      sleep(2)
      parameterShowSleep = parameterShowSleep + 2
      digHeight = 1
    end
  end

  --check combinations of min values
  if digDeep == 1 and digWide < 0 then
    error(
    "Parameter combination not allowed: depth=1 with width<0! Hint: increase depths or move turtle to use positive width.")
  end

  -- further parameters 4+
  for i = 4, #tArgs, 1 do
    if string.lower(tArgs[i]) == "layerbylayer" or string.lower(tArgs[i]) == "layer" or string.lower(tArgs[i]) == "singlelayer" then
      blnLayerByLayer = true
    end
    if string.lower(tArgs[i]) == "startwithin" or string.lower(tArgs[i]) == "within" or string.lower(tArgs[i]) == "in" then
      blnStartWithin = true
    end
    if string.lower(tArgs[i]) == "stripmine" or string.lower(tArgs[i]) == "strip" or string.lower(tArgs[i]) == "mine" then
      blnStripMine = true
    end
  end

  -- show parameters
  print("Clear depth = " .. digDeep)
  print("Clear width = " .. digWide)
  print("Clear height= " .. digHeight)
  term.write("Option LayerByLayert= ")
  if blnLayerByLayer then print("on") else print("off") end
  term.write("Option StartWithin  = ")
  if blnStartWithin then print("on") else print("off") end
  term.write("Option StripMine    = ")
  if blnStripMine then print("on") else print("off") end
  sleep(parameterShowSleep)
end

if blnShowUsage then
  term.clear()
  term.setCursorPos(1, 1)
  printUI("header")
  printUI("" .. cPrgName .. ", by Kaikaku")
  printUI("footer")
  print("Usage: ", cPrgName, " depth, width [height ['LayerByLayer'] ['StartWithin'] ['StripMine']] ")
  print()
  print("If called with any parameter, then")
  print("  there will be no info screen. Turtle")
  print("  starts immediately.")
  return
end


---------------------------------------
-- basic functions for turtle control -
---------------------------------------
-- 2021-03-28 partly tPos (from tClear)
-- 2021-03-20 arrangeArray, printArray (from tLoader)
-- 2021-03-13 askForNumber, pressKeyNoSpecials, checkInventory(u), getFirstEmptySlot, identifyTool, findModem, ensureModem
-- 2021-03-05 gfr                     -
-- 2021-02-06 select+place            -
-- 2021-01-29 save turtle go func     -
--            checkInventory w/ exit  -
--            refuelManager           -
---------------------------------------
local function gf(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.forward() do end end
end
local function gb(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.back() do end end
end
local function gu(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.up() do end end
end
local function gd(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.down() do end end
end
local function gl(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.turnLeft() do end end
end
local function gr(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.turnRight() do end end
end

local function df() turtle.dig() end
local function du() turtle.digUp() end
local function dd() turtle.digDown() end

local function dfs() while turtle.dig() do end end
local function dus() while turtle.digUp() do end end
local function dds() while turtle.digDown() do end end

local function pf() return turtle.place() end
local function pu() return turtle.placeUp() end
local function pd() return turtle.placeDown() end

local function sf() turtle.suck() end
local function su() turtle.suckUp() end
local function sd() turtle.suckDown() end
local function Df() turtle.drop() end
local function Du(n) turtle.dropUp(n) end
local function Dd() turtle.dropDown() end
local function ss(s) turtle.select(s) end
local function gic(s) return turtle.getItemCount(s) end

local function gfs(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.forward() do df() end end
end
local function gbs(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.back() do
      gl()
      gl()
      df()
      gr()
      gr()
    end end
end
local function gus(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.up() do du() end end
end
local function gds(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.down() do dd() end end
end
local function pfs()
  df()
  turtle.place()
end
local function pus()
  du()
  turtle.placeUp()
end
local function pds()
  dd()
  turtle.placeDown()
end

local function gfr() return turtle.forward() end
local function gbr() return turtle.back() end
local function gur() return turtle.up() end
local function gdr() return turtle.down() end

local tPos = {}

local function glPos(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.turnLeft() do end end
end                                                                                                                                   --tPos[4]=(tPos[4]-1)%4 end end
local function grPos(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.turnRight() do end end
end                                                                                                                                   --tPos[4]=(tPos[4]+1)%4 end end
local function gfPos(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.forward() do df() end end
end                                                                                                                                   --pCF(1) end end
local function gbPos(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do while not turtle.back() do
      gl()
      gl()
      df()
      gr()
      gr()
    end end
end                                                                                                                                   --pCF(-1) end end
local function guPos(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do
    while not turtle.up() do du() end
    tPos[3] = tPos[3] + 1
  end
end
local function gdPos(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do
    while not turtle.down() do dd() end
    tPos[3] = tPos[3] - 1
  end
end


local function spd(s, blnForward)
  if s == nil then s = turtle.currentSlot() end
  if blnForward == nil then blnForward = true end
  ss(s)
  pd()
  if blnForward then gf() end
end
local function spu(s, blnForward)
  if s == nil then s = turtle.currentSlot() end
  if blnForward == nil then blnForward = true end
  ss(s)
  pu()
  if blnForward then gf() end
end
local function spf(s, blnBack)
  if s == nil then s = turtle.currentSlot() end
  if blnBack == nil then blnBack = true end
  ss(s)
  pf()
  if blnBack then gb() end
end

local function waitKey(strText)
  local event, scancode
  write(strText)
  event, scancode = os.pullEvent("key")
  print()
end

local function askForInputText(textt)
  local at = ""
  -- check prompting texts
  if textt == nil then textt = "Enter text:" end

  -- ask for input
  write(textt)
  at = read()
  return at
end

local function askForNumber(askText, minValue, maxValue)
  -- gets entered data, ensures it's a number and returns it
  -- keeps asking if entry is not a number
  -- adapts to min and max values
  -- allways writes in screen line 13 (last for turtles)
  -- calls askForInputText
  local blnReask = true
  local returnNumber = nil
  if minValue == nil then minValur = 1 end
  if maxValue == nil then maxValue = 100 end
  if askText == nil then askText = "Key in number and press Enter: " end
  while blnReask do
    term.setCursorPos(1, 13)
    returnNumber = askForInputText(askText)
    if returnNumber == nil then
      blnReask = true
    else
      returnNumber = tonumber(returnNumber)
      if returnNumber == nil then
        blnReask = true
      else
        returnNumber = math.floor(returnNumber)
        if returnNumber > maxValue then returnNumber = maxValue end
        if returnNumber < minValue then returnNumber = minValue end
        blnReask = false
      end
    end
  end
  return returnNumber
end

local function pressKeyNoSpecials(askText)
  -- excludes ctrl / alt / shifts
  -- catches windows
  -- retruns the key number (if needed at all)
  local tmpEvent, tmpKey
  if askText == nil then askText = "Press key to START! (stop w/ ctrl+t)   " end
  tmpKey = 341
  while tmpKey >= 340 and tmpKey <= 346 do -- ctrls, alts, shifts
    term.write(askText)
    tmpEvent, tmpKey = os.pullEvent("key")
    if tmpKey == nil then tmpKey = 341 end -- win
  end
  return tmpKey
end

local function checkFuel()
  local tmp = turtle.getFuelLevel()
  return tmp
end

local function checkTurtle(blnOnlyIdentify)
  if blnOnlyIdentify == nil then blnOnlyIdentify = false end
  -- turtle?
  local turtleOk, turtleVal = pcall(checkFuel)
  if not turtleOk then
    blnTurtle = false
    if not blnOnlyIdentify then
      term.clear()
      term.setCursorPos(1, 1)
      printUI("header")
      printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku (" .. iPage .. "/" .. iPageMax .. ")")
      printUI("line")
      printUI("This is a turtle program.")
      printUI("  Please, execute it with a turtle!")
      printUI("footer")

      coloredTextAt(cPrgName, 2, 2, baseColor)
      error()
    end
  else
    blnTurtle = true
  end
end

local function sleepDots(sec, duration)
  if sec == nil then sec = 10 end
  if sec < 1 then return end
  if duration == nil then duration = 1 end -- shorten durtation for more dots

  for i = 1, sec - 1 do
    sleep(1 * duration)
    term.write(".")
  end

  sleep(1)
  print(".")
end

local function checkInventory(s, nMin, nMax, textt, blnExitOnFalse, blnRepeat)
  -- checks if in slot s are not less than nMin and not more than nMax items
  -- returns true if okay
  -- if not displays textt
  -- blnExitOnFalse=true raises an error
  -- blnRepeat=true repeatedly sks to put in the right number of items (overrides blnExitOnFalse)
  local oldSlot = turtle.getSelectedSlot()
  if s == nil then s = turtle.getSelectedSlot() end
  if nMin == nil then nMin = 0 end
  if nMax == nil then nMax = 64 end
  if blnExitOnFalse == nil then blnExitOnFalse = false end
  if blnRepeat == nil then blnRepeat = false end
  if blnRepeat ~= true then blnRepeat = false end

  while true do
    if turtle.getItemCount(s) < nMin or turtle.getItemCount(s) > nMax then
      print(textt)
      if not blnRepeat then
        -- single check ends with this
        if blnExitOnFalse then
          error()
        else
          ss(oldSlot)
          return false
        end
      end
      -- repeated check
      ss(s)
      sleepDots(3)
    else
      -- everything is fine
      ss(oldSlot)
      return true
    end
  end
end

local function refuelFromSlot(s, n) -- slot, amount to consume
  if s == nil then s = 16 end
  if n == nil then n = 64 end
  local currentSlot = turtle.getSelectedSlot()
  local fuelItems = turtle.getItemCount(s)
  local returnValue = false

  if fuelItems > 0 then
    ss(s)
    returnValue = turtle.refuel(n)
    ss(currentSlot)
  end
  return returnValue
end

local function refuelManager(setMinFuel, setSlotFuel, waitTime)
  local currentSlotSelected = turtle.getSelectedSlot()
  ss(setSlotFuel)
  while turtle.getFuelLevel() < setMinFuel do
    print("Need more fuel (" .. turtle.getFuelLevel() .. "/" .. setMinFuel .. ").")
    if not refuelFromSlot(setSlotFuel) then
      -- unsucessfull try
      print("  Please, put fuel items in slot " .. setSlotFuel .. "!")
      term.write("  Sleeping " .. waitTime .. " seconds")
      sleepDots(waitTime)
    else
      print("Refueled...")
    end
  end
  ss(currentSlotSelected)
end

local function debugPrint(str)
  if blnDebugPrint then print(str) end
end

local function inspectFor(blockArray, strDirection) -- <<-- from TreeFarm
  if strDirection == nil then strDirection = "f" end
  local blnOk, data

  -- inspect
  if strDirection == "d" then
    blnOk, data = turtle.inspectDown()
  elseif strDirection == "u" then
    blnOk, data = turtle.inspectUp()
  elseif strDirection == "f" then
    blnOk, data = turtle.inspect()
  else
    print("Warning: Unknown direction '", strDirection, "' in inspectFor, taking (f)orward instead.")
    strDirection = "f"
    blnOk, data = turtle.inspect()
  end
  if data.name ~= nil then debugPrint("Found:" .. string.lower(data.name)) end
  -- compare
  local i = 1
  while blockArray[i] ~= nil do
    debugPrint("Compare to:" .. string.lower(blockArray[i]))
    if data.name ~= nil then
      if string.lower(data.name) == string.lower(blockArray[i]) then return true end
    end
    i = i + 1
  end

  return false -- reached a nil value
end


local function getFirstEmptySlot(startAt)
  if startAt == nil then startAt = 1 end
  if startAt > 16 or startAt < 1 then return nil end

  for i = startAt, 16, 1 do
    if gic(i) == 0 then return i end
  end
  for i = 1, startAt, 1 do
    if gic(i) == 0 then return i end
  end
  return nil
end

local function identifyTool(toolSide)
  -- returns name of tool at side toolSide
  -- returns no_tool if there is none
  -- requires at least one empty slot for tool check (throws error)
  if toolSide == nil then toolSide = "right" end
  if toolSide ~= "right" and toolSide ~= "r" then toolSide = "left" end
  local slotNumber = getFirstEmptySlot()
  local slotSelected = turtle.getSelectedSlot()
  local toolName = "no_tool"

  if slotNumber == nil then error("Couldn't find empty slot to check tool on side '" .. toolSide .. "'!") end
  ss(slotNumber)
  -- step 1: get name
  if toolSide == "right" or toolSide == "r" then
    turtle.equipRight()
  else
    turtle.equipLeft()
  end
  -- step 2: get name
  local data = turtle.getItemDetail()
  if data ~= nil then toolName = data.name end
  -- step 3: re-equipget name
  if toolSide == "right" or toolSide == "r" then
    turtle.equipRight()
  else
    turtle.equipLeft()
  end
  ss(slotSelected)
  return toolName
end


local function findModem() -- <<-- delete if no modem used
  for _, p in pairs(rs.getSides()) do
    if peripheral.isPresent(p) and peripheral.getType(p) == "modem" then return true, p end
  end
  return false, nil
end

-- Chunky turtle communication functions
local function findChunkyTurtle()
  -- Look for available chunky turtles
  print("Broadcasting find_chunky message...")
  local timer = os.startTimer(3) -- Wait 3 seconds for responses
  local availableChunkies = {}

  -- Send broadcast to find chunky turtles
  rednet.broadcast({
    type = "find_chunky",
    masterId = os.getComputerID(),
    timestamp = os.time()
  }, "tclear-chunky")

  print("Waiting for chunky turtle responses...")

  -- Collect responses
  local event, timerId
  repeat
    event, timerId = os.pullEvent()
    if event == "rednet_message" then
      local senderId, message, protocol = rednet.receive(0.1)
      if senderId then
        print("Received message from " .. senderId .. " on protocol '" .. (protocol or "none") .. "'")
        if message and message.type == "chunky_available" then
          table.insert(availableChunkies, senderId)
          print("Found chunky turtle: " .. senderId)
        else
          print("Message type: " .. (message and message.type or "nil"))
        end
      end
    end
  until event == "timer" and timerId == timer

  print("Discovery timeout - found " .. #availableChunkies .. " chunky turtles")

  if #availableChunkies > 0 then
    chunkyTurtleId = availableChunkies[1] -- Use first available
    print("Attempting to pair with chunky turtle: " .. chunkyTurtleId)
    -- Pair with the chunky turtle
    rednet.send(chunkyTurtleId, {
      type = "pair",
      masterId = os.getComputerID(),
      timestamp = os.time()
    }, "tclear-chunky")
    print("Paired with chunky turtle: " .. chunkyTurtleId)
    blnUseChunky = true
    return true
  else
    print("No chunky turtles found - check that chunky turtle is running and has wireless modem")
  end
  return false
end

local function moveChunkyTurtle(mainX, mainY, mainZ, mainFacing)
  if blnUseChunky and chunkyTurtleId then
    -- Calculate chunky turtle position relative to main turtle (to the left side)
    -- Chunky turtle should be at same height, same Y level, but offset to the left
    local chunkyX = mainX         -- Same X position (depth)
    local chunkyY = mainY         -- Same height
    local chunkyZ = mainZ - 1     -- One block to the left (negative Z)
    local chunkyFacing = mainFacing -- Same facing direction

    rednet.send(chunkyTurtleId, {
      type = "move",
      target = { x = chunkyX, y = chunkyY, z = chunkyZ, facing = chunkyFacing },
      timestamp = os.time()
    }, "tclear-chunky")
    chunkyPosition = { x = chunkyX, y = chunkyY, z = chunkyZ, facing = chunkyFacing }
    print("Sent chunky turtle to position: (" ..
    chunkyX .. "," .. chunkyY .. "," .. chunkyZ .. ") facing=" .. chunkyFacing)
  end
end

local function stopChunkyTurtle()
  if blnUseChunky and chunkyTurtleId then
    rednet.send(chunkyTurtleId, {
      type = "stop",
      timestamp = os.time()
    }, "tclear-chunky")
  end
end


------------------------------------------------------------------------------
-- main: description ---------------------------------------------------------
------------------------------------------------------------------------------
checkTurtle()

-- Initialize rednet for chunky turtle communication
local hasModem, modemSide = findModem()
if hasModem then
  rednet.open(modemSide)
  print("Rednet opened for chunky turtle communication")
else
  print("No modem found - chunky turtle pairing disabled")
end

if blnAskForParameters then
  term.clear()
  term.setCursorPos(1, 1)
  local iPage = 0
  local iPageMax = 5
  local event, key, isHeld
  local blnLoop = true

  term.clear()
  term.setCursorPos(1, 1)
  iPage = iPage + 1
  printUI("header")
  printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku (" .. iPage .. "/" .. iPageMax .. ")")
  printUI("line")
  --       1234567890123456789012345678901234567
  printUI("Program features:")
  printUI("* Quick: mines 3 layers in 1 go")
  printUI("* Precise: mines and moves only ")
  printUI("    within the specified area")
  printUI("* Versatile: place turtle at any")
  printUI("    corner or within corner to start")
  printUI("* Lava sparing: with layer by layer")
  printUI("* Stripmine: may be misused for this")
  printUI("footer")

  coloredTextAt(cPrgName, 2, 2, baseColor)
  coloredTextAt("Quick", 4, 5, baseColor)
  coloredTextAt("Precise", 4, 6, baseColor)
  coloredTextAt("Versatile", 4, 8, baseColor)
  coloredTextAt("Lava sparing", 4, 10, baseColor)
  coloredTextAt("Stripmine", 4, 11, baseColor)

  pressKeyNoSpecials("Press key to START! (stop w/ ctrl+t)   ")
  ---

  term.clear()
  term.setCursorPos(1, 1)
  iPage = iPage + 1
  printUI("header")
  printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku (" .. iPage .. "/" .. iPageMax .. ")")
  printUI("line")
  --       1234567890123456789012345678901234567
  printUI("Program mines all blocks of a")
  printUI("  d * w * h cuboid.              ")
  printUI("  ")
  printUI("  height=" .. digHeight)
  printUI("    .                      ")
  printUI("  | / depth=" .. digDeep)
  printUI("  |/                         ")
  printUI("  +---- width=" .. digWide)
  printUI("footer")
  term.write("Key in depth and press Enter: ")

  coloredTextAt(cPrgName, 2, 2, baseColor)
  coloredTextAt("<-- enter (d>=1)", 18, 9, baseColor)
  event, key, isHeld = os.pullEvent("key")
  digDeep = askForNumber("Key in depth and press Enter: ", 1, 999)
  ---

  term.clear()
  term.setCursorPos(1, 1)
  iPage = iPage + 1
  printUI("header")
  printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku (" .. iPage .. "/" .. iPageMax .. ")")
  printUI("line")
  --       1234567890123456789012345678901234567
  printUI("Program mines all blocks of a")
  printUI("  d * w * h cuboid.              ")
  printUI("  ")
  printUI("  height=" .. digHeight)
  printUI("    .                      ")
  printUI("  | / depth=")
  printUI("  |/                         ")
  printUI("  +---- width=" .. digWide)
  printUI("footer")
  term.write("Key in width and press Enter: ")

  coloredTextAt(cPrgName, 2, 2, baseColor)
  coloredTextAt("(w>=2 or", 31, 10, baseColor)
  coloredTextAt("<-- enter  w<=-2)", 21, 11, baseColor)
  coloredTextAt(digDeep, 14, 9, baseColor)
  event, key, isHeld = os.pullEvent("key")
  digWide = askForNumber("Key in width and press Enter: ", -999, 999)
  if digWide == -1 or digWide == 0 or digWide == 1 then digWide = 2 end
  ---

  term.clear()
  term.setCursorPos(1, 1)
  iPage = iPage + 1
  printUI("header")
  printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku (" .. iPage .. "/" .. iPageMax .. ")")
  printUI("line")
  --       1234567890123456789012345678901234567
  printUI("Program mines all blocks of a")
  printUI("  d * w * h cuboid.              ")
  printUI("  ")
  printUI("  height=" .. digHeight)
  printUI("    .                      ")
  printUI("  | / depth=")
  printUI("  |/                         ")
  printUI("  +---- width=")
  printUI("footer")
  term.write("Key in height and press Enter: ")

  coloredTextAt(cPrgName, 2, 2, baseColor)
  coloredTextAt("<-- enter (h<>0)", 15, 7, baseColor)
  coloredTextAt(digDeep, 14, 9, baseColor)
  coloredTextAt(digWide, 17, 11, baseColor)
  event, key, isHeld = os.pullEvent("key")
  digHeight = askForNumber("Key in height and press Enter: ", -999, 999)
  if digHeight == 0 then digHeight = 1 end
  ---

  term.clear()
  term.setCursorPos(1, 1)
  iPage = iPage + 1
  printUI("header")
  printUI("" .. cPrgName .. ", " .. cVersion .. ", by Kaikaku (" .. iPage .. "/" .. iPageMax .. ")")
  printUI("line")
  --       1234567890123456789012345678901234567
  printUI("Program mines all blocks of a")
  printUI("  d * w * h cuboid.              ")
  printUI("  ")
  printUI("  height=       Options:")
  printUI("    .            layer by layer: ")
  printUI("  | / depth=      start within:   ")
  printUI('  |/              "strip mine":   ')
  printUI("  +---- width=")
  printUI("footer")
  term.write("Toggle options or ENTER to start: ")

  coloredTextAt(cPrgName, 2, 2, baseColor)
  coloredTextAt("Options:", 18, 7, baseColor)
  coloredTextAt("l", 20, 8, baseColor)
  coloredTextAt("w", 26, 9, baseColor)
  coloredTextAt("m", 27, 10, baseColor)
  coloredTextAt(digDeep, 14, 9, baseColor)
  coloredTextAt(digWide, 17, 11, baseColor)
  coloredTextAt(digHeight, 11, 7, baseColor)

  while blnLoop do
    -- color toggles
    if blnLayerByLayer then
      coloredTextAt("on ", 36, 8, baseColor)
    else
      coloredTextAt("off", 36, 8, colors.white)
    end
    if blnStartWithin then
      coloredTextAt("on ", 36, 9, baseColor)
    else
      coloredTextAt("off", 36, 9, colors.white)
    end
    if blnStripMine then
      coloredTextAt("on ", 36, 10, baseColor)
    else
      coloredTextAt("off", 36, 10, colors.white)
    end
    -- get key
    event, key, isHeld = os.pullEvent("key")
    -- evaluate key
    if key ~= nil then
      if keys.getName(key) == "l" then
        blnLayerByLayer = not blnLayerByLayer
      elseif keys.getName(key) == "m" then
        blnStripMine = not blnStripMine
      elseif keys.getName(key) == "w" then
        blnStartWithin = not blnStartWithin
      elseif keys.getName(key) == "enter" then
        blnLoop = false
      end
    end
  end
end


---------------------------------------
-- additional functions               -
---------------------------------------

local blnDigUp = false
local blnDigDown = false

local function digUpDown()
  if blnDigUp then dus() end
  if blnDigDown then dds() end
end

local function gfPosDig(n)
  if n == nil then n = 1 end
  for i = 1, n, 1 do
    gfPos()
    digUpDown()
  end
end

-- Try to find and pair with chunky turtle
if hasModem then
  print("Looking for chunky turtle...")
  if findChunkyTurtle() then
    print("Chunky turtle paired successfully!")
    -- Wait for chunky turtle to confirm pairing
    print("Waiting for chunky turtle confirmation...")
    sleep(2)
    -- Send initial position to chunky turtle
    moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    print("Chunky turtle positioned and ready!")
  else
    print("No chunky turtle found - continuing without chunk loading")
  end
else
  print("No modem found - chunky turtle pairing disabled")
end

------------------------------------------------------------------------------
-- main: pre-main options ----------------------------------------------------
------------------------------------------------------------------------------

local selfCall = ""
local selfLayer = ""
if blnStripMine then
  -- let's missuse this beautiful program for strip mining

  -- srtip mine step 1: main corridor
  if blnLayerByLayer then selfLayer = " LayerByLayer" end
  selfCall = "tClear " .. digDeep .. " -2 " .. digHeight .. selfLayer

  if blnStripMine then selfCall = selfCall .. " within" end

  --print(selfCall)
  shell.run(selfCall)

  -- strip mine step 2: mining shafts right side
  -- step inside
  if not blnStartWithin then gfPos() end
  -- mine shafts
  for i = 1, digDeep, 4 do
    -- get on position
    if i > 1 then
      gfPos(4)
    end
    -- mining shafts
    selfCall = "tClear 1 " .. (digWide + 1) .. " " .. digHeight .. " within" .. selfLayer
    print(selfCall)
    --sleep(3)
    shell.run(selfCall)
  end

  -- strip mine step 3: mining shafts left side
  -- get on position
  gl()
  gfPos()
  gl()
  -- mine shafts
  for i = 1, digDeep, 4 do
    -- get on position
    if i > 1 then
      gfPos(4)
    end

    -- mining shafts
    selfCall = "tClear 1 " .. (digWide + 1) .. " " .. digHeight .. " within" .. selfLayer
    print(selfCall)
    --sleep(3)
    shell.run(selfCall)
  end

  -- strip mine step 4: return
  -- to entrance
  gl()
  gfPos()
  gl()
  -- step outside
  if not blnStartWithin then gbPos() end

  -- done
  return
end


------------------------------------------------------------------------------
-- main: program -------------------------------------------------------------
------------------------------------------------------------------------------
term.clear()
term.setCursorPos(1, 1)

---- step 0: check fuel ----
print("step 0: checking fuel...")
-- fuel
-- estimate consumption
if not blnLayerByLayer then
  cMinFuel = math.floor(digHeight / 3)
else
  cMinFuel = math.floor(digHeight)
end
cMinFuel = cMinFuel * (math.abs(digDeep) + 1) * (math.abs(digWide) + 1) + (digHeight * 2)
cMinFuel = math.floor(cMinFuel * 1.1) + 20 -- extra

refuelManager(cMinFuel, slotFuel, 2)
print("... done")


---- step 1: do deal with negative values ----
term.write("step 1: deal with negative values...")

-- first dig block is 1,1,1
tPos[1] = 1
tPos[2] = 0
tPos[3] = 1
tPos[4] = 0                             -- starting position


-- save inital values for end report
digWideOrg = digWide
digDeepOrg = digDeep

--- check negative width
local blnNegativeWidth = false
if digWide < 0 then
  blnNegativeWidth = true
  digWide = digDeepOrg
  digDeep = -digWideOrg
end

--- check negative height
local blnNegativeHeight = false
local remainingDigHeight = digHeight
if digHeight < 0 then
  blnNegativeHeight = true
  remainingDigHeight = -digHeight
end
print(" done")


---- step 2: enter and go up ----
term.write("step 2: enter and go up...")
-- step inside area
if not blnStartWithin then
  -- move into cuboid
  gfPosDig()
  -- Move chunky turtle to follow
  moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
else
  -- I'm already there
  tPos[2] = 1
  -- Move chunky turtle to follow
  moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
end

-- positive or negative inital width?
if not blnNegativeWidth then
  grPos() -- turn to show progress
else
  -- orientation is already okay, due to negative inital width
end
print(" done")

-- step 3: starting height
term.write("step 3: starting height...")
if not blnLayerByLayer then
  -- normal 3 layer dig mode
  if digHeight > 2 then
    -- get to right inital digging height
    guPos(digHeight - 2)
    -- Move chunky turtle to follow
    moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
  elseif digHeight < -1 then
    -- get to right inital negative digging height
    gdPos(1)
    -- Move chunky turtle to follow
    moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
  end
else
  -- layer by layer
  if digHeight > 1 then
    -- go to very top
    guPos(digHeight - 1)
    -- Move chunky turtle to follow
    moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
  else
    -- just stay where you are
  end
end
print(" done")


while remainingDigHeight > 0 do
  -- step 4: set dig up/down
  term.write("step 4: set dig up/down...")
  if not blnLayerByLayer then
    -- normal 3 layer dig mode
    if not blnNegativeHeight then
      -- positive dig height
      if tPos[3] > 1 then
        -- gone up to tripple dig
        blnDigUp = true
        blnDigDown = true
      elseif remainingDigHeight == 2 then
        blnDigUp = true
        blnDigDown = false
      else
        blnDigUp = false
        blnDigDown = false
      end
    else
      -- negative dig hight
      if tPos[3] >= digHeight + 3 then
        -- gone down to tripple dig
        blnDigUp = true
        blnDigDown = true
      elseif remainingDigHeight == 2 then
        blnDigUp = true  --false
        blnDigDown = false --true
      else
        blnDigUp = false
        blnDigDown = false
      end
    end
  else
    -- layer by layer mode
    blnDigUp = false
    blnDigDown = false
  end
  print(" done")


  ---- step 5: digging one level ----
  term.write("step 5: digging one level...")

  for iy = 1, digDeep, 1 do
    if iy == 1 then
      gfPosDig() -- step inside track
      -- Move chunky turtle to follow
      moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    elseif iy % 2 == 0 then
      -- u-turn left
      glPos()
      gfPosDig()
      glPos()
      -- Move chunky turtle to follow
      moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    else
      -- u-turn right
      grPos()
      gfPosDig()
      grPos()
      -- Move chunky turtle to follow
      moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    end
    -- lane
    gfPosDig(digWide - 2)
    -- Move chunky turtle to follow
    moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])

    if iy == digDeep then
      -- return
      if iy % 2 == 1 then
        -- uneven! lets return	
        glPos(2)
        gfPosDig(digWide - 2)
      end

      -- dig lane y=1 back
      gfPosDig()
      glPos()
      gfPosDig(digDeep - 1)
      glPos()
      -- Move chunky turtle to follow
      moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    end
  end
  print(" done")


  ---- step 6: change level ----
  term.write("step 6: change level...")

  -- adjuste remainingDigHeight
  remainingDigHeight = remainingDigHeight - 1
  if blnDigUp then remainingDigHeight = remainingDigHeight - 1 end
  if blnDigDown then remainingDigHeight = remainingDigHeight - 1 end

  -- adjust layer if there's s.th. left to dig
  if remainingDigHeight > 0 then
    if not blnLayerByLayer then
      -- normal 3 layer dig mode
      -- inital dig height pos or neg?
      if not blnNegativeHeight then
        -- inital dig height positive
        -- get to next dig level
        if remainingDigHeight >= 2 then
          gdPos(3)
          -- Move chunky turtle to follow
          moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        else
          gdPos(tPos[3] - 1)
          -- Move chunky turtle to follow
          moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        end
      else
        -- inital dig height negative
        -- get to next dig level
        if remainingDigHeight >= 2 then
          gdPos(3)
          -- Move chunky turtle to follow
          moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        else
          gdPos(-digHeight + tPos[3] - 2)
          -- Move chunky turtle to follow
          moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
        end
      end
    else
      -- layer by layer mode
      gdPos(1) -- just the next one
      -- Move chunky turtle to follow
      moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
    end
  end
  print(" done")
end

---- step 7: return to floor ----
term.write("step 7: return to floor...")

-- return to floor
if not blnNegativeHeight then
  gdPos(tPos[3] - 1)
else
  guPos(-tPos[3] + 1)
end
-- Move chunky turtle to follow
moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])

-- positive or negative inital width?
if not blnNegativeWidth then
  glPos() -- turn to leave
else
  -- orientation is already okay, due to negative inital width
end

-- step out of area
if not blnStartWithin then
  -- move out of cuboid
  gbPos()
  -- Move chunky turtle to follow
  moveChunkyTurtle(tPos[1], tPos[2], tPos[3], tPos[4])
else
  -- I started there, so I'm already done
end
print(" done")


---- step 8: finishing stuff / report ----
-- Stop chunky turtle
if blnUseChunky then
  stopChunkyTurtle()
  print("Chunky turtle stopped")
end

print("Done with tClear " .. digDeep .. " " .. digWide .. " " .. digHeight)
print("That looks much cleaner now! !")
ss(1)
--sleep(0.4)
printUI("header")
printUI("Check out YouTube for more videos")
printUI("and turtle programs by Kaikaku :)")
printUI("footer")
