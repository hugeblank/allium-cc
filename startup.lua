shell.openTab("shell")
local config = {}
do
    local default = {    
        update = {
            allium = true, 
            deps = true
        },
        version = ""
    }
    local temp
    local file = fs.open("cfg/allium.ltn", "r")
    temp = textutils.unserialize(file.readAll()) -- for use when debugging
    file.close()
    if not temp then
        printError("Could not parse configuration file")
        return
    elseif not temp.version then 
        printError("Could not get Allium version")
        return
    end
    local function fill(t, def)
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
    config = fill(temp, default)
end

if config.update.allium then
    if fs.exists("cfg/repolist.csh") then -- Checking for a repolist shell executable
        -- Update all plugins and programs on the repolist
        for line in io.lines("cfg/repolist.csh") do
            shell.run(line)
        end
    end
end
-- Clearing the screen
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

-- Filling Dependencies
if config.update.deps then
    shell.run("depman.lua upgrade https://gist.githubusercontent.com/hugeblank/7887b55ea62c55f4a1239966bcaa725c/raw/ /cfg/deps.ltn /lib "..config.version)
end
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