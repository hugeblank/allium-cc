shell.openTab("shell")

-- Allium version
local allium_version = "0.9.0-pr1"

if not commands then -- Attempt to prevent user from running this on non-command comps
	printError("Allium must be run on a command computer")
	return
end

--[[
    DEFAULT ALLIUM CONFIGS ### DO NOT CHANGE THESE ###
    Configurations can be changed in /cfg/allium.lson
]]
local default = {
    version = allium_version, -- Allium's version
    import_timeout = 5, -- The maximum amount of time it takes to wait for a plugin dependency to provide its module.
    label = "<&r&dAll&5&h[[Killroy wuz here.]]&i[[https://www.youtube.com/watch?v=XqZsoesa55w&t=15s]]i&r&dum&r> ", -- The label the loader uses
    updates = { -- Various auto-update configurations. Server operators may want to change this from the default
        deps = true, -- Automatically update dependencies
        allium = true -- Automatically update allium
    }
}

local config = {}
do -- Configuration parsing
	local file = fs.open("cfg/allium.lson", "r")
	local function verify_cfg(input, default, index)
		for givenField, givenValue in pairs(input) do -- input key, value
			for expectedField, expectedValue in pairs(default) do -- standard key, value
				if type(givenValue) == "table" and type(expectedValue) == "table" then
					if not verify_cfg(givenValue, expectedValue, givenField..".") then
						return false
					end
				elseif givenField == expectedField and type(givenValue) ~= type(expectedValue) then
					printError("Invalid config option "..(index or "")..givenField.." (expected "..type(expectedValue)..", got "..type(givenValue)..")")
					return false
				end
			end
		end
		return true
	end
	local function fill_missing(file, default)
        local out = {}
        if not file then file = {} end
        for k, v in pairs(default) do
            if type(v) == "table" then
                out[k] = fill_missing(file[k], v)
            else
                if type(file[k]) == "nil" then
                    out[k] = v
                else
                    out[k] = file[k]
                end
            end
        end
        for k, v in pairs(file) do
            if out[k] == nil then
                out[k] = v
            end
        end
        return out
    end
    local output = {}
	if file then -- Could not read file
        output = textutils.unserialise(file.readAll()) or {}
        file.close()
	end
	if verify_cfg(output, default) then -- Make sure none of the config opts are invalid (skips missing ones)
        config = fill_missing(output, default) -- Fill in the remaining options that are missing
        if config.version ~= allium_version then
            config.version = allium_version
            file = fs.open("cfg/allium.lson", "w")
            if file then
                file.write(textutils.serialise(config))
                file.close()
            end
        end
	else
		return
	end
end

-- Checking Allium/Plugin updates
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
    print("Checking for dependency updates...")
    local didrun = false
    parallel.waitForAll(function()
        didrun = shell.run("pastebin run nRgBd3b6 upgrade https://pastebin.com/raw/fisfxn76 /cfg/deps.lson /lib "..allium_version)
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
multishell.setTitle(multishell.getCurrent(), "Allium")
os.run(_ENV, "allium.lua", config)

-- Removing all captures
for _, side in pairs(peripheral.getNames()) do -- Finding the chat module
	if peripheral.getMethods(side) then
		for _, method in pairs(peripheral.getMethods(side)) do
			if method == "uncapture" then
                peripheral.call(side, "uncapture")
				break
			end
		end
    end
end

-- Rebooting or exiting
print("Rebooting in 5 seconds")
print("Press any key to cancel")
parallel.waitForAny(function() repeat until os.pullEvent("char") end, function() sleep(5) os.reboot() end)