shell.openTab("shell")
local debug = false -- for use when debugging, auto-update script doesn't get triggered
-- Checking for a repolist shell executable
if not debug then
    if fs.exists("repolist.csh") then
        -- Update all plugins and programs on the repolist
        for line in io.lines("repolist.csh") do
            shell.run(line)
        end
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
                peripheral.call(allium.side, "uncapture", ".")
				break
			end
		end
    end
end

-- Rebooting or exiting
print("Rebooting in 5 seconds")
print("Press any key to cancel")
parallel.waitForAny(function() repeat until os.pullEvent("char") end, function() sleep(5) os.reboot() end)