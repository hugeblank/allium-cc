shell.openTab("shell")
local debug = false
if fs.exists("cfg/debug.cfg") then
    file = fs.open("cfg/debug.cfg", "r")
    debug = load("return "..file.readAll())() -- for use when debugging, so auto-update script doesn't get triggered
    file.close()
end
if not debug then
    if fs.exists("cfg/repolist.csh") then -- Checking for a repolist shell executable
        -- Update all plugins and programs on the repolist
        for line in io.lines("cfg/repolist.csh") do
            shell.run(line)
        end
    else
        printError("No valid repo file found")
    end
end
-- Installing some critical libraries if they aren't already
local libs = {
    semver = "hugeblank/semparse/master/semver.lua",
    gget = "hugeblank/qs-cc/master/src/gget.lua",
    json = "rxi/json.lua/master/json.lua",
    nap = "hugeblank/qs-cc/master/src/nap.lua"
}
for k, v in pairs(libs) do
    if not fs.exists("/lib/"..k..".lua") then
        shell.run("wget https://raw.github.com/"..v, "/lib/"..k..".lua")
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