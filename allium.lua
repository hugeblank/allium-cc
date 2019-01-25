-- Allium by hugeblank
paintutils.drawImage(paintutils.loadImage("allium.nfp"), 40, 2) -- Draw the Allium image on the side
term.setBackgroundColor(colors.black) -- Reset terminal and cursor
term.setTextColor(colors.white)
term.setCursorPos(1, 1)
-- Announce loading has begun
print("Loading Allium")
print("Initializing API")

local mName = "<&r&dAll&5&h(Hugeblank was here. Hi.)&i(https://www.youtube.com/watch?v=PomZJao7Raw)i&r&dum&r>" --bot title
local raisin = require("raisin.raisin")
local color = require("color") --Sponsored by roger109z
local allium = {} -- API table
local group = {thread = raisin.group.add(1), command = raisin.group.add(2)}
local plugins = {} -- Plugin table

allium.assert = function(condition, message, level)
	if not condition then error(message, level) end
end

local assert = allium.assert

allium.sanitize = function(name)
	if name then
		return name:lower():gsub(" ", "-")
	end
end

allium.tell = function(name, message, botname) --allium.tell as documented in README
    if not (type(message) == "string" or type(message) == "table") then
        return false
    end
	local test
	if type(message) == "table" then
		_, test = commands.tellraw(name, color.format(table.concat(message, "\n")))
	else
		_, test = commands.tellraw(name, color.format((function(botname) if botname == true then return "" elseif botname then return botname.."&r " else return mName.."&r " end end)(botname)..message))
    end
    return textutils.serialise(test)
end

allium.getPlayers = function()
	local didexec, input = commands.exec("list")
	local out = {}
	if not didexec then 
		local _, users = commands.testfor("@a")
		for i = 1, #users do
			out[#out+1] = string.sub(users[i], 7, -1)
		end
	else
		for user in string.gmatch(input[2], "%S+") do
			if user:find(",") then
				out[#out+1] = user:sub(1, -2)
			else
				out[#out+1] = user
			end
		end
	end
	return out
end

allium.getInfo = function(plugin) -- Get the information of all plugins, or a single plugin
	assert(plugin == nil or type(plugin) == "string", "Invalid argument #1 (string expected, got"..type(plugin)..")", 3)
	if plugin then
		plugin = allium.sanitize(plugin)
	end
	assert(command == nil or type(command) == "string", "Invalid argument #2 (string expected, got"..type(command)..")", 3)
	if command then
		assert(plugin, "Invalid argument #1 (string expected, got"..type(plugin)..")", 3)
	end
	if plugin then
		assert(plugins[plugin], "Invalid argument #1 (plugin "..plugin.." does not exist)", 3)
		if command then
			assert(plugins[plugin].commands[command], "Invalid argument #2 (command "..command.." does not exist in plugin "..plugin..")", 3)
		end
	end
	if plugin then
		local res = {[plugin] = {}}
		for name, command_data in pairs(plugins[plugin].commands) do
			res[plugin][name] = {info = command_data.info, usage = command_data.usage}
		end
		return res
	else
		local res = {}
		for p_name, plugin in pairs(plugins) do
			res[p_name] = {}
			for c_name, command_data in pairs(plugin.commands) do
				res[p_name][c_name] = {info = command_data.info, usage = command_data.usage}
			end
		end
		return res
	end
end

allium.getName = function(plugin)
	assert(type(plugin) == "string", "Invalid argument #1 (string expected, got "..type(plugin)..")", 3)
	if plugins[plugin] then
		return plugins[plugin].name
	end
end

allium.register = function(p_name, fullname)
	assert(type(p_name) == "string", "Invalid argument #1 (string expected, got "..type(p_name)..")", 3)
	local real_name = allium.sanitize(p_name)
	assert(plugins[real_name] == nil, "Invalid argument #1 (plugin exists under name "..real_name..")", 3)
	plugins[real_name] = {threads = {}, commands = {}, name = fullname or p_name}
	local funcs = {}
	local this = plugins[real_name]
	
	funcs.command = function(c_name, command, info, usage) -- name: name | command: executing function | info: help information | usage: string for improper inputs
		assert(type(c_name) == "string", "Invalid argument #1 (string expected, got "..type(c_name)..")", 3)
		local real_name = allium.sanitize(c_name)
		assert(type(command) == "function", "Invalid argument #2 (function expected, got "..type(command)..")", 3)
		assert(this.commands[real_name] == nil, "Invalid argument #2 (command exists under name "..real_name.." for plugin "..this.name..")", 3)
		assert(type(info) == "string", "Invalid argument #3 (string expected, got "..type(info)..")", 3)
		this.commands[real_name] = {command = command, info = info, usage = usage}
	end

	funcs.thread = function(thread)
		assert(type(thread) == "function", "Invalid argument #1 (function expected, got "..type(thread)..")", 3)
		return raisin.thread.add(thread, 0, group.thread)
	end

	funcs.getPersistence = function(name)
		if fs.exists("persistence.ltn") then
			local fper = fs.open("persistence.ltn", "r")
			local tpersist = textutils.unserialize(fper.readAll())
			fper.close()
			if not tpersist[p_name] then
				tpersist[p_name] = {}
			end
			if type(name) == "string" then
				return tpersist[p_name][name]
			end
		end
		return false
	end
	
	funcs.setPersistence = function(name, data)
		local tpersist
		if fs.exists("persistence.ltn") then
			local fper = fs.open("persistence.ltn", "r")
			tpersist = textutils.unserialize(fper.readAll())
			fper.close()
		end
		if not tpersist[p_name] then
			tpersist[p_name] = {}
		end
		if type(name) == "string" then
			tpersist[p_name][name] = data
			local fpers = fs.open("persistence.ltn", "w")
			fpers.write(textutils.serialise(tpersist))
			fpers.close()
			return true
		end
		return false
	end

	return funcs
end

-- Finding the chat module
for _, side in pairs(peripheral.getNames()) do
	if peripheral.getMethods(side) then
		for _, method in pairs(peripheral.getMethods(side)) do
			if method == "capture" then
				allium.side = side
				peripheral.call(side, method, "^!")
				break
			end
		end
	end
	if allium.side then break end
end

if not allium.side then
	printError("Cannot find chat module")
	return
end

_G.allium = allium -- Globalizing Allium API


do -- Plugin loading process
	print("Loading plugins...")
	local dir = shell.dir()
	if fs.exists(dir.."plugins") then
		for _, plugin in pairs(fs.list(dir.."plugins")) do
			if not fs.isDir(dir.."plugins/"..plugin) then
				local file, err = loadfile(dir.."plugins/"..plugin)
				if not file then
					printError(err)
				else
					local suc, err = pcall(file)
					if not suc then
						printError(err)
					end
				end
			end
		end
	end
end

local main = function()
	while true do
		local _, message, _, name = os.pullEvent("chat_capture") --Pull chat messages
		if string.find(message, "!") == 1 then --are they for allium?
			args = {}
			for k in string.gmatch(message, "%S+") do --put all arguments spaced out into a table
				args[#args+1] = k
			end
			local cmd = args[1]:sub(2, -1) -- Strip the !
			table.remove(args, 1) --remove the first parameter given (!command)
			local cmd_exec
			if not string.find(cmd, ":") then --did they not specify the plugin source?
				for p_name, plugin in pairs(plugins) do --nope... gonna have to find it for them.
					for c_name, command in pairs(plugin.commands) do
						if c_name == cmd then --well I found it, but there may be more...
							cmd_exec = {command = command, plugin = p_name} --split into command function, source
							break
						end
					end
					if cmd_exec then break end -- Exit this loop, we've found the command we're looking for
				end
			else --hey they did! +1 karma.
				local splitat = string.find(cmd, ":")
				local p_name, c_name = string.sub(cmd, 1, splitat-1), string.sub(cmd, splitat+1, -1)
				if plugins[p_name] then --check plugin existence
					if plugins[p_name].commands[c_name] then --check command existence
						cmd_exec = {command = plugins[p_name].commands[c_name], plugin = p_name} --split it into the function, and then the source
					end
				end
			end
			if cmd_exec then --is there really a command?
				local data = { -- Infrequently used data to pass onto the command being executed
					usage = function(name) allium.tell(name, "&c"..cmd.." "..cmd_exec.command.usage) end,
					autofill = cmd_exec.command.usage
				}
				local function exec_command()
					local stat, err = pcall(cmd_exec.command.command, name, args, data) --Let's execute the command in a safe environment that won't kill allium
					if stat == false then--it crashed...
						allium.tell(name, "&4"..cmd.." crashed! This is likely not your fault, but the developer's. Please contact the developer of &a"..cmd_exec.plugin.."&4. Error:\n&c"..err)
						printError(cmd.." errored. Error:\n"..err)
					end
				end
				raisin.thread.add(exec_command, 0, group.command)
    		else --this isn't even a valid command...
	    		allium.tell(name, "&6Invalid Command, use &c&g(!allium:help)!help&r&6 for assistance.") --bleh!
    		end
	    end
	end
end

raisin.thread.add(main, 0)

if not fs.exists("persistence.ltn") then --In the situation that this is a first installation, let's add persistence.ltn
	local fpers = fs.open("persistence.ltn", "w")
	fpers.write("{}")
	fpers.close()
end

print("Allium started.")
allium.tell("@a", "&eHello World!")
sleep()
raisin.manager.run()
