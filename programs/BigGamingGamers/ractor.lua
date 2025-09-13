local BUFFER_MAX = 10000000 
local MIN_THRESHOLD = .5
local MAX_THRESHOLD = .8

print("Software Control is On...")
local reactor = peripheral.wrap("back")
while(true) do
    local currentEnergy = reactor.getEnergyStored() / BUFFER_MAX
    if (currentEnergy < MIN_THRESHOLD) then
        reactor.setActive(true)
    elseif(currentEnergy > MAX_THRESHOLD) then
        reactor.setActive(false)
    end
    sleep(.5)
end