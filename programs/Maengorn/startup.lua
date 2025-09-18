-- Always copy the clientdig program from disk, overwriting if it exists
if fs.exists("/clientdig") then
    fs.delete("/clientdig")
end
fs.copy("disk/clientdig", "/clientdig")

-- Run the clientdig program
shell.run("clientdig")
    
    