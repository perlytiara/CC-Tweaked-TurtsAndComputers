-- Paste Update: zQhqgEfz


SLOT_COUNT = 16

rednet.open('bottom')
screen = peripheral.wrap('monitor_2')

prices = {
    ['minecraft:iron_ingot']= {
        ['value']= 1,
        ['display_name']= 'Iron Ingots'
    },
    ['minecraft:iron_block']= {
        ['value']= 10,
        ['display_name']= 'Iron Blocks'
    },
    ['minecraft:diamond']= {
        ['value']= 14,
        ['display_name']= 'Diamonds'
    },
    ['minecraft:netherite_scrap']= {
        ['value']= 144,
        ['display_name']= 'Netherite Scrap'
    }
}


local width = 23

function writePricesToScreen(prices)
    local textScale = 1
    screen.clear()
    screen.setCursorPos(2, 1)
    screen.write('======= Potato Rates =======')
    
    
    local i = textScale + 3
    for key, val in pairs(prices) do
        screen.setCursorPos(2, i)
        
        displaySize = string.len(val['display_name'] .. val['value'])
        screen.write(val['display_name'])
        
        screen.write(' ')
        screen.write(string.rep(' ', width - displaySize))
        screen.write(' ')
        
        screen.write('1:' .. tostring(val['value']))
        
        i = i + 1
    end
    
    screen.setCursorPos(2, i + 3)
    screen.write('New payment options soon!')
    screen.setCursorPos(2, i + 5)
    screen.write('Prices may change')
end

function writeLimitToScreen(millisRemaining)
    screen.clear()
    screen.setCursorPos(2, 1)
    screen.write('Too Fast!')
    
    screen.setCursorPos(2, 3)
    screen.write('You can purchase again in:')
    screen.setCursorPos(2, 4)
    screen.write(string.format('%d seconds', millisRemaining / 1000))
end

function getFirstItemIndex()
    for i = 1, SLOT_COUNT, 1 do
        turtle.select(i)
        if turtle.getItemDetail() ~= nil then
            return i
        end
    end

    return nil
end



function calculatePayout(item)
    
    local price = prices[item['name']]['value']
    if price ~= nil then    
        return price * item['count']
    end
    return false
end


tickRate = .5
resetTimer = os.epoch('utc')
resetTime = 1000 * 60 * 5

saturation = 0
saturationLimit = 420

writePricesToScreen(prices)

print('POS Starting Up...')
while true do
    if (saturation < saturationLimit) then
        if turtle.suckUp(12) then
            idx = getFirstItemIndex()
            item = turtle.getItemDetail(idx)
            turtle.select(idx)

            if (prices[item['name']] ~= nil) then
                local payout = calculatePayout(item)
                saturation = saturation + payout

                turtle.drop()
                rednet.broadcast(payout)
            else
                print('Invalid Payment')
                turtle.dropUp()
            end
        end
    else
        writeLimitToScreen(resetTime - (os.epoch('utc') - resetTimer))
    end

    
    if ((os.epoch('utc') - resetTimer) > resetTime) then
        writePricesToScreen(prices)
        saturation = 0
        resetTimer = os.epoch('utc')
    end
    
    os.sleep(tickRate)
end