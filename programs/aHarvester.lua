--{program="aHarvester",version="1.10",date="2024-10-30"}
---------------------------------------
-- aHarvester          by Kaikaku
-- 2024-10-30, v1.10   UI fix
-- 2021-03-05, v1.02c  info clar. + gfs()
-- 2021-02-28, v1.01   info clarification
-- 2021-02-28, v1.00   initial
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- This program automates the farming
--   of many different plants like 
--   sugarcane, melons, bamboo. Those
--   plants must grow from a source 
--   block, that is not to be harvested.
-- Harvested material is droped into
--   chest. Fuel is taken from another.
-- For more feature details see info 
--   screens or YouTube.


---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Turtle is a mining turtle and a 
--   sample of its landmark block in 
--   slot 1.


---------------------------------------
---- PARAMETERS ----------------------- 
---------------------------------------
local cVersion  ="v1.02c"
local cPrgName  ="aHarvester"
local cCritFuel  =800 -- stops at fuel station / home if lower than this
local cMinFuel  =2000 -- refuels at fuel station if lower than this
local slotFuel=16
local cSleepTime=60
local cMaxTurns =-1
local turnCounter =0
local turnsRemaining =cMaxTurns
local blnCreateStartup=false
local createStartup = "shell.run('"..cPrgName.." "
local blnNoCannibalism=false -- no checks for other turtles (a bit slower)
local blnDetectedTurtle=false
local cNoCannibalism={}
-- Hint: in case of new botonia versions this might need an update!
cNoCannibalism[0]="computercraft:turtle_normal"
cNoCannibalism[1]="computercraft:turtle_advanced"

local harvestedStuff=0
local harvestedStuffTotal=0

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local blnAskForParameters =true

local blnDown = true
local blnUp   = true

local landmarkU -- up
local landmarkF --forward
local landmarkD --down

local nextTrunRight = true
local nextTrunTurn = false
local blnGoOn = true


---------------------------------------
---- Early UI functions ---------------
---------------------------------------
local function swapColors()     -- <<-- put into template
local backColor=term.getBackgroundColor()
local textColor=term.getTextColor()

term.setBackgroundColor(textColor)
term.setTextColor(backColor)
end

local function printUI(strInput)
if strInput==ni then strInput="" end
 
  if strInput=="header" then
    term.write("+-------------------------------------") print("+")   
  elseif strInput=="line" then
    term.write("+-------------------------------------") print("+") 
  elseif strInput=="footer" then
    term.write("+-------------------------------------") print("+") 
  else
    term.write("|")
    strInput=strInput.."                                     "
    term.write(string.sub(strInput,1,37))
    print("|") 
  end
end

---------------------------------------
---- tArgs ----------------------------
---------------------------------------
local tArgs = {...}    -- <<-- transfere concept to template
local paraIdentified=false
local paraNumberCount=0
term.clear() term.setCursorPos(1,1)

-- header 
if #tArgs~=0 then
  printUI("header")
  printUI(""..cPrgName..", "..cVersion..", by Kaikaku. Enjoy!")
  printUI("line")
  print("Starting...")
end

-- check parameters
for i=1,#tArgs do
  blnAskForParameters=false
  paraIdentified=false
  -- tet parameters
  if string.lower(tArgs[i])=="notdown" then 
    paraIdentified=true blnDown=false 
	createStartup=createStartup..tArgs[i].." "
	print("Option: not dig down!")
  end
  if string.lower(tArgs[i])=="notup" then	
    paraIdentified=true blnUp=false 
	createStartup=createStartup..tArgs[i].." "
	print("Option: not dig up!")  
  end
  if string.lower(tArgs[i])=="nocannibalism" then	
    paraIdentified=true blnNoCannibalism=true 
	createStartup=createStartup..tArgs[i].." "
	print("Option: no cannibalism!")  
  end
  if string.lower(tArgs[i])=="startup" then	
    paraIdentified=true blnCreateStartup=true 
	print("Option: creating startup")  
  end
  -- text+number parameters
  if string.sub(string.lower(tArgs[i]),1,7)=="minfuel" then
	term.write("Option: minFuel "..cMinFuel.."->")  
	paraIdentified=true 
	createStartup=createStartup..tArgs[i].." "
    cMinFuel=tonumber(string.sub(string.lower(tArgs[i]),8))
	print(cMinFuel)  
  end
  if string.sub(string.lower(tArgs[i]),1,8)=="critfuel" then
	term.write("Option: critFuel "..cCritFuel.."->")  
	paraIdentified=true 
	createStartup=createStartup..tArgs[i].." "
    cCritFuel=tonumber(string.sub(string.lower(tArgs[i]),9))
	print(cCritFuel)  
  end
  -- number parameters
  if not paraIdentified  then
    if paraNumberCount==0 then
	  cSleepTime=tonumber(tArgs[i]) -- no error handling for text
	  paraIdentified=true
	  createStartup=createStartup..tArgs[i].." "
	  paraNumberCount=paraNumberCount+1
	  print("Option: sleep time = "..cSleepTime)
	elseif paraNumberCount==1 then
	  cMaxTurns=tonumber(tArgs[i]) -- no error handling for text
	  turnsRemaining=cMaxTurns
	  paraIdentified=true
	  createStartup=createStartup..tArgs[i].." "
	  paraNumberCount=paraNumberCount+1
	  print("Option: fixed number of turns = "..cMaxTurns)
	end
  end
  if not paraIdentified then
    error("Error: Unknown parameter "..i..":'"..tArgs[i].."'")
  end
sleep(0.3)
end

---------------------------------------    -- <<--- put in template
---- startup generation ---------------
---------------------------------------
if blnCreateStartup then
local newFileName
  createStartup=createStartup.."')"
  print("Creating a startup file with: "..createStartup)
  
  -- is there already one?
  if fs.exists("startup.lua") then
    print("  '".."startup.lua".."' already exists.")
	newFileName="startup_old_"..os.date("%Y-%m-%d_%H:%M")
	print("  Renaming to '".."startup.lua".."'") 
	shell.run("rename startup.lua "..newFileName)
  end
  if fs.exists("startup") then
    print("  '".."startup".."' already exists.")
	newFileName="startup_old_"..os.date("%Y-%m-%d_%H:%M")
	print("  Renaming to '"..newFileName.."'") 
	shell.run("rename startup "..newFileName)
  end
  
  print("Saving new startup...")
   	

local h = fs.open("startup", "w")
h.writeLine("-- Automatically created startup by:")
h.writeLine("--   "..cPrgName..", "..cVersion..", by Kaikaku")
h.writeLine("-- If you are looking for another")
h.writeLine("--   startup file, check files like:")
h.writeLine("--   'startup_old_yyyy-mm-dd-tttt'")
h.writeLine(createStartup)
h.close()

end

---------------------------------------
-- basic functions for turtle control -
---------------------------------------
local function gf()  while not turtle.forward()   do end end
local function gb()  while not turtle.back()      do end end
local function gu()  while not turtle.up()        do end end
local function gd()  while not turtle.down()      do end end
local function gl()  while not turtle.turnLeft()  do end end
local function gr()  while not turtle.turnRight() do end end
local function df()  local returnValue = turtle.dig() turtle.suck() return returnValue  end
local function gfs(n)  if n==nil then n=1 end  for i=1,n,1 do  while not turtle.forward() do df() end end end
local function du()  turtle.digUp() turtle.suckUp()      end
local function dd()  turtle.digDown() turtle.suckDown()  end
local function pf()  turtle.place()     end
local function pu()  turtle.placeUp()   end
local function pd()  return turtle.placeDown() end
local function sf()  turtle.suck()      end
local function su()  turtle.suckUp()    end
local function sd()  turtle.suckDown()  end
local function Df()  turtle.drop()      end
local function Du(n) turtle.dropUp(n)  end
local function Dd()  turtle.dropDown()  end
local function ss(s) turtle.select(s)   end
local function gic(s) return turtle.getItemCount(s) end



local function waitKey(strText)
  local event, scancode
  write(strText) 
  event, scancode = os.pullEvent("key") 
  print()
end

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

local function checkTurtle()
-- turtle?
  local turtleOk, turtleVal = pcall(checkFuel)
  if not turtleOk then
    term.clear() term.setCursorPos(1,1)
    print("+-------------------------------------+")
    print("  ",cPrgName,", by Kaikaku")
    print("+-------------------------------------+")
    print("| This is a turtle program.           |")
    print("| Please, execute it with a turtle!   |")
    print("+-------------------------------------+")
    return
  end
end


local function sleepDots(sec)
if sec==nil then sec=10 end
if sec<1 then return end
local sleepDotsCounter=0

  for i=1,sec-1 do
    sleepDotsCounter=sleepDotsCounter+1
    sleep(1)
	if sleepDotsCounter<31 then
      term.write(".")
	else
	  sleepDotsCounter=1
	  print()
	  term.write(".")
	end
  end
  
  sleep(1)
  print(".")
end


---------------------------------------
-- additional functions               -
---------------------------------------


local function dropInventory()
  for i=2,16 do
    if gic(i)>0 then 
	  ss(i) 
	  harvestedStuff=harvestedStuff+gic()
	  Dd() 
	end
  end
  ss(1)
end

local function doCompares()
  landmarkU=turtle.compareUp()
  landmarkF=turtle.compare()
  landmarkD=turtle.compareDown()
end

local function doRefuel()
local fuelAtStart=turtle.getFuelLevel()

  -- call this only at fuel station
  if turtle.getFuelLevel() < cMinFuel then
    -- need to refuel
    term.write("  Refueling:"..turtle.getFuelLevel())
	if gic(slotFuel)==0 then
	  ss(slotFuel)
	  su()
	  turtle.refuel()
	  ss(1)
	end
	print(""..turtle.getFuelLevel())
  else
    print("  Fuel is okay.")
  end
  return fuelAtStart<turtle.getFuelLevel()
end

local function checkCritFuel()
local currentSlot = turtle.getSelectedSlot()
  while turtle.getFuelLevel()<cCritFuel do
    ss(slotFuel)
    print("Critical fuel level ("..turtle.getFuelLevel().."/"..cCritFuel..")!")
	term.write("  Please, provide fuel in slot "..slotFuel.."!")
    while gic(slotFuel)==0 do
	  term.write(".")
	  sleep(1)
	end
    turtle.refuel()
  end
  ss(currentSlot)
end


local function suckAll()
  while turtle.suck() do end
  while turtle.suckUp() do end
  while turtle.suckDOwn() do end
end

local function debugPrint(str)
 if false then print(str) end
end

local function inspectFor(blockArray, strDirection)
if strDirection==nil then strDirection="f" end
local blnOk, data

  -- inspect
  if strDirection=="d" then blnOk, data = turtle.inspectDown() 
  elseif strDirection=="u" then blnOk, data = turtle.inspectUp() 
  elseif strDirection=="f" then blnOk, data = turtle.inspect() 
  else 
    print("Warning: Unknown direction '",strDirection,"' in inspectFor, taking (f)orward instead.")
    strDirection="f"
    blnOk, data = turtle.inspect() 
  end
  if data.name~=nil then debugPrint("Found:"..string.lower(data.name)) end
  -- compare
  local i=1
  while blockArray[i]~=nil do
  debugPrint("Compare to:"..string.lower(blockArray[i]))
    if data.name~=nil then
      if string.lower(data.name) == string.lower(blockArray[i]) then return true end
	end
    i=i+1
  end
  
  return false -- reached a nil value
end

local function evadeStrategy()
local cTurnProbablity=20
local tmpRnd = math.random(0,100)
  term.write("")
  if tmpRnd<=cTurnProbablity then
    gr() term.write("r")
  elseif tmpRnd<=cTurnProbablity*2 then
    gl() term.write("l")
  else
    term.write("s") sleep(0.8)
  end
end

local function handleReport()
  print("  Harvested items this turn: "..harvestedStuff)
  harvestedStuffTotal=harvestedStuffTotal+harvestedStuff
  harvestedStuff=0
  print("  Harvested items total: "..harvestedStuffTotal)
end

local function handleTurnCounter()
-- return true if cMaxTurns is reached, else false
  handleReport()
  if turnsRemaining==0 then return true end
  turnCounter=turnCounter+1
  if cMaxTurns>=0 then 
    turnsRemaining=turnsRemaining-1
	term.write("Turn "..turnCounter.."/"..cMaxTurns..":")
  else
	term.write("Turn "..turnCounter..":")
  end
  return false
end

------------------------------------------------------------------------------
-- main ----------------------------------------------------------------------
------------------------------------------------------------------------------
checkTurtle()

if blnAskForParameters then
term.clear() term.setCursorPos(1,1)
local iPage=0
local iPageMax=10                                    
term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("This program automates the farming")
printUI("  of many different plants like")
printUI("  sugar cane, melons, mushrooms,")
printUI("  bamboo, kelp and many more. These")
printUI("  plants typically grow or spread")
printUI("  from a source block. ")
printUI("Starting it w/o parameter (as now)")
printUI("  shows this info and uses defaults.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Determine a landmark block (not dirt)")
printUI("  and frame the area in where to har-")
printUI("  vest. Place this frame at y level")
printUI("  of the turtle is. Put 1 in slot 1.")
printUI("The turtle will allways move forward")
printUI("  until it hits this block. Then it")
printUI("  makes a u-turn right then left...")
printUI("  In corners it changes the orient.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Put a chest below the turtle level")
printUI("  with a landmark block two blocks")
printUI("  above, this is the home position.")
printUI("Place a chest above the turtle level")
printUI("  with a landmark block two blocks")
printUI("  below, this is the refuel chest.")
printUI("You can have as many home and fuel")
printUI("  stations as you like.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Side view example:")
printUI(" ")
printUI("         L c    T=turtle")
printUI(" Lssssss T  L   L=landmark block")
printUI("  ssssss C L    s=sugar cane")
printUI("  ssssss        C=home chest")
printUI(" XXXXXXXXXXXX   c=fuel chest")
printUI(" XXXXXXXXXXXX   X=dirt/etc.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Number parameters:              ")
printUI("  The first number parameter you use")
printUI("    determines the waiting time at ")
printUI("    the home position (default=60).")
printUI("  A second number parameter deter-")
printUI("    mines the number of turns ")
printUI("    (=reaching home position) if you")
printUI("    want to limit the runs.")
printUI("footer")
until askForInputText("Press enter when ready:")==""
term.clear() term.setCursorPos(1,1) iPage=iPage+1

repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Harvest options:              ")
printUI("  Turtle will harvest allways blocks ")
printUI("    in front of it and by default all")
printUI("    blocks above and below it.       ")
printUI("  To disable harvesting of blocks you")
printUI("    use one or both of the following ")
printUI("    not case sensitive parameters:   ")
printUI("  notUp and/or notDown")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Fuel parameters: At min fuel level")
printUI("  (2000) the turtle refuels. With")
printUI("  the parameter minFuelxxxx you cust-")
printUI("  omize this value to 'xxxx'.")
printUI("At crit fuel level (800) the turtle")
printUI("  won't move from home or (empty?)")
printUI("  fuel stations: Use parameter ")
printUI("  critFuelxxxx to change this.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Auto startup:")
printUI("  If you want the turtle to allways")
printUI("  start the program when the world or")
printUI("  chunk is loaded, use the parameter:")
printUI("  startup")
printUI("  This will create a startup pro-")
printUI("  gram using the same parameters")
printUI("  as the current call.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Example calls:")
printUI("aHarvester notDown")
printUI("->Turtle starts w/ default values, ")
printUI("  but no harvesting down.")
printUI("aHarvester 120 2 minFuel1000 startup")
printUI("->Creates a startup program, 120 sec")
printUI("  waiting at home, only 2 runs, min")
printUI("  fuel is set to 1000. Turtle starts.")
printUI("footer")
until askForInputText("Press enter when ready:")==""

term.clear() term.setCursorPos(1,1) iPage=iPage+1
repeat
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Parameter: noCannibalsm")
printUI("  You can use multiple turtles in one")
printUI("  farm w/o them eating each other.")
printUI("  In very rare cases, the hungry ")
printUI("  turtle will stop until solved.")
printUI("Sorry for this long description, as")
printUI("  fall back you can watch the YouTube")
printUI("  video. Enjoy!")
printUI("footer")
until askForInputText("Press enter to START! (stop w/ ctrl+t)")=="" 
end


--------------------------------------- 
-- main loop                          -
---------------------------------------

-- step 1: check starting stuff
ss(1)
local tmpSleep=1
while turtle.getItemCount()==0 do 
  print("Put 1 landmark block in slot 1!") 
  print("Sleeping",tmpSleep,"seconds") 
  sleepDots(tmpSleep)
  tmpSleep=tmpSleep+1
  ss(1)
end


-- step 2: program loop
term.write("Inital turn 0:")

while blnGoOn do
  

  -- step 2.0: need to turn once more?
  if nextTrunTurn then
    -- need to turn once more, because of wall last turn
	nextTrunTurn=false
	if nextTrunRight then
      gr() print("r") nextTrunRight=false
    else
      gl() print("l") nextTrunRight=true
    end	
  end

  -- step 2.1: check for landmarks
  doCompares()
  
  -- step 2.2: handle home base
  if landmarkU then
    -- at my base
	if math.random()<0.95 then 
	  print() term.write("Home. ")
	else
	  print() term.write("I'm home, honey! ")
	end
    print("Fuel:",turtle.getFuelLevel().."/"..cMinFuel)
    print("Dropping inventory:")
	dropInventory()
	if handleTurnCounter() then print("Finished all "..cMaxTurns.." turns.") break end
    print(" Sleeping for "..cSleepTime.." seconds")
	sleepDots(cSleepTime)
	checkCritFuel()
	
  end
   
  -- step 2.3: handle fuel station
  if landmarkD then
    -- at fuel station
	print() print("Fuel station. Fuel:",turtle.getFuelLevel().."/"..cMinFuel)
	while doRefuel() do end
	checkCritFuel()
  end 
  
  -- step 2.4: handle wall/corner
  if landmarkF then
    -- found wall
	nextTrunTurn=true
    if nextTrunRight then
      gr() term.write("r") 
	  if turtle.compare() then 
	    print() term.write("Changing orientation:")
	    gl() term.write("l") gl() print("l") 
	    nextTrunTurn=false
        nextTrunRight=false
	  end
    else  
      gl() term.write("l")
	  if turtle.compare() then 
	    print() term.write("Changing orientation:")
	    gr() term.write("r") gr() print("r")
	    nextTrunTurn=false
        nextTrunRight=true
	  end
    end
    landmarkF=turtle.compare()
  end
  
  -- step 2.5: dig'n move
  if blnNoCannibalism then blnDetectedTurtle=inspectFor(cNoCannibalism,"f") end 
  if blnDetectedTurtle then
    -- found a turtle!!
    evadeStrategy()
  else
    -- regular move
    if not landmarkF then 
	  df() while turtle.suck() do end 
    end
    if not landmarkU and not landmarkD then 
      if blnUp   then du() end while turtle.suckUp()   do end
	  if blnDown then dd() end while turtle.suckDown() do end
    end
    if not landmarkF then 
      if not landmarkD then while turtle.suckUp() do end end
	  if blnNoCannibalism then blnDetectedTurtle=inspectFor(cNoCannibalism,"f") end 
      if not blnDetectedTurtle then gfs() term.write("") end
    end
  end
  
  -- step 2.6: safety check
  while gic(1)~=1 do
	print()
	print("Safety violation!")
	print("  I need exactly 1 landmark block in")
    print("  slot 1 (currently: "..gic(1)..")!")
	term.write("Sleeping for 10 sec ")
	sleepDots(10)
  end
end

 
print("That was quite a bit of work :)")
 os.sleep(0.4)
 print("***************************************")
 print("* Check out YouTube for more videos   *")
 print("* and turtle programs by Kaikaku :)   *")
 print("***************************************")