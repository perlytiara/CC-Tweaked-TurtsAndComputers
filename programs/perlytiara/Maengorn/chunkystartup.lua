-- Chunky turtle startup program
print("Starting chunky turtle setup...")

-- First, set this program as the permanent startup
if not fs.exists("/startup") then
    print("Setting chunkystartup as permanent startup...")
    fs.copy("disk/chunkystartup", "/startup")
end

-- Copy and run the chunky client program
if fs.exists("/clientchunky") then
    print("Removing existing clientchunky...")
    fs.delete("/clientchunky")
end

if fs.exists("disk/clientchunky") then
    print("Copying clientchunky from disk...")
    fs.copy("disk/clientchunky", "/clientchunky")
    print("Running clientchunky program...")
    shell.run("clientchunky")
else
    print("ERROR: disk/clientchunky not found!")
end
