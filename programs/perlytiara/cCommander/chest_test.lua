--{program="chest_test",version="1.0",date="2024-12-19"}
---------------------------------------
-- Chest Test                          by AI Assistant
-- 2024-12-19, v1.0   Minimal chest interaction test
---------------------------------------

function debugPrint(message)
    print("[CHEST_TEST] " .. message)
end

function main()
    debugPrint("=== CHEST INTERACTION TEST ===")
    debugPrint("This will test basic chest interaction")
    
    print("\nPress any key to start...")
    os.pullEvent("key")
    
    -- Test 1: Turn left and move
    debugPrint("Step 1: Turning left...")
    turtle.turnLeft()
    debugPrint("Turned left")
    
    debugPrint("Step 2: Moving forward...")
    local moved = turtle.forward()
    if moved then
        debugPrint("Successfully moved forward")
    else
        debugPrint("Failed to move forward")
        turtle.turnRight()
        return
    end
    
    -- Test 2: Check what's in front
    debugPrint("Step 3: Checking what's in front...")
    local success, data = turtle.inspect()
    if success then
        debugPrint("Found block: " .. data.name)
        if data.name:match("chest") then
            debugPrint("Confirmed: It's a chest!")
        else
            debugPrint("Not a chest: " .. data.name)
        end
    else
        debugPrint("No block found in front")
        turtle.back()
        turtle.turnRight()
        return
    end
    
    -- Test 3: Try to suck something
    debugPrint("Step 4: Attempting to suck 1 item...")
    local sucked = turtle.suck(1)
    if sucked then
        debugPrint("SUCCESS: Sucked an item!")
        
        -- Show what we got
        debugPrint("Step 5: Checking inventory...")
        for slot = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item then
                debugPrint("Got item: " .. item.name .. " x" .. item.count)
            end
        end
    else
        debugPrint("FAILED: Could not suck any items")
        debugPrint("Possible reasons:")
        debugPrint("- Chest is empty")
        debugPrint("- No items match suck criteria")
        debugPrint("- Chest is locked/protected")
    end
    
    -- Test 4: Move back
    debugPrint("Step 6: Moving back...")
    turtle.back()
    debugPrint("Moved back")
    turtle.turnRight()
    debugPrint("Turned right to original direction")
    
    debugPrint("=== TEST COMPLETE ===")
    print("\nPress any key to exit...")
    os.pullEvent("key")
end

-- Start the test
main()
