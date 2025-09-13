---@meta
-- CC:Tweaked minimal API stubs for LuaLS to stop undefined-field warnings.
-- This file is for editor tooling only; it does not run at runtime.

---@diagnostic disable: duplicate-set-field, lowercase-global

-- sleep is a global in CC
---@param time number
function sleep(time) end

-- os extensions
os = os or {}
---@param filter? string
---@return string, ...
function os.pullEvent(filter) end
---@param filter? string
---@return string, ...
function os.pullEventRaw(filter) end
---@param time number
function os.sleep(time) end
---@return string|nil
function os.getComputerLabel() end
---@param label string|nil
function os.setComputerLabel(label) end
function os.shutdown() end
function os.reboot() end
function os.exit() end

-- http
http = http or {}
---@param url string
---@return any, string?
function http.get(url) end

-- fs
fs = fs or {}
---@param path string
---@return boolean
function fs.exists(path) end
---@param path string
function fs.makeDir(path) end
---@param path string, mode string
---@return any
function fs.open(path, mode) end
---@param path string
---@return string[]
function fs.list(path) end
---@param path string
---@return boolean
function fs.isDir(path) end
---@param path string
function fs.delete(path) end

-- shell/read
---@return string
function read() end
---@param s string
function write(s) end

-- peripheral
peripheral = peripheral or {}
---@param side string
---@return table
function peripheral.wrap(side) end
---@param side string
---@param method string
---@return any
function peripheral.call(side, method, ...) end

-- redstone
redstone = redstone or {}
---@param side string
---@param state boolean
function redstone.setOutput(side, state) end
---@param side string
---@return boolean
function redstone.getInput(side) end
-- some scripts alias redstone as rs
rs = rs or redstone

-- turtle (minimal)
turtle = turtle or {}
function turtle.select(slot) end
function turtle.place() end
function turtle.placeUp() end
function turtle.placeDown() end
function turtle.dig() end
function turtle.digUp() end
function turtle.digDown() end
function turtle.forward() end
function turtle.up() end
function turtle.down() end
function turtle.turnLeft() end
function turtle.turnRight() end
function turtle.getFuelLevel() end
function turtle.refuel(n) end
function turtle.getItemDetail(slot) end
function turtle.getItemCount(slot) end
---@param count? integer
function turtle.drop(count) end
---@param count? integer
function turtle.dropUp(count) end
---@param count? integer
function turtle.dropDown(count) end
---@param count? integer
function turtle.suckUp(count) end
---@param count? integer
function turtle.suckDown(count) end

-- gps
gps = gps or {}
---@param timeout? number
---@param debug? boolean
---@return number, number, number
function gps.locate(timeout, debug) end

-- vector
vector = vector or {}
---@class Vec3
---@field x number
---@field y number
---@field z number
---@param x? number
---@param y? number
---@param z? number
---@return Vec3
function vector.new(x, y, z) end

-- term
term = term or {}
function term.clearLine() end

-- bit32
bit32 = bit32 or {}
function bit32.band(a, b, ...) end
function bit32.bor(a, b, ...) end
function bit32.bxor(a, b, ...) end
function bit32.bnot(a) end
function bit32.lshift(x, disp) end
function bit32.rshift(x, disp) end
function bit32.arshift(x, disp) end
function bit32.rrotate(x, disp) end
function bit32.lrotate(x, disp) end


