shell.openTab("shell")
-- Checking for a repolist shell executable
if fs.exists("repolist.csh") then
    -- Update all plugins and programs on the repolist
    local file = fs.open("repolist.csh", "r")
    for k in file.readLine do
        shell.run(k)
    end
    file.close()
else
    -- Generate a repolist file
    local file = fs.open("repolist.csh", "w")
    file.write("gitget hugeblank/Allium /") --Forkers change this to their repository.
    file.close()
    printError("No valid repo file, default file created")
end
-- Clearing the screen
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
-- Running Allium
shell.run("allium.lua")
-- Removing all captures
local exit = false
for _, side in pairs(peripheral.getNames()) do
	if peripheral.getMethods(side) then
		for _, method in pairs(peripheral.getMethods(side)) do
			if method == "uncapture" then
				peripheral.call(side, method, ".")
                exit = true
                break
			end
		end
    end
    if exit then break end
end
-- Rebooting or exiting
print("Rebooting in 3 seconds")
print("Press any key to cancel")
parallel.waitForAny(function() repeat until os.pullEvent("char") end, function() sleep(3) os.reboot() end)