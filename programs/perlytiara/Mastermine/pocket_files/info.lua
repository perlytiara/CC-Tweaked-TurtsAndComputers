hub_id = tonumber(fs.open('/hub_id', 'r').readAll())

while true do
    sender, hub_state, _ = rednet.receive('hub_report')
    if sender == hub_id then
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
        term.write('POWER: ')
        if hub_state.on then
            term.setTextColor(colors.green)
            print('ON')
        else
            term.setTextColor(colors.red)
            print('OFF')
        end
        term.setTextColor(colors.white)
        term.write('TURTLES PARKED: ')
        if hub_state.turtles_parked >= hub_state.turtle_count then
            term.setTextColor(colors.green)
        else
            term.setTextColor(colors.red)
        end
        term.write(hub_state.turtles_parked)
    end
end