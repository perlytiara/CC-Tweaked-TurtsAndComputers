if not fs.exists("/startup") then
    fs.copy("disk/clientdig", "/startup")
    fs.copy("disk/clientdig", "/clientdig")
    shell.run("clientdig")
    end
    
    