-- Allium by hugeblank
local version = "0.6.0"
local label = "<&r&dAll&5&h[[Hugeblank was here. Hi.]]&i[[https://www.youtube.com/watch?v=hjGZLnja1o8]]i&r&dum&r>" --bot title
local raisin, color, semver = require("lib.raisin.raisin"), require("lib.color"), require("lib.semver") -- color.lua sponsored by roger109z
local allium, plugins, group = {}, {}, {thread = raisin.group.add(1) , command = raisin.group.add(2)} 

local function print(noline, ...) -- Magical function that takes in a table and changes the text color/writes at the same time
	local words = {...}
	if type(noline) ~= "boolean" then
		table.insert(words, 1, noline)
		noline = false
	end
	local text_color = term.getTextColor()
	for i = 1, #words do
		if type(words[i]) == "number" then
			term.setTextColor(words[i])
		elseif type(words[i]) == "table" then
			print(unpack(words[i]))
		else
			write(words[i])
		end
	end
	if not noline then
		write("\n")
	end
	term.setTextColor(text_color)
end

local function deep_copy(table, list) -- Recursively copy a module
	out = {}
	if not list then
		list = {table}
	end
	for name, func in pairs(table) do
		local matched, i = false, 1
		while not matched do
			if i == #list or list[i] == func then
				matched = true
			end
			i = i+1
		end
		if type(func) == "table" and not matched then
			list[#list+1] = func
			out[name] = deep_copy(func, list)
		else
			out[name] = func
		end
	end
	return out
end

local cli = {
	info = {true, "[", colors.lime, "I", colors.white, "] "}, 
	warn = {true, "[", colors.yellow, "W", colors.white, "] "},
	error = {true, "[", colors.red, "E", colors.white, "] "}
}

do -- Allium image setup <3
	multishell.setTitle(multishell.getFocus(), "Allium")
	term.clear()
	local x, y = term.getSize()
	paintutils.drawImage(paintutils.loadImage("cfg/allium.nfp"), x-7, 2) -- Draw the Allium image on the side
	local win = window.create(term.current(), 1, 1, x-9, y, true) -- Create a window to prevent text from writing over the image
	term.redirect(win) -- Redirect the terminal
	term.setCursorPos(1, 1)
	term.setBackgroundColor(colors.black) -- Reset terminal and cursor
	term.setTextColor(colors.white)
	print(cli.info, "Loading ", colors.magenta, "All", colors.purple, "i", colors.magenta, "um")
	print(cli.info, "Initializing API")
end

allium.assert = function(condition, message, level)
	if not level then 
		level = 0
	end
	if not condition then error(message, level+3) end
end

local assert = allium.assert

allium.sanitize = function(name)
	assert(type(name) == "string", "Invalid argument #1 (expected string, got "..type(name)..")")
	return name:lower():gsub(" ", "_"):gsub("[^a-z0-9_]", "")
end

allium.tell = function(name, message, alt_name)
	assert(type(name) == "string", "Invalid argument #1 (expected string, got "..type(name)..")")
    assert(type(message) == "string" or type(message) == "table", "Invalid argument #2 (expected string or table, got "..type(message)..")")
	local test
	message = message:gsub("\"", "\\\"")
	if type(message) == "table" then
		_, test = commands.tellraw(name, color.format(table.concat(message, "\n")))
	else
		_, test = commands.tellraw(name, color.format((function(alt_name) if alt_name == true then return "" elseif alt_name then return alt_name.."&r " else return label.."&r " end end)(alt_name)..message))
    end
    return textutils.serialise(test)
end

allium.execute = function(name, command)
	os.queueEvent("chat_capture", command, "", name)
end

allium.getPlayers = function()
	local didexec, input = commands.exec("list")
	local out = {}
	if not didexec then 
		local _, users = commands.exec("testfor @a")
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

allium.forEachPlayer = function(func)
	assert(type(func) == "function", "Invalid argument #1 (function expected, got "..type(func)..")")
	local threads = {}
	local players = allium.getPlayers()
	local mentioned, error = false
	for i = 1, #players do 
		threads[#threads+1] = function()
			local suc, err = pcall(func, players[i])
			if not suc and not mentioned then
				error = err
				mentioned = true
			end
		end
	end
	parallel.waitForAll(unpack(threads))
	if not mentioned then
		return true
	else
		return false, error
	end
end

allium.getInfo = function(plugin) -- Get the information of all plugins, or a single plugin
	assert(plugin == nil or type(plugin) == "string", "Invalid argument #1 (nil or string expected, got"..type(plugin)..")")
	if plugin then
		plugin = allium.sanitize(plugin)
		assert(plugins[plugin], "Invalid argument #1 (plugin "..plugin.." does not exist)")
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
	assert(type(plugin) == "string", "Invalid argument #1 (string expected, got "..type(plugin)..")")
	if plugins[plugin] then
		return plugins[plugin].name
	end
end

allium.getVersion = function(plugin)
	assert(type(plugin) == "string", "Invalid argument #1 (string expected, got "..type(plugin)..")")
	if plugins[plugin] then
		return plugins[plugin].version
	end
end

allium.register = function(p_name, version, fullname)
	assert(type(p_name) == "string", "Invalid argument #1 (string expected, got "..type(p_name)..")")
	local real_name = allium.sanitize(p_name)
	assert(plugins[real_name] == nil, "Invalid argument #1 (plugin exists under name "..real_name..")")
	local version, rule = semver.parse(version)
	if not rule then rule = "" end
	assert(type(version) == "table", "Invalid argument #2 (malformed SemVer, breaks rule "..rule..")")
	plugins[real_name] = {threads = {}, commands = {}, name = fullname or p_name, version = version}
	local funcs = {}
	local this = plugins[real_name]
	
	funcs.command = function(c_name, command, info, usage) -- name: name | command: executing function | info: help information | usage: table of strings for improper inputs
		-- Add a command for the user to execute
		assert(type(c_name) == "string", "Invalid argument #1 (string expected, got "..type(c_name)..")")
		local real_name = allium.sanitize(c_name)
		assert(type(command) == "function", "Invalid argument #2 (function expected, got "..type(command)..")")
		assert(this.commands[real_name] == nil, "Invalid argument #2 (command exists under name "..real_name.." for plugin "..this.name..")")
		assert(type(info) == "string" or type(info) == "table" or not info, "Invalid argument #3 (string, table, or nil expected, got "..type(info)..")")
		if type(info) == "string" then info = {info} end
		assert(info[1], "Invalid argument #3 (info formatted table expected)")
		this.commands[real_name] = {command = command, info = info, usage = usage}
	end

	funcs.thread = function(thread)
		-- Add a thread that repeatedly iterates
		assert(type(thread) == "function", "Invalid argument #1 (function expected, got "..type(thread)..")")
		return raisin.thread.wrap(raisin.thread.add(thread, 0, group.thread), group.thread)
	end

	funcs.module = function(container)
		-- A container for all external functionality that other programs can utilize
		assert(type(container) == "table", "Invalid argument #1 (table expected, got "..type(container)..")")
		this.module = container
		funcs.module = container
	end

	funcs.getPersistence = function(name)
		assert(type(name) ~= "nil", "Invalid argument #1 (expected anything but nil, got "..type(name)..")")
		if fs.exists("cfg/persistence.ltn") then
			local fper = fs.open("cfg/persistence.ltn", "r")
			local tpersist = textutils.unserialize(fper.readAll())
			fper.close()
			if not tpersist[real_name] then
				tpersist[real_name] = {}
			end
			if type(name) == "string" then
				return tpersist[real_name][name]
			end
		end
		return false
	end
	
	funcs.setPersistence = function(name, data)
		assert(type(name) ~= "nil", "Invalid argument #1 (expected anything but nil, got "..type(name)..")")
		local tpersist
		if fs.exists("cfg/persistence.ltn") then
			local fper = fs.open("cfg/persistence.ltn", "r")
			tpersist = textutils.unserialize(fper.readAll())
			fper.close()
		end
		if not tpersist[real_name] then
			tpersist[real_name] = {}
		end
		if type(name) == "string" then
			tpersist[real_name][name] = data
			local fpers = fs.open("cfg/persistence.ltn", "w")
			fpers.write(textutils.serialise(tpersist))
			fpers.close()
			return true
		end
		return false
	end

	funcs.import = function(p_name) -- request the API from a specific plugin
		assert(type(p_name) == "string", "Invalid argument #1 (string expected, got "..type(p_name)..")")
		p_name = allium.sanitize(p_name)
		local timer = os.startTimer(5)
		repeat
			local e = {os.pullEvent()}
		until (e[1] == "timer" and e[2] == timer) or (plugins[p_name] and plugins[p_name].module)
		if not plugins[p_name] and plugins[p_name].module then
			return false
		end
		for being_loaded, loaded_plugins in pairs(loaded) do -- Plugin being loaded, plugins that the plugin being loaded has loaded
			if being_loaded == p_name then
				for i = 1, #loaded_plugins do
					if loaded_plugins[i] == real_name then
						return false
					end
				end
				break
			end
		end
		if loaded[real_name] then
			loaded[real_name][#loaded[real_name]+1] = p_name
		else
			loaded[real_name] = {p_name}
		end
		return deep_copy(plugins[p_name].module)
	end

	return funcs
end

allium.version = semver.parse(version)

allium.verify = function(min, max)
	local smin, smax = min, max
	local min, max = semver.parse(min), semver.parse(max)
	if smin and not min then return false end
	if smax and not max then return false end
	if min and allium.version < min then
		return false
	end
	if max and allium.version > max then
		return false
	end
	return true
end

for _, side in pairs(peripheral.getNames()) do -- Finding the chat module
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
	print(cli.warn, "Allium could not find chat module")
end

_G.allium = allium -- Globalizing Allium API

do -- Plugin loading process
	print(cli.info, "Loading plugins")
	local loader_group = raisin.group.add(1)
	local function scopeDown(dir)
		for _, plugin in pairs(fs.list(dir)) do
			if (not fs.isDir(dir.."/"..plugin)) and plugin:find(".lua") then
				local file, err = loadfile(dir.."/"..plugin, _ENV)
				if not file then
					print(cli.error, err)
				else
					local thread = function()
						local suc, err = pcall(file)
						if not suc then
							print(cli.error, err)
						end
					end
					raisin.thread.add(thread, 0, loader_group)
				end
			elseif fs.isDir(dir.."/"..plugin) then
				scopeDown(dir.."/"..plugin)
			end
		end
	end
	local dir = shell.dir()
	if fs.exists(dir.."/plugins") then
		scopeDown(dir.."/plugins")
	else
		fs.makeDir(dir.."/plugins")
	end
	raisin.manager.runGroup(loader_group)
end

local interpreter = function() -- Main command interpretation thread
	while true do
		local _, message, _, name, uuid = os.pullEvent("chat_capture") -- Pull chat messages
		if message:find("!") == 1 then -- Are they for allium?
			args = {}
			for k in message:gmatch("%S+") do -- Put all arguments spaced out into a table
				args[#args+1] = k
			end
			for i = 1, #args do
				if args[i] then
					local quote = args[i]:sub(1, 1):find("\"") -- Find quotes within arguments
					if quote then
						local j, end_quote = i
						if args[i]:sub(-1, -1) ~= "\"" and #args[i] ~= 1 then -- If the quote isn't found in the same argument
							while not (end_quote or j == #args) do -- Find the quote that matches with this one
								j = j+1
								end_quote = args[j]:sub(-1, -1):find("\"")
							end
						end
						if end_quote then -- If there was an end quote
							local message, size = "", 0
							local function merge(str)
								if #message+#str > size then
									message = message..str.." "
									size = #message
								end
							end
							merge(args[i]:sub(2, -1))
							merge(table.concat(args, " ", i+1, j-1))
							args[i] = message..args[j]:sub(1, -2) -- Overwrite the first argument
							for k = j, i+1, -1 do -- Then remove everything that was used
								table.remove(args, k)
							end
						end
					end
				end
			end
			local cmd = args[1]:sub(2, -1) -- Strip the !
			table.remove(args, 1) -- Remove the first parameter given (!command)
			local cmd_exec
			if not cmd:find(":") then -- Did they not specify the plugin source?
				for p_name, plugin in pairs(plugins) do -- Nope... gonna have to find it for them.
					for c_name, data in pairs(plugin.commands) do
						if c_name == cmd then --well I found it, but there may be more...
							cmd_exec = {data = data, plugin = p_name, command = c_name} -- Split into command function, plugin name, and command name
							break
						end
					end
					if cmd_exec then break end -- Exit this loop, we've found the command we're looking for
				end
			else -- Hey they did! +1 karma.
				local splitat = cmd:find(":")
				local p_name, c_name = cmd:sub(1, splitat-1), cmd:sub(splitat+1, -1)
				if plugins[p_name] then --check plugin existence
					if plugins[p_name].commands[c_name] then --check command existence
						cmd_exec = {data = plugins[p_name].commands[c_name], plugin = p_name, command = c_name} -- Split it into the function, and then the source
					end
				end
			end
			if cmd_exec then -- Is there really a command?
				local data = { -- Infrequently used data to pass onto the command being executed
					error = function(text) 
						local str = "Invalid or missing parameter(s)"
						if cmd_exec.data.usage then
							str = "!"..cmd.." "..cmd_exec.data.usage
						end
						allium.tell(name, "&c"..(text or str))
					end,
					usage = cmd_exec.data.usage,
					uuid = uuid
				}
				local function exec_command()
					local stat, err = pcall(cmd_exec.data.command, name, args, data) --Let's execute the command in a safe environment that won't kill allium
					if stat == false then--it crashed...
						allium.tell(name, "&4!"..cmd_exec.command.." crashed! This is likely not your fault, but the developer's. Please contact the developer of &a"..cmd_exec.plugin.."&4. Error:\n&c&h[[Click here to place error into chat prompt, so you may copy it if needed for an issue report]]&s[["..err.."]]"..err.."&r")
						print(cli.warn, cmd.." | "..err)
					end
				end
				raisin.thread.add(exec_command, 0, group.command)
    		else --this isn't even a valid command...
	    		allium.tell(name, "&6Invalid Command, use &c&g[[!allium:help]]!help&r&6 for assistance.") --bleh!
    		end
	    end
	end
end

local scanner = function() -- Login/out scanner thread
    local online = {}
    while true do
        local cur_players = allium.getPlayers()
        local organized = {}
        for i = 1, #cur_players do -- Sort players in a way that's useful
            organized[cur_players[i]] = cur_players[i]
        end
        for _, name in pairs(organized) do
            if online[name] == nil then
				online[name] = name
                os.queueEvent("player_join", name)
            end
		end
		for _, name in pairs(online) do
			if organized[name] == nil then
				online[name] = nil
				os.queueEvent("player_quit", name)
			end
		end
        sleep()
    end
end

raisin.thread.add(interpreter, 0)
raisin.thread.add(scanner, 1)

if not fs.exists("cfg/persistence.ltn") then --In the situation that this is a first installation, let's do some setup
	local fpers = fs.open("cfg/persistence.ltn", "w")
	fpers.write("{}")
	fpers.close()
end

print(cli.info, "Allium started.")
allium.tell("@a", "&eHello World!")
raisin.manager.run()
_G.allium = nil