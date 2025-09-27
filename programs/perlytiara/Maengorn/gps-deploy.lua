--
--GPS Deploy by neonerZ v1.1
--http://youtube.com/neonerz
--
--This script is originally from BigSHinyToys from ComputerCraft.info
--Original link can be found here:
--http://www.computercraft.info/forums2/index.php?/topic/3088-how-to-guide-gps-global-position-system/page__p__28333#entry28333
--Edited by neonerZ
--
-- Modifications included:
--
-- happydude11209: Line 209 - added logic to check if the server is set to no fuel mode
-- http://www.computercraft.info/forums2/index.php?/topic/9528-gps-deploy-10/page__view__findpost__p__123411
--
-- kittykiller: Line 110 - Bug in the locate code if you were using an existing GPS system to deploy a new one
-- http://www.computercraft.info/forums2/index.php?/topic/9528-gps-deploy-10/page__view__findpost__p__80323
--
-- Mad_Professor: Line 296 - Bug calling computers, monitors. Making people think they needed to load 4 monitors
-- http://www.computercraft.info/forums2/index.php?/topic/9528-gps-deploy-10/page__view__findpost__p__150291
--
--
--
-- In order to use this script you need to setup
-- either a mining turtle, or a standard turtle
-- Mining Turtle: Slot 1 - Fuel
--				  Slot 2 - At least 4 computers
--				  Slot 3 - At least 4 modems
--				  Slot 4 - At lease 1 disk drive
--				  Slot 5 - 1 Disk
-- Standard Turtle: Slot 1 - Fuel
--				  	Slot 2 - At least 4 computers
--				  	Slot 3 - At least 4 modems
--				  	Slot 4 - At lease 4 disk drives
--				 	Slot 5 - 1 Disk		
--
-- (mining turtles will be able to reuse the same
--	disk drive, where-as a standard turtle will leave
--  them and deploy a separate disk drive for each
--	GPS host)
--
-- Default Usage: Place the turtle where you want it
--		deployed facing the SOUTH or 0 direction.
--		Fill the turtle with the required materials
--		above. Then use the command
--
--		gps-deploy x y z
--
--		Where x, y, z is the *absolute* positions of the deploment
--		turtle. By default the turtle will deploy the
--		the GPS array at around y = 254. Add a fourth
--		value to specify the height offset.
--		IMPORTANT: It's crucial you use your absolute coordinates,
--		 (the ones inside the parentheses next to your realitive coordinates)
--		 For Example: If F3 shows X = -6.43534 (-7) or Z = -15.542 (-16)
--		 you'd use -7 and -16 respectively. If you use -6 and -15 all coordinates
--		 that go past 0 in the opposite direction will be off by 1.)
--
--		Example: gps-deploy 1 1 1 20
--
--		Would assume the turtle's start position is 
--		x=1, y=1, z=1 and will deploy the satelite 
--		array at y= 21
--
--neonerZ added features
--	Smart Refilling: Fuel should go in slot 1.
--		If not enough fuel is available script
--		will prompt user for more fuel and wait 30. 
--		Script will estimate how much fuel is needed
--		and try to take only that much (in coal)
--	Item Detection: Script will check slots 2-5
--		for the correct quantity of items. It does
--		*not* check if items are valid
--	GPS Host Coordinates: The script now requires
--		you to enter in the coordinates of the 
--		turtle before launching. This will set
--		the GPS host computers to the correct
--		coordinates.
--	Satelite Array Location: The script allows
--		the user to set an offset for the placement
--		of the four satelites 

-- How heigh up should the satellite be deployed?
-- This is the default value if you don't pass a
-- value to the script. There is a check down below
-- to make sure the user entered values isn't > 254
height = 255

-- need to enable rednet first incase using locate
rednet.open( "right" )

local function printUsage()
	print("")
	print( "Usages:" )
	print( "gps-deploy <x> <y> <z> [height]" )
	print( "Example: gps-deploy 1 1 1 20")
	print( "would deploy the satelite to y=21")
	print( "gps-deploy locate [height]")
	print( "if you have working GPS use this")
	print( "to find out the coords over GPS")
end

-- confirm default height isn't set above 254
-- Check to see if a minimum of 3 values were
-- passed to the script
local tArgs = { ... }

if tArgs[1] == "locate" then
	print ("")
	print ("Locating GPS signal...")
	xcord, ycord, zcord = gps.locate(5, false)
	if xcord==nil then
		print("")
		print ("No GPS signal detected, please rerun manually")
		return
	end
	if tArgs[2] == nil then
		height = tonumber(height)
	else
		height = tonumber(tArgs[2])
	end
	print ("gps-deploy ",xcord," ",ycord," ",zcord," height: ",height)
	xcord = tonumber(xcord)
	ycord = tonumber(ycord)
	zcord = tonumber(zcord)
else
	if #tArgs <= 2 then
		printUsage()
		return
	else
		xcord = tonumber(tArgs[1])
		ycord = tonumber(tArgs[2])
		zcord = tonumber(tArgs[3])	
		if tArgs[4] == nil then
			height = tonumber(height)
		else
			if tonumber(tArgs[4]) > 254 then
				height = tonumber(height)
			else
				height = tonumber(tArgs[4])
			end
		end
	end

end

if height > ycord and height < 256 then
	height = height-ycord
end

if height > 255 then
	height = 255
end

-- check if the script is running on a turtle
-- (original code)
if not turtle then
	print("")
	print("Error: not a turtle")
	return
end

-- move functions
-- (original code)
local mov = {}

mov.forward = function ()
	while not turtle.forward() do
		sleep(1)
	end
	return true
end
mov.back = function ()
	while not turtle.back() do
		sleep(1)
	end
	return true
end
mov.up = function ()
	while not turtle.up() do
		sleep(1)
	end
	return true
end
mov.down = function ()
	while not turtle.down() do
		sleep(1)
	end
	return true
end
mov.place = function ()
	while not turtle.place() do
		sleep(1)
	end
end

local base = nil

-- Check if we have enough fuel
-- we estimate the fuel usage ((height*2)+70) needed to
-- complete the deoployment and then see if we have enough
-- fuel loaded. If we don't, it checks the first slot for
-- available fuel and tries to fill up on it. If it doesn't
-- have enough fuel in there, it prompts the user for more 
-- fuel. It allows 30 seconds for the user to add  fuel
-- (trying to refuel and verify fuel level every second) 
-- and if it doesn't get it's fill within 30 seconds
-- it exits with a message to the user
-- neonerZ
if type(turtle.getFuelLevel()) == "string" then
        print("No-fuel mode")
else
	if turtle.getFuelLevel() < (tonumber(height)*2)+70 then
		while turtle.getFuelLevel() < (tonumber(height)*2)+70 do
			turtle.select(1)
			realcoal=(((tonumber(height)*2)+70)-turtle.getFuelLevel())/80
			if realcoal>=64 then
				coal=64
			else
				coal=math.ceil(realcoal)
			end
			if turtle.refuel(tonumber(coal)) == false then
				fuel=((tonumber(height)*2)+70)-turtle.getFuelLevel()
				print("")
				print("You ran out of fuel in slot 1")
				print("Please insert "..fuel.." fuel or "..realcoal.." coal to continue")
				print("Waiting 30 seconds for fuel or exiting")
				i=0
				while i<=30 do
					sleep(1)
					realcoal=(((tonumber(height)*2)+70)-turtle.getFuelLevel())/80
					if realcoal>=64 then
						coal=64
					else
						coal=math.ceil(realcoal)
					end
					turtle.refuel(tonumber(coal))
					if turtle.getFuelLevel() >= (tonumber(height)*2)+70 then
						print("")
						print("Turtle Fueled")
						i=31
					end
					if i==30 then
						fuel=((tonumber(height)*2)+70)-turtle.getFuelLevel()
						print("")
						print("Not enough fuel provided")
						print("Please provide "..fuel.." fuel or "..realcoal.." coal and try again")
						return
					end
					i=i+1
				end
			end
		end
	end
end
--	if fs.exists("custom") then
--		print("custom program detected")
--		print("please Enter base Station number")
--		local failFlag = false
--		repeat
--			if failFlag then
--				print("Error Not number")
--				print("try again")
--			end
--			write(" > ")
--			base = tonumber(read())
--			failFlag = true
--		until type(base) == "number"
--	end
--	print("Please Place 4 computers in slot two")
--	print("4 modems in slot three")
--	print("if mineing turtle then")
--	print("1 disk drive in slot four")
--	print("if not mineing then")
--	print("4 disk drive in slot four")
--	print("blank floopy disk in slot five")
--	print("press Enter key to continue")
--	while true do
--		local event , key = os.pullEvent("key")
--		if key == 28 then break end
--	end
--	print("Launching")
--end

-- check if the required quantity of items
-- are in the appropriate spots. I'm sure
-- there's a more elegant way of doing this.
-- I don't believe there's a way to check if
-- the items are correct without using compare
monitor=0
modem=0
diskdrive=0
disk=0
print("")
turtle.select(2)
if turtle.getItemCount(2) < 4 then
	print("Please place at least 4 computers into slot two")
	monitor=1
end
turtle.select(3)
if turtle.getItemCount(2) < 4 then
	print("Please place at least 4 modems into slot three")
	modem=1
end
turtle.select(4)
if turtle.getItemCount(2) < 1 then
	print("Please place 1 disk drive into slot four if a -mining turtle-")
	print("Please place 4 disk drives into slot four if a -standard turtle-")
	diskdrive=1
end
turtle.select(5)
if turtle.getItemCount(2) < 1 then
	print("Please place 1 disk into slot five")
	disk=1
end

if monitor == 1 or modem == 1 or diskdrive == 1 or disk == 1 then
	print("Please fix above issues to continue")
	return
end

-- calculate the coordinates of the 4 satelite arrays

newycord=tonumber(ycord)+tonumber(height)

if newycord > 255 then newycord = 255 end

toycordns=newycord
toycordwe=newycord-3

if toycordns >= 255 or toycordwe >= 255 then
	toycordns=255
	toycordwe=252
end

local set = {}
set[1] = {x = tonumber(xcord),z = tonumber(zcord)+3,y = tonumber(toycordns)}
set[2] = {x = tonumber(xcord)-3,z = tonumber(zcord),y = tonumber(toycordwe)}
set[3] = {x = tonumber(xcord),z = tonumber(zcord)-3,y = tonumber(toycordns)}
set[4] = {x = tonumber(xcord)+3,z = tonumber(zcord),y = tonumber(toycordwe)}

-- start the climb up to the correct ycord
while not turtle.up() do
	term.clear()
	term.setCursorPos(1,1)
	term.write("Please get off me")
end
if ycord+tonumber(height) >= 255 then
	while turtle.up() do -- sends it up till it hits max hight
	end
else
	for i = 3,tonumber(height) do
	turtle.up()
	end
end

-- once at the correct height, deploy GPS array
-- this is a mixture of my own code and the
-- original code
for a = 1,4 do
	--forward two
	for i = 1,2 do
		mov.forward()
	end
	turtle.select(2)
	mov.place()
	mov.back()
	turtle.select(3)
	mov.place()
	mov.down()
	mov.forward()
	turtle.select(4)
	mov.place()
	turtle.select(5)
	turtle.drop()
	-- make a custom disk that starts up the gps host application
	-- with the correct coordinates and copy it over. also makes 
	-- makes it a startup script so the computers will
	-- start back up properly after chunk unloading
	fs.delete("disk/startup")
	file = fs.open("disk/startup","w")
	file.write([[
fs.copy("disk/install","startup")
fs.delete("disk/startup")
if fs.exists("disk/custom") then
	fs.copy("disk/custom","custom")
	fs.delete("disk/custom")
end
print("sleep in 10")
sleep(10)
os.reboot()
]])
	file.close()
	if fs.exists("custom") then
		fs.copy("custom","disk/custom")
	end
		file = fs.open("disk/install","w")
		file.write([[
if fs.exists("custom") then
	shell.run("custom","host",]]..set[a]["x"]..","..set[a]["y"]..","..set[a]["z"]..","..(base or "nil")..[[)
else
	shell.run("gps","host",]]..set[a]["x"]..","..set[a]["y"]..","..set[a]["z"]..[[)
end
]])
		file.close()
	turtle.turnLeft()
	mov.forward()
	mov.up()
	turtle.turnRight()
	mov.forward()
	turtle.turnRight()
	peripheral.call("front","turnOn")
	mov.down()
	turtle.suck()
	turtle.select(3)
	turtle.dig()
	mov.up()
	-- reboot would be here
	turtle.turnRight()
	--back 3
	for i = 1,3 do
		mov.forward()
	end
	turtle.turnLeft()
	mov.forward()
	if a == 1 or a == 3 then
		for i = 1,3 do
		mov.down()
		end
	elseif a == 2 or a == 4 then
		for i = 1,3 do
		mov.up()
		end
	end
end

-- goes back down. this is the original code
-- might be worth editing to come down the same
-- amount of spaces it went up, but this should
-- do the job
while turtle.down() do 
end
turtle = tMove
print("")
print("Finished")