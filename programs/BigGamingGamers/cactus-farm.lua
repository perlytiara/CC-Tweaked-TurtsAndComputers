while (true) do
    if (redstone.getInput("bottom")) then
        redstone.setOutput("front", true)
        redstone.setOutput("back", true)
        redstone.setOutput("right", true)
        redstone.setOutput("left", true)
        sleep(.05)
        redstone.setOutput("front", false)
        redstone.setOutput("back", false)
        redstone.setOutput("right", false)
        redstone.setOutput("left", false)
        sleep(.05)
    else
        sleep(1)
    end
end

-- pastebin get QuswHq2H startup