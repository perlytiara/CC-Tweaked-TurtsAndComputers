-- eSlicer Chunky Turtle Startup  
-- Deploys chunky client from disk

print("eSlicer Chunky Startup v1.0")

-- Check if we're loading from disk
if fs.exists("disk/chunky_client") then
    print("Loading chunky client from disk...")
    
    -- Copy the client program to local storage
    if fs.exists("/chunky_client") then
        fs.delete("/chunky_client")
    end
    
    fs.copy("disk/chunky_client", "/chunky_client")
    
    -- Set this as permanent startup (in case of reboot during operation)
    if not fs.exists("/startup") then
        print("Setting up permanent startup...")
        local startupFile = fs.open("/startup", "w")
        startupFile.write([[
-- eSlicer Chunky Turtle Auto-Startup
if fs.exists("/chunky_client") then
    shell.run("chunky_client")
else
    print("Error: chunky_client not found!")
    print("Please redeploy from server.")
end
]])
        startupFile.close()
    end
    
    -- Run the chunky client
    print("Starting chunk loading operations...")
    shell.run("chunky_client")
    
else
    print("Error: No disk found or chunky_client missing!")
    print("Please ensure disk is properly configured.")
end
