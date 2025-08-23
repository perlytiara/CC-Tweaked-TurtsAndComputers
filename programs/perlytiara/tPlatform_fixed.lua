--{program="tPlatform",version="1.20",date="2025-08-23"}
---------------------------------------
-- tPlatform           by Kaikaku
-- 2016-02-28, v1.10   checks fuel 
-- 2015-03-28, v1.03   select slot 1 
-- 2015-03-21, v1.02   code tidied up 
-- 2013-11-09, v1.01   more compact
-- 2013-11-02, v1.00   initial
---------------------------------------

---------------------------------------
---- ASSUMPTIONS/PRECONDITIONS -------- 
---------------------------------------
--   Turtle movement:
--   - building space must be empty

---------------------------------------
---- PARAMETERS ----------------------- 
---------------------------------------
local cSleepTime=10

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local userX=3 userY=1
local blnAskForParameters=true
local blnDirectionX=true
local currentSlot=1

---------------------------------------
---- tArgs ----------------------------
---------------------------------------
local tArgs = {...}
if #tArgs == 2 then -- no error check
  blnAskForParameters=false
  userX=tonumber(tArgs[1])
  userY=tonumber(tArgs[2])
end

---------------------------------------
-- basic functions for turtle control -
---------------------------------------
local function mats()
  if turtle.getItemCount(currentSlot)==0 then
    currentSlot=currentSlot+1
	if currentSlot>16 then
	  currentSlot=1
	  print("Out of materials, please restock!")
	  print("  Sleeping for "..cSleepTime.." sec ...")
	  os.sleep(cSleepTime)
	end  
	turtle.select(currentSlot)
	mats()
  end
end

local function gf()
  while not turtle.forward() do
    turtle.attack()
    turtle.dig()
    os.sleep(0.2)
  end
end
local function gb()
  while not turtle.back() do
    turtle.turnLeft(); turtle.turnLeft()
    turtle.attack()
    turtle.dig()
    turtle.turnLeft(); turtle.turnLeft()
    os.sleep(0.2)
  end
end
local function gu()
  while not turtle.up() do
    turtle.attackUp()
    turtle.digUp()
    os.sleep(0.2)
  end
end
local function gd()
  while not turtle.down() do
    turtle.attackDown()
    turtle.digDown()
    os.sleep(0.2)
  end
end
local function gl()  while not turtle.turnLeft()  do end end
local function gr()  while not turtle.turnRight() do end end
local function df()  turtle.dig()       end
local function du()  turtle.digUp()     end
local function dd()  turtle.digDown()   end
local function pf()  mats() while not turtle.place()     do end end
local function pu()  mats() while not turtle.placeUp()   do end end
local function pd()  mats() while not turtle.placeDown() do end end
local function sf()  turtle.suck()      end
local function su()  turtle.suckUp()    end
local function sd()  turtle.suckDown()  end
local function Df()  turtle.drop()      end
local function Du()  turtle.dropUp()    end
local function Dd()  turtle.dropDown()  end
local function ss(s) turtle.select(s)   end

local function askForInputText(textt)
  local at=""
  -- check prompting texts
  if textt==nil then textt="Enter text:" end
  
  -- ask for input
  write(textt)
  at=read() 
  return at
end


local function checkFuel()
  local tmp=turtle.getFuelLevel()
  return tmp
end

-- Attempt to refuel up to a target fuel level using any fuel items in inventory
local function autoRefuel(targetFuel)
  local function tryConsumeFuelInSlots()
    local consumedAny=false
    for s=1,16 do
      if turtle.getItemCount(s)>0 then
        turtle.select(s)
        if turtle.refuel(0) then
          turtle.refuel()
          consumedAny=true
          if turtle.getFuelLevel()>=targetFuel then
            return true
          end
        end
      end
    end
    return consumedAny
  end

  if turtle.getFuelLevel()=="unlimited" then return true end

  while turtle.getFuelLevel()<targetFuel do
    local madeProgress = tryConsumeFuelInSlots()
    if turtle.getFuelLevel()>=targetFuel then return true end
    if not madeProgress then
      print("Out of fuel. Insert coal/fuel. Waiting "..cSleepTime.."s ...")
      os.sleep(cSleepTime)
    end
  end
  return true
end

-- Place a block below the turtle if air; skip if already solid
local function placeBlockDown()
  if turtle.detectDown() then return true end

  for s=1,16 do
    if turtle.getItemCount(s)>0 then
      turtle.select(s)
      if not turtle.refuel(0) then
        if turtle.placeDown() then
          return true
        end
      end
    end
  end

  print("No placeable blocks found. Waiting "..cSleepTime.."s ...")
  os.sleep(cSleepTime)
  return placeBlockDown()
end

------------------------------------------------------------------------------
-- main ----------------------------------------------------------------------
------------------------------------------------------------------------------

-- step 0 usage hints
term.clear() term.setCursorPos(1,1)
print("+-------------------------------------+")
print("| tPlatform v1.20, by Kaikaku         |")
print("+-------------------------------------+")
print("| Put in building materials in any    |")
print("|   slot(s) and press enter.          |")
print("| Platform size: Enter x and y to     |")
print("|   determine size. Either when asked |")
print("|   by program or with function call, |")
print("|   e.g., tPlatform 5 10              |")
print("| If turtle runs out of materials it  |")
print("|   waits until resupplied.           |")
print("| Will auto-refuel from inventory.    |")
print("+-------------------------------------+")
 
-- step 1 get input
ss(1)
if blnAskForParameters then
  askForInputText("Put in materials + press enter!")
  -- step 1.1 get x
  write("Enter length x (default&min=3):")
  userX=read()
  if userX==nil or userX=="" then userX=3 end
  userX=tonumber(userX) -- no error check yet
  if userX<3 then userX=3 end
   
  -- step 1.2 get y
  write("Enter width y (default&min=1):")
  userY=read()
  if userY==nil or userY=="" then userY=1 end
  userY=tonumber(userY) -- no error check yet
  --if userY<2 then userY=2 end
end  
userX=math.floor(userX)
userY=math.floor(userY)

-- check fuel level
local cMinFuel=(userX)*(userY+1)+1
turtleOk, turtleVal = pcall(checkFuel)
autoRefuel(cMinFuel)
if turtle.getFuelLevel()<cMinFuel then
term.clear() term.setCursorPos(1,1)
print("+-------------------------------------+")
print("| tPlatform v1.20, by Kaikaku         |")
print("+-------------------------------------+")
print("| Unable to reach required fuel level |")
print("| minimum of about ",cMinFuel," units.")
print("| Insert coal/fuel and restart.       |")
print("+-------------------------------------+")
return
end

-- step 2 build (new)
print("Let's build something nice:")
placeBlockDown()
for row=1,userY do
  for col=2,userX do
    gf()
    placeBlockDown()
  end
  if row<userY then
    if row%2==1 then
      gr(); gf(); gr()
    else
      gl(); gf(); gl()
    end
    placeBlockDown()
  end
end

print("Done. Looks nice to me ;)")
os.sleep(0.4)
print("***************************************")
print("* Check out YouTube for more videos   *")
print("* and turtle programs by Kaikaku :)   *")
print("***************************************")
return

-- step 2 loopy loops ;
-- ... existing code ...