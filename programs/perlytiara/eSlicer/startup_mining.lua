-- eSlicer Mining Turtle Startup
-- Deploys mining client from disk

print("eSlicer Mining Startup v1.0")

-- Check if we're loading from disk
if fs.exists("disk/mining_client") then
    print("Loading mining client from disk...")
    
    -- Copy the client program to local storage
    if fs.exists("/mining_client") then
        fs.delete("/mining_client")
    end
    
    fs.copy("disk/mining_client", "/mining_client")
    
    -- Set this as permanent startup (in case of reboot during operation)
    if not fs.exists("/startup") then
        print("Setting up permanent startup...")
        local startupFile = fs.open("/startup", "w")
        startupFile.write([[
-- eSlicer Mining Turtle Auto-Startup
if fs.exists("/mining_client") then
    shell.run("mining_client")
else
    print("Error: mining_client not found!")
    print("Please redeploy from server.")
end
]])
        startupFile.close()
    end
    
    -- Run the mining client
    print("Starting mining operations...")
    shell.run("mining_client")
    
else
    print("Error: No disk found or mining_client missing!")
    print("Please ensure disk is properly configured.")
end
