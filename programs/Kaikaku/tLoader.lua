--{program="tLoader",version="1.10",date="2024-10-22"}
---------------------------------------
-- tLoader            by Kaikaku
-- 2024-10-22, v1.10   UI fix
-- 2021-04-02, v1.01  tClear added
-- 2021-03-20, v1.00  initial
-- TUAPv1FU (tLoader)
---------------------------------------

---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Loader program to pastebin get
--   all the other releazed programs. 
-- If in-program info is insufficient
--   check out YouTube for more details.


---------------------------------------
---- ASSUMPTIONS ---------------------- 
---------------------------------------
-- Atm mainly meant for turtles
-- 


---------------------------------------
---- VARIABLES: template -------------- 
---------------------------------------
local cVersion  ="v1.10"              
local cPrgName  ="tLoader"          
local cMinFuel  =110                  
local cSleepTime=0.4                 
local cMaxTurns =-1                   
local turnCounter =0                  
local turnsRemaining =cMaxTurns       
local harvestedStuff=0                
local harvestedStuffTotal=0           

local blnAskForParameters =true       
local blnShowUsage        =false    
local blnDebugPrint       =false
local blnTurtle                       
local isComputer          =false      
local baseColor=colors.blue			  


---------------------------------------
---- VARIABLES: specific -------------- 
---------------------------------------
local blnAll  = false
local blnAllA = false
local blnAllT = false
local blnAllB = false
local blnDelete = false 
local singleProg1 = ""
local singleProg2 = ""
local singleProg3 = ""
local counter = 0

---------------------------------------
---- Data: specific -------------------
---------------------------------------

--     id, name, pastebin, applicability[t/c/b]
local array={}
array={
       "a","AESeeds",        "stXEtJ6C","t",
       "a","CabReactor",     "knYniUQx","t",
       "a","EndoFeeder",     "bMHsGY06","t",
       "a","FlowerPot",      "EiBtxqUT","t",
	   "a","Harvester",      "ZVc6H649","t",
	   "a","MilkPower",      "e8bs7VnN","t",
       "a","TreeFarm",       "Qn008fPa","t",
	   
       "b","9x9",            "a5nWDnK6","t",
       "b","Dome",           "jEAYUJdZ","t",
	   "b","DonkeySanctuary","Xc98RnqU","t",
       "b","Door2x3",        "BvavMNTW","t",
	   "b","Drone",          "A35d84ge","b",
	   "b","Chandelier",     "bMky9MzP","t",
	   "b","HalfTimberHouse","hxeZ5Wui","t",
	   "b","Head",           "HP3AW3sd","t",
       "b","Mansion",        "PfdurUkb","t",
       "b","MobFarm",        "unPPhDpQ","t",
	   "b","Shuttle",        "L1UQ3he3","t",
       "b","TownHouse",      "FHw76UHP","t",
	   
       "t","Clear",          "07653J4E","t",
       "t","Fireworks",      "UYm0CCQ7","t",
       "t","Loader",         "TUAPv1FU","b",
       "t","Platform",       "fbyxVzSX","t",
       "t","Send",           "h3xcC9S1","b",
       "t","WaitFor",        "9vzPCd4T","b"}

---------------------------------------
---- Early UI functions ---------------
---------------------------------------
local function swapColors()
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

local function coloredTextAt(inputText,outputRow,outputCol,textColor,backColor)
-- writes and colors text to coordinates
local oldRow, oldCol = term.getCursorPos()
local oldTextColor=term.getTextColor() 
local oldBackColor=term.getBackgroundColor()
if textColor==nil then textColor=term.getTextColor() end
if backColor==nil then backColor=term.getBackgroundColor() end

  term.setTextColor(textColor)
  term.setBackgroundColor(backColor)
  term.setCursorPos(outputRow,outputCol)
  term.write(inputText)
  term.setCursorPos(oldRow, oldCol)
  term.setTextColor(oldTextColor)
  term.setBackgroundColor(oldBackColor)
end

---------------------------------------
---- tArgs ----------------------------
---------------------------------------
local tArgs = {...}   
term.clear() term.setCursorPos(1,1)

-- header 
if #tArgs~=0 then
  blnAskForParameters=false
  term.clear() term.setCursorPos(1,1) 
  printUI("header")
  printUI(""..cPrgName..", "..cVersion..", by Kaikaku. Enjoy!")
  printUI("line")
  coloredTextAt(cPrgName,2,2,baseColor) 
  print("Starting...")
end

for t=1,#tArgs do
  if string.lower(tArgs[t])=="all" then 
    blnAll=true 
  elseif string.lower(tArgs[t])=="a" then 
	blnAllA=true
  elseif string.lower(tArgs[t])=="t" then 
    blnAllT=true
  elseif string.lower(tArgs[t])=="b" then 
    blnAllB=true
  elseif string.lower(tArgs[t])=="del" then 
    blnDelete=true
  elseif string.lower(tArgs[t])=="delte" then 
    blnDelete=true
  elseif singleProg1=="" then
    singleProg1 = tArgs[t]
  elseif singleProg2=="" then
    singleProg2 = tArgs[t]
  else
    singleProg3 = tArgs[t]
  end
end


---------------------------------------
-- basic functions for turtle control -
---------------------------------------

local function spd(s,blnForward)
  if s==nil then s=turtle.currentSlot() end
  if blnForward==nil then blnForward=true end
  ss(s) pd() if blnForward then gf() end
end
local function spu(s,blnForward)
  if s==nil then s=turtle.currentSlot() end
  if blnForward==nil then blnForward=true end
  ss(s) pu() if blnForward then gf() end
end
local function spf(s,blnBack)
  if s==nil then s=turtle.currentSlot() end
  if blnBack==nil then blnBack=true end
  ss(s) pf() if blnBack then gb() end
end

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

local function askForNumber(askText, minValue, maxValue)
-- gets entered data, ensures it's a number and returns it
-- keeps asking if entry is not a number
-- adapts to min and max values
-- allways writes in screen line 13 (last for turtles)
-- calls askForInputText
local blnReask=true
local returnNumber=nil
if minValue==nil then minValur=1 end
if maxValue==nil then maxValue=100 end
if askText==nil then askText="Key in number and press Enter: " end
  while blnReask do
   term.setCursorPos(1,13)
    returnNumber=askForInputText(askText)
    if returnNumber==nil then 
      blnReask=true 
    else  
      returnNumber=tonumber(returnNumber)
      if returnNumber==nil then
        blnReask=true
	  else
	    returnNumber=math.floor(returnNumber)
	    if returnNumber>maxValue then returnNumber=maxValue end
	    if returnNumber<minValue then returnNumber=minValue end
	    blnReask=false
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
if askText==nil then askText="Press key to START! (stop w/ ctrl+t)   " end
  tmpKey=341
  while tmpKey>=340 and tmpKey<=346 do -- ctrls, alts, shifts
    term.write(askText) tmpEvent, tmpKey = os.pullEvent("key")
    if tmpKey==nil then tmpKey=341 end -- win
  end
  return tmpKey
end

local function checkFuel()
  local tmp=turtle.getFuelLevel()
  return tmp
end

local function checkTurtle(blnOnlyIdentify) 
if blnOnlyIdentify==nil then blnOnlyIdentify=false end
-- turtle?
  local turtleOk, turtleVal = pcall(checkFuel)
  if not turtleOk then
    blnTurtle=false
	if not blnOnlyIdentify then
      term.clear() term.setCursorPos(1,1)
      printUI("header")
      printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
      printUI("line")
      printUI("This is a turtle program.")
      printUI("  Please, execute it with a turtle!")
      printUI("footer")
	
	  coloredTextAt(cPrgName,2,2,colors.red)
      error()
	end
  else
    blnTurtle=true
  end
end

local function sleepDots(sec, duration)
if sec==nil then sec=10 end
if sec<1 then return end
if duration==nil then duration=1 end -- shorten durtation for more dots

  for i=1,sec-1 do
    sleep(1*duration)
    term.write(".")
  end
  
  sleep(1)
  print(".")
end

local function debugPrint(str)
 if blnDebugPrint then print(str) end
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


local function getFirstEmptySlot(startAt) 
if startAt==nil then startAt=1 end
if startAt>16 or startAt<1 then return nil end
  
  for i=startAt,16,1 do
    if gic(i)==0 then return i end  
  end
  for i=1,startAt,1 do
    if gic(i)==0 then return i end  
  end
  return nil
end

local function identifyTool(toolSide)  
-- returns name of tool at side toolSide
-- returns no_tool if there is none
-- requires at least one empty slot for tool check (throws error)
if toolSide==nil then toolSide="right" end
if toolSide~="right" and toolSide~="r" then toolSide="left" end
local slotNumber = getFirstEmptySlot()
local slotSelected=turtle.getSelectedSlot()
local toolName="no_tool"

  if slotNumber==nil then error("Couldn't find empty slot to check tool on side '"..toolSide.."'!") end
  ss(slotNumber)
  -- step 1: get name
  if toolSide=="right" or toolSide=="r" then
    turtle.equipRight()
  else
    turtle.equipLeft()  
  end
  -- step 2: get name
  local data = turtle.getItemDetail()
  if data~=nil then toolName=data.name end
  -- step 3: re-equipget name
  if toolSide=="right" or toolSide=="r" then
    turtle.equipRight()
  else
    turtle.equipLeft()  
  end
  ss(slotSelected)
  return toolName
end


-- pre description ------------------------
local function arrangeArray(inputArray, startAt, endAt, widthAt, maxRows, maxCharacters, numSpacers)
-- prints array in two columns
if widthAt==nil then widthAt=4 end  -- how many array itmes belong to one "object"
if widthAt<1 then widthAt=4 end
if startAt==nil then startAt=1 end  -- start with this "object"
if startAt<1 then startAt=1 end
if endAt==nil then endAt=#inputArray/widthAt end -- end at this "object"
if endAt>#inputArray*widthAt then endAt=#inputArray/widthAt end
if maxRows==nil then maxRows=10 end  -- so many rows to display
if maxRows<1 then maxRows=5 end
if maxCharacters==nil then maxCharacters=19 end  -- so many chars in one column (rest is cut off)
if maxCharacters<1 then maxCharacters=19 end
local fillerA=" "--"-"
if numSpacers==nil then numSpacers=0 end  -- so many spaces between both columns
if numSpacers<1 then numSpacers=0 end
local fillerB=" "--"x"

local outputArray={}
local j=1
local tmpString=""
local tmpSpaces=""
local tmpSpacer=""

  for i=1,maxCharacters,1 do
    tmpSpaces=tmpSpaces..fillerA
  end
  for i=1,numSpacers,1 do
    tmpSpacer=tmpSpacer..fillerB
  end

  for i=startAt*widthAt-(widthAt-1),endAt*widthAt,widthAt do
      
      --print(inputArray[i]..inputArray[i+1])
	  tmpString=inputArray[i]..inputArray[i+1]..tmpSpaces
	  tmpString=string.sub(tmpString,1,maxCharacters)
	  if outputArray[j]==nil then outputArray[j]="" tmpString=tmpString..tmpSpacer end
	  outputArray[j]=outputArray[j]..tmpString
	  j=j+1
	  if j>maxRows then j=1 end
  end

  return outputArray
end

local function printArray(iArray)
  for i=1,#iArray,1 do
    term.write(i) 
	if iArray[i]~=nil then print(iArray[i]) else print() end
  end

end

local function countProgramTypes()
local countA=0
local countB=0
local countT=0

  for i=1,#array,4 do
    if array[i]=="a" then
	  countA=countA+1
	elseif array[i]=="b" then
	  countB=countB+1
	elseif array[i]=="t" then
	  countT=countT+1
	end
  end
  return countA,countB,countT,countA+countB+countT

end



------------------------------------------------------------------------------
-- main: description ---------------------------------------------------------
------------------------------------------------------------------------------
checkTurtle(true)

local iPage=0
if blnAskForParameters then
term.clear() term.setCursorPos(1,1)
local iPageMax=3                                    
local event, key, isHeld  
local blnLoop=true                               

term.clear() term.setCursorPos(1,1) iPage=iPage+1
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax.."+)")
printUI("line")
--       1234567890123456789012345678901234567
printUI("This program can load all other")
printUI("  programs released by Kaikaku.")
printUI("No need to remember any other")
printUI("  pastebin codes than: TUAPv1FU")
printUI("You can select single programs")
printUI("  or groups of programs (e.g. all")
printUI("  builder programs). Or load by ")
printUI("  paramter call: tLoader bDrone")
printUI("footer")

coloredTextAt(cPrgName,2,2,baseColor)
coloredTextAt("TUAPv1FU",25,7,baseColor)
coloredTextAt("tLoader bDrone",19,11,baseColor)
pressKeyNoSpecials("Press key for next (stop w/ ctrl+t)   ")   



term.clear() term.setCursorPos(1,1) iPage=iPage+1
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax.."+)")
printUI("line")
--       1234567890123456789012345678901234567
printUI("How to remember TUAPv1FU?")
printUI("  T  = To                    It took ")
printUI("  U  = YOU                   quite a ")
printUI("  A  = All                   while   ")
printUI("  P  = Programs              and a   ")
printUI("  v  = version               temp ban")
printUI("  1  = one                   to get  ")
printUI("  FU = FU**?!                this  ")
--       1234567890123456789012345678901234567
printUI("footer")

coloredTextAt(cPrgName,2,2,baseColor)
coloredTextAt("TUAPv1FU",18,4,baseColor)
coloredTextAt("T",4,5,baseColor) coloredTextAt("T",9,5,baseColor)
coloredTextAt("U",4,6,baseColor) coloredTextAt("YOU",9,6,baseColor)
coloredTextAt("A",4,7,baseColor) coloredTextAt("A",9,7,baseColor)
coloredTextAt("P",4,8,baseColor) coloredTextAt("P",9,8,baseColor)
coloredTextAt("v",4,9,baseColor) coloredTextAt("v",9,9,baseColor)
coloredTextAt("1",4,10,baseColor) coloredTextAt("one",9,10,baseColor)
coloredTextAt("FU",4,11,baseColor) coloredTextAt("FU",9,11,baseColor)


pressKeyNoSpecials("Press key for next (stop w/ ctrl+t)   ")


term.clear() term.setCursorPos(1,1) iPage=iPage+1
local aa,bb,tt,ss = countProgramTypes()
printUI("header")
printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax.."+)")
printUI("line")
--       1234567890123456789012345678901234567
printUI("Select load mode:")
printUI("  1 = select one from list (1)")
printUI("  2 = all automation programs ("..aa..")")
printUI("  3 = all building programs ("..bb..")")
printUI("  4 = all tool programs ("..tt..")")
printUI("  5 = all programs ("..(#array/4)..")")
printUI("  ")
printUI("  d = delete old programs (off)")
printUI("footer")
term.write("Press key 1,2,3,4,5 to select mode") 

coloredTextAt(cPrgName,2,2,baseColor)
coloredTextAt("Select load mode",2,4,baseColor)
coloredTextAt("1",4,5,baseColor)  coloredTextAt("list", 24,5,baseColor)
coloredTextAt("2",4,6,baseColor)  coloredTextAt("a",    12,6,colors.green)
coloredTextAt("3",4,7,baseColor)  coloredTextAt("b",    12,7,colors.red)
coloredTextAt("4",4,8,baseColor)  coloredTextAt("t",    12,8,baseColor)
coloredTextAt("5",4,9,baseColor)  coloredTextAt("all",   8,9,baseColor)
coloredTextAt("d",4,11,baseColor) coloredTextAt("(off)",28,11,baseColor)

while blnLoop do -- option selection example --<< example to check for 1,2,3,4
  event, key, isHeld = os.pullEvent("key")
  if key~=nil then
    if keys.getName(key)=="one" 
	or keys.getName(key)=="two" 
	or keys.getName(key)=="three" 
	or keys.getName(key)=="four"  
	or keys.getName(key)=="five" then
      blnLoop=false
	elseif keys.getName(key)=="d" then
	  if blnDelete then
	    blnDelete=false
        coloredTextAt("(off)",28,11,baseColor)
	  else
	    blnDelete=true
        coloredTextAt("(on) ",28,11,baseColor)
	  end
    end
  end
end

if keys.getName(key)=="two" then blnAllA=true
elseif keys.getName(key)=="three" then blnAllB=true
elseif keys.getName(key)=="four" then blnAllT=true
elseif keys.getName(key)=="five" then blnAll=true
end

if keys.getName(key)=="one" then
local cRowCount=8
local iNumber
local iNumberLast
local blnSelectionDone=false

--local function arrangeArray(inputArray, startAt, endAt, widthAt, maxRows, maxCharacters, numSpacers)
  local testArray = arrangeArray(array,1,nil,4,#array/4,16,1)
  local numberPages = math.ceil(#testArray/cRowCount)
  iPageMax=iPageMax+numberPages
  for j=1,#array/4,cRowCount do
    term.clear() term.setCursorPos(1,1) iPage=iPage+1 
    printUI("header")
    printUI(""..cPrgName..", "..cVersion..", by Kaikaku ("..iPage.."/"..iPageMax..")")
    printUI("line")
	coloredTextAt(cPrgName,2,2,baseColor)

    iNumber=1
	iNumberLast=1
    for i=j,j+cRowCount-1,1 do
	  
      if testArray[i]~= nil then 
	    printUI("  "..iNumber.." = "..testArray[i]) 
		coloredTextAt(iNumber,4,3+iNumber,baseColor)
		if string.sub(testArray[i],1,1)=="a" then coloredTextAt("a" ,8,3+iNumber,colors.green) 
		elseif string.sub(testArray[i],1,1)=="b" then coloredTextAt("b" ,8,3+iNumber,colors.red) 
		elseif string.sub(testArray[i],1,1)=="t" then coloredTextAt("t" ,8,3+iNumber,colors.blue) 
		end
		iNumberLast=iNumberLast+1
	  else 
	    printUI() 
	  end
	  iNumber=iNumber+1
    end
    printUI("footer")
    if iPage<iPageMax then
      term.write("Select program (1-"..(iNumberLast-1).."), other key = next ") 
	else 
      term.write("Select program (1-"..(iNumberLast-1).."), other key = EXIT ") 
	end
	
    blnLoop=true
    local iArray
    while blnLoop do 
      event, key, isHeld = os.pullEvent("key")
      if key~=nil then
        if keys.getName(key)=="one" and iNumberLast>1 then
          iArray=1
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true 
	    elseif keys.getName(key)=="two" and iNumberLast>2 then
          iArray=1+1*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true 
	    elseif keys.getName(key)=="three" and iNumberLast>3 then
          iArray=1+2*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true
	    elseif keys.getName(key)=="four" and iNumberLast>4 then
          iArray=1+3*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true
	    elseif keys.getName(key)=="five" and iNumberLast>5 then
          iArray=1+4*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true
	    elseif keys.getName(key)=="six" and iNumberLast>6 then
          iArray=1+5*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true
	    elseif keys.getName(key)=="seven" and iNumberLast>7 then
          iArray=1+6*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true
	    elseif keys.getName(key)=="eight" and iNumberLast>8 then
          iArray=1+7*4
	      iArray=iArray+(iPage-3-1)*4*cRowCount
	      singleProg1=array[iArray]..array[iArray+1] 
	      blnSelectionDone=true
        end
	    blnLoop=false
      end
    end
	if blnSelectionDone then break end
  end
end
end

   
---------------------------------------
---- MAIN -----------------------------
---------------------------------------
term.clear() term.setCursorPos(1,1)

---- step 1: pastebin get ----  
print("step 1: pastebin get...")
local i=1

while array[i]~=nil do
  if blnAll 
  or (blnAllA and array[i]=="a") 
  or (blnAllT and array[i]=="t") 
  or (blnAllB and array[i]=="b") 
  or string.lower(singleProg1)==string.lower(array[i]..array[i+1]) 
  or string.lower(singleProg2)==string.lower(array[i]..array[i+1]) 
  or string.lower(singleProg3)==string.lower(array[i]..array[i+1]) then
	print("-- "..array[i]..array[i+1].." --")
    if blnDelete then 
	  print("Deleting current version")
	  shell.run("delete "..array[i]..array[i+1]) 
	end
    print(shell.run("pastebin get "..array[i+2].." "..array[i]..array[i+1]))
	counter=counter+1
	sleep(cSleepTime)
  end
  i=i+4
end

if counter~=0 then
  sleepDots(6,0.2)
  ---- step 2: finishing stuff / report ----
  term.clear() term.setCursorPos(1,1)
  print("step 2: report")
  if counter==1 then
    print("1 program downloaded/updated/tried :)")
  else
    print(counter.." programs downloaded/updated/tried :)")
  end
end

print()
printUI("header") 
       --1234567890123456789012345678901234567
printUI("If in-program info is insufficient,")
printUI("you can check out YouTube for further")
printUI("explanations. Just search for the")
printUI("program name and ComputerCraft.")
printUI("Enjoy! Kaikaku ")
coloredTextAt("Kaikaku",9,9,baseColor)
printUI("footer")
