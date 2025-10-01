-- Startup script for newly deployed turtles
if not fs.exists("/clientdig") then
    -- First boot - copy files from disk
    if fs.exists("disk/clientdig") then
        fs.copy("disk/clientdig", "/clientdig")
        print("Copied clientdig from disk")
    else
        print("ERROR: No clientdig found on disk!")
        return
    end
    
    if fs.exists("disk/startup") then
        fs.copy("disk/startup", "/startup")
        print("Copied startup from disk")
    end
    
    print("Setup complete, rebooting...")
    os.sleep(1)
    os.reboot()
else
    -- Files already installed, run the client
    shell.run("clientdig")
end