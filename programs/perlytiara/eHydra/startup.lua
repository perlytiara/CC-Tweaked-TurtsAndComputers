-- eHydra System Startup
-- Quick access to eHydra tools

print("eHydra System v1.0")
print("==================")
print("1. Auto-updater")
print("2. Batch updater") 
print("3. Initialize turtle")
print("4. Deploy turtles")
print("5. Self-update eHydra")
print("6. Restore backups")
print("7. Exit")
print()

write("Select tool [1-7]: ")
local choice = tonumber(read()) or 7

if choice == 1 then
    shell.run("autoupdater")
elseif choice == 2 then
    shell.run("batch_updater")
elseif choice == 3 then  
    shell.run("init")
elseif choice == 4 then
    shell.run("turtle_deployer")
elseif choice == 5 then
    shell.run("self_update")
elseif choice == 6 then
    shell.run("restore_backups")
else
    print("Goodbye!")
end
