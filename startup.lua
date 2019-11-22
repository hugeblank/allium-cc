-- Allium version
-- x.x.x-pr = unstable, potential breaking changes
local allium_version = "0.10.0"

local path = "/"
local firstrun = false
for str in string.gmatch(shell.getRunningProgram(), ".+[/]") do
	path = path..str
end

if not commands then -- Attempt to prevent user from running this on non-command comps
	printError("Allium must be run on a command computer")
	return
end

--[[
    DEFAULT ALLIUM CONFIGS ### DO NOT CHANGE THESE ###
    Configurations can be changed in /cfg/allium.lson
]]
local default = {
    label = "<&r&dAll&5&h(hugeblank <3 AJR)&i(https://www.youtube.com/watch?v=Vy1JwiXHwI4)i&r&dum&r> ", -- The label the loader uses
    import_timeout = 5, -- The maximum amount of time it takes to wait for a plugin dependency to provide its module.
    updates = { -- Various update configurations.
        notify = { -- Configurations to trigger notifications when parts of Allium are ready for an update
            dependencies = true, -- Notify when dependencies need updating
            plugins = true, -- Notify when plugins need updating
            allium = true -- Notify when allium needs updating
        },
        repo = { -- Repo specific information for Allium in case you want to use a fork
            user = "hugeblank", -- User to check updates from
            branch = "master", --  Branch/Tag to check updates from
            name = "Allium" -- Name of repo to check updates from
        }
    }
}

--load settings from file
local loadSettings = function(file, default)
    assert(type(file) == "string", "file must be a string")
    if not fs.exists(file) then
        firstrun = true
        local setting = fs.open(file,"w")
        setting.write(textutils.serialise(default))
        setting.close()
        return default
    end
    local setting = fs.open(file, "r")
    local config = setting.readAll()
    setting.close()
    config = textutils.unserialise(config)
    if type(config) ~= "table" then
        return default
    end
    local checkForKeys
    checkForKeys = function(default, test)
        for key, value in pairs(default) do
            if type(test[key]) ~= type(value) then
                test[key] = value
            elseif type(test[key]) == "table" then
                checkForKeys(value, test[key])
            end
        end
    end
    checkForKeys(default, config)
    return config
end

local config, up = loadSettings(fs.combine(path, "cfg/allium.lson"), default), {}
local depman
up.check = {}
up.run = {}

if config.updates.notify.dependencies then
    local depget = http.get("https://raw.githubusercontent.com/hugeblank/allium-depman/046ce3e231eab81ac15275ffe8dd76ab6f2f8274/instance.lua")
    if depget then
        local contents = depget.readAll()
        depget.close()
        local depargs = { -- Depman args minus the task which can be inserted into the first index
            path,
            "https://raw.githubusercontent.com/hugeblank/allium-depman/master/listing.lson",
            fs.combine(path, "/cfg/dependencies.lson"),
            fs.combine(path, "/lib"),
            allium_version
        }
        depman = function(task)
            local out = {}
            local temp = {_G.print, _G.printError, _G.error} -- The good ol' switcheroo
            local function cache(...)
                for i = 1, #({...}) do
                    out[#out+1] = ({...})[i]
                    temp[1](out[#out])
                end
            end
            _G.print, _G.printError, _G.error = cache, cache, cache -- Best CS map don't @ me (jk never played it)
            local result, err = pcall(load(contents, "Depman", nil, _ENV), task, table.unpack(depargs))
            out[#out+1] = err
            _G.print, _G.printError, _G.error = table.unpack(temp)
            return result, out
        end
        up.check.dependencies = function()
            return depman("scan")
        end
        up.run.dependencies = function()
            depman("upgrade")
        end
    end
end


-- First run installation of utilities
if firstrun then
    print("Welcome to Allium! Doing some first-run setup and then we'll be on our way.")
    fs.delete(fs.combine(path, "/lib"))
    if depman then
        depman("upgrade")
    end
end
local github, json = require("lib.nap")("https://api.github.com"), require("lib.json")

if config.updates.notify.allium then
    up.check.allium = function()
        local repo = config.updates.repo
        local jsonresponse = github.repos[repo.user][repo.name].commits[repo.branch]({
            method = "GET"
        })
        if jsonresponse then
            local out = jsonresponse.readAll()
            jsonresponse.close()
            return json.decode(out).sha
        else
            return false, "No response from github"
        end
    end
    up.run.allium = function(sha)
        local repo = config.updates.repo
        local null = function() end
        os.run({
            term = {
                write=null,
                setCursorPos=null,
                getCursorPos=function() return 1, 1 end
            },
            print = null,
            write = null,
            shell = {
                getRunningProgram = function() return fs.combine(path, "/lib/gget.lua") end
            }
        },
        fs.combine(path, "/lib/gget.lua"),
        repo.user,
        repo.name,
        repo.branch
        )
        local file = fs.open(fs.combine(path, "/cfg/version.lson"), "w")
        if file then
            file.write(textutils.serialise({sha = sha}))
            -- Not adding version because we're outdated now. We've been replaced.
            file.close()
        else
            printError("Could not write to file. Is the disk full?")
            return
        end
    end
end

-- Final firstrun stuff
if firstrun then
    print("Finalizing installation")
    local sha, v_file = up.check.allium(), fs.open(fs.combine(path, "/cfg/version.lson"), "w")
    if v_file then
        v_file.write(textutils.serialise({sha = sha, version = allium_version}))
        v_file.close()
    end
    local m_file = fs.open(fs.combine(path, "/cfg/metadata.lson"), "w")
    if m_file then
        m_file.write("{}")
        m_file.close()
    end
    if not (m_file and v_file) then
        printError("Could not write to file. Is the disk full?")
        return
    end
end

local r_file = fs.open(fs.combine(path, "/cfg/version.lson"), "r")
if r_file then
    local v_data = textutils.unserialise(r_file.readAll())
    r_file.close()
    if v_data then
        config.version, config.sha = v_data.version, v_data.sha
    else
        printError("Could not parse version data, did you mess with ./cfg/version.lson?")
        print("If you're updating from a prior version, delete allium.config, reboot, and you should be good.")
        return
    end
    if not config.version then
        local w_file = fs.open(fs.combine(path, "/cfg/version.lson"), "w")
        if w_file then -- Reapply version because it was removed by the last version
            v_data.version = allium_version
            config.version = allium_version
            w_file.write(textutils.serialise(v_data))
            w_file.close()
        else
            printError("Could not write to file. Is the disk full?")
            return
        end
    end
else
    printError("Could not read version data, did you delete ./cfg/version.lson?")
    print("If you're updating from a prior version, delete allium.config, reboot, and you should be good.")
    return
end

-- Clearing the screen
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

-- Running Allium
multishell.setTitle(multishell.getCurrent(), "Allium")
local s, e = pcall(os.run, _ENV, fs.combine(path, "allium.lua"), config, up)
if not s then
    printError(e)
end

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