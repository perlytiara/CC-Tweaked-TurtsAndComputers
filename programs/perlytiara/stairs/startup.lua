-- startup.lua - Auto-start stairs client on turtle boot
if turtle then
  print("Starting stairs client...")
  shell.run("client")
else
  print("Not a turtle - startup skipped")
end
