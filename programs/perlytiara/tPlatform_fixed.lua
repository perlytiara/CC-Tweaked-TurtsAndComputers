--{program="tPlatform",version="1.10",date="2016-02-28"}
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

local function gf()  while not turtle.forward()   do end end
local function gb()  while not turtle.back()      do end end
local function gu()  while not turtle.up()        do end end
local function gd()  while not turtle.down()      do end end
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

------------------------------------------------------------------------------
-- main ----------------------------------------------------------------------
------------------------------------------------------------------------------

-- step 0 usage hints
term.clear() term.setCursorPos(1,1)
print("+-------------------------------------+")
print("| tPlatform v1.10, by Kaikaku         |")
print("+-------------------------------------+")
print("| Put in building materials in any    |")
print("|   slot(s) and press enter.          |")
print("| Platform size: Enter x and y to     |")
print("|   determine size. Either when asked |")
print("|   by program or with function call, |")
print("|   e.g., tPlatform 5 10              |")
print("| If turtle runs out of materials it  |")
print("|   waits until resupplied.           |")
print("+-------------------------------------+")
 
-- step 1 get input
ss(1)
if blnAskForParameters then
  askForInputText("Put in materials + press enter!")
  -- step 1.1 get x
  write("Enter depth x (default&min=3):")
  userX=read()
  if userX==nil or userX=="" then userX=3 end
  userX=tonumber(userX) -- no error check yet
  if userX<3 then userX=3 end
   
  -- step 1.2 get y
  write("Enter width y (default&min=1):")
  userY=read()
  if userY==nil or userY=="" then userY=3 end
  userY=tonumber(userY) -- no error check yet
  --if userY<2 then userY=2 end
end  
userX=math.floor(userX)
userY=math.floor(userY)

-- check fuel level
local cMinFuel=(userX)*(userY+1)+1
turtleOk, turtleVal = pcall(checkFuel)
if turtleVal<cMinFuel then
term.clear() term.setCursorPos(1,1)
print("+-------------------------------------+")
print("| tPlatform v1.10, by Kaikaku         |")
print("+-------------------------------------+")
print("| Please refuel turtle, it needs a    |")
print("| minimum of about ",cMinFuel," fuel units.")
print("| Tip: Put some fuel (e.g. coal) in   |")
print("|      slot 1 and enter: refuel all.  |")
print("|      This will consume all(!) fuel  |")
print("|      items in the turtle's inventory|")
print("+-------------------------------------+")
return
end

-- step 2 loopy loops ;)
print("Let's build something nice:")
-- step 2.1 go to start position 
--          & if odd number go back
if userY%2==1 then 
  -- odd number of rows
  for i=1,userX,1 do gf() end
  blnDirectionX=false
else
  -- even number of rows
  gf() gf() gl() gl()
  blnDirectionX=true
end	

-- step 2.2 build it
for iY=1,userY,1 do
  for iX=1,userX-1 do
    if iX==1 then
	  if iY~=1 then 
	    if blnDirectionX then
		  gl() 
		else
          gr() 
		end
	  end
	  gb() pf()		
    elseif  iX==userX-1 then
	  if iY~=userY then 	    
	    if blnDirectionX then
	      -- right turn
          gr()  
		else
		  -- left turn
		  gl() 
	  	end	  
	  end
	  gb() pf()
	else -- in between start and end
	  gb() pf()
    end

  end
  blnDirectionX=not blnDirectionX
end
-- go back within 1st row
gr()
for i=1,userY-1,1 do gb() pf() end
gl() gb() pf()
  
print("Done. Looks nice to me ;)")
os.sleep(0.4)
print("***************************************")
print("* Check out YouTube for more videos   *")
print("* and turtle programs by Kaikaku :)   *")
print("***************************************")