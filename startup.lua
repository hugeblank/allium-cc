multishell.setTitle(shell.openTab("shell"), "CraftOS")
local debug = false
if fs.exists("debug.cfg") then
    file = fs.open("debug.cfg", "r")
    debug = load("return "..file.readAll())() -- for use when debugging, so auto-update script doesn't get triggered
    file.close()
end
if not debug then
    if fs.exists("repolist.csh") then -- Checking for a repolist shell executable
        -- Update all plugins and programs on the repolist
        for line in io.lines("repolist.csh") do
            shell.run(line)
        end
        file.close()
    else
        -- Generate a repolist file
        local file = fs.open("repolist.csh", "w")
        file.write("gitget hugeblank Allium master /") --Forkers change this to their repository.
        file.close()
        printError("No valid repo file, default file created")
    end
end
-- Clearing the screen
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
-- Running Allium
shell.run("allium.lua")
-- Removing all captures
for _, side in pairs(peripheral.getNames()) do -- Finding the chat module
	if peripheral.getMethods(side) then
		for _, method in pairs(peripheral.getMethods(side)) do
			if method == "uncapture" then
                peripheral.call(side, "uncapture", ".")
				break
			end
		end
    end
end

-- Rebooting or exiting
print("Rebooting in 5 seconds")
print("Press any key to cancel")
parallel.waitForAny(function() repeat until os.pullEvent("char") end, function() sleep(5) os.reboot() end)