shell.openTab("shell")

if not commands then -- Attempt to prevent user from running this on non-command comps
	printError("Allium must be run on a command computer")
	return
end

local config = {}
do
    config.updates = {
        allium = true, 
        deps = true
    }
    local temp
    do -- Handle update configuration
        local file = fs.open("cfg/updates.lson", "r")
        if not file then
            temp = {}
        else
            local output = textutils.unserialise(file.readAll())
            if not output then
                temp = {}
            else
                temp = output
            end
        end
    end
    do -- Handle version configuration
        local file = fs.open("cfg/allium.lson", "r")
        if not file then
            printError("Could not read version")
            return
        end
        local output = textutils.unserialise(file.readAll())
        if not output then
            printError("Could not parse version")
            return
        end
        config.version = output.version
    end
    local function fill(t, def) -- 
        local out = {}
        for k, v in pairs(def) do
            if type(v) == "table" then
                out[k] = fill(t[k], v)
            else
                if t[k] ~= nil then
                    out[k] = t[k]
                else
                    out[k] = v
                end
            end
        end
        return out
    end
    config.updates = fill(temp, config.updates)
end

-- Checking user defined updates
if config.updates.allium then
    if fs.exists("cfg/repolist.csh") then -- Checking for a repolist shell executable
        -- Update all plugins and programs on the repolist
        for line in io.lines("cfg/repolist.csh") do
            shell.run(line)
        end
    end
end

-- Filling Dependencies
if config.updates.deps then
    -- Allium DepMan Instance: https://pastebin.com/nRgBd3b6
    print("Updating Dependencies...")
    local didrun = false
    parallel.waitForAll(function()
        didrun = shell.run("pastebin run nRgBd3b6 upgrade https://pastebin.com/raw/fisfxn76 /cfg/deps.lson /lib "..config.version)
    end, 
    function()
        multishell.setTitle(multishell.getCurrent(), "depman")
    end)
    if not didrun then
        printError("Could not update dependencies")
        return
    end
end

-- Clearing the screen
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

-- Running Allium
shell.run("allium.lua "..config.version)

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