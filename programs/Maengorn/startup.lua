-- Always copy the clientdig program from disk, overwriting if it exists
print("Starting turtle setup...")

if fs.exists("/clientdig") then
    print("Removing existing clientdig...")
    fs.delete("/clientdig")
end

if fs.exists("disk/clientdig") then
    print("Copying clientdig from disk...")
    fs.copy("disk/clientdig", "/clientdig")
    print("Running clientdig program...")
    shell.run("clientdig")
else
    print("ERROR: disk/clientdig not found!")
end
    
    