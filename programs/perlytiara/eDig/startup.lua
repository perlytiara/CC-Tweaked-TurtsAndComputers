-- startup.lua - Auto-start eDig client on turtle boot
if turtle then
  print("Starting eDig client...")
  shell.run("eDig/client")
else
  print("Not a turtle - startup skipped")
end