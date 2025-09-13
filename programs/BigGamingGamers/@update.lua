-- Alias: delegates to update.lua in this collection
local target = "/programs/BigGamingGamers/update.lua"
if fs.exists(target) then
    shell.run(target, table.unpack(arg))
else
    print("Missing " .. target .. " — ensure files are installed.")
end


