-- Allium by hugeblank
do -- Allium image setup <3
	local x, y = term.getSize()
	paintutils.drawImage(paintutils.loadImage("allium.nfp"), x-7, 2) -- Draw the Allium image on the side
	local win = window.create(term.current(), 1, 1, x-9, y, true)
	term.redirect(win)
end
term.setBackgroundColor(colors.black) -- Reset terminal and cursor
term.setTextColor(colors.white)
term.setCursorPos(1, 1)
-- Announce loading has begun
print("Loading Allium")
print("Initializing API")

local label = "<&r&dAll&5&h[[Hugeblank was here. Hi.]]&i[[https://www.youtube.com/watch?v=PomZJao7Raw]]i&r&dum&r>" --bot title
local raisin, color = require("raisin.raisin"), require("color") --Sponsored by roger109z
local allium = {} -- API table
local group = {thread = raisin.group.add(1) , command = raisin.group.add(2)} -- threads first, commands second, plugin groups third
local plugins = {} -- Plugin table

allium.assert = function(condition, message, level)
	if not condition then error(message, level or 3) end
end

local assert = allium.assert

allium.sanitize = function(name)
	assert(type(name) == "string", "Invalid argument #1 (expected string, got "..type(name)..")")
	return name:lower():gsub(" ", "-")
end

allium.tell = function(name, message, alt_name)
	assert(type(name) == "string", "Invalid argument #1 (expected string, got "..type(name)..")")
    assert(type(message) == "string" or type(message) == "table", "Invalid argument #2 (expected string or table, got "..type(message)..")")
	local test
	if type(message) == "table" then
		_, test = commands.tellraw(name, color.format(table.concat(message, "\n")))
	else
		_, test = commands.tellraw(name, color.format((function(alt_name) if alt_name == true then return "" elseif alt_name then return alt_name.."&r " else return label.."&r " end end)(alt_name)..message))
    end
    return textutils.serialise(test)
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

allium.getPosition = function(name) 
	assert(type(name) == "nil" or type(name) == "string", "Invalid argument #1 (expected string or nil, got "..type(name)..")")
	local position = {} -- Player position values
	local suc, tbl
	parallel.waitForAll(function() -- Execute tp to player, and value check simultaneously for minimum latency
		suc = commands.exec("tp @e[type=minecraft:armor_stand,team=allium_trackers] "..name)
	end, function()
		_, tbl = commands.exec("tp @e[type=minecraft:armor_stand,team=allium_trackers] ~ ~ ~")
	end)
	commands.exec("tp @e[type=minecraft:armor_stand,team=allium_trackers] "..table.concat({commands.getBlockPosition()}, " "))
	if suc then
		local pos_str = tbl[1]:gsub("Teleported Armor Stand to ", ""):gsub("[,]", "")
		for value in pos_str:gmatch("%S+") do
			position[#position+1] = value
		end
	else
		return false
	end
	return unpack(position)
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

allium.register = function(p_name, fullname)
	assert(type(p_name) == "string", "Invalid argument #1 (string expected, got "..type(p_name)..")")
	local real_name = allium.sanitize(p_name)
	assert(plugins[real_name] == nil, "Invalid argument #1 (plugin exists under name "..real_name..")")
	plugins[real_name] = {threads = {}, commands = {}, name = fullname or p_name}
	local funcs = {}
	local this = plugins[real_name]
	
	funcs.command = function(c_name, command, info, usage) -- name: name | command: executing function | info: help information | usage: table of strings for improper inputs
		assert(type(c_name) == "string", "Invalid argument #1 (string expected, got "..type(c_name)..")")
		local real_name = allium.sanitize(c_name)
		assert(type(command) == "function", "Invalid argument #2 (function expected, got "..type(command)..")")
		assert(this.commands[real_name] == nil, "Invalid argument #2 (command exists under name "..real_name.." for plugin "..this.name..")")
		assert(type(info) == "string" or type(info) == "table" or not info, "Invalid argument #3 (string, table, or nil expected, got "..type(info)..")")
		if type(info) == "string" then info = {generic = info} end
		assert(info.generic, "Invalid argument #3 ('generic' info expected, none found)")
		this.commands[real_name] = {command = command, info = info, usage = usage}
	end

	funcs.thread = function(thread)
		assert(type(thread) == "function", "Invalid argument #1 (function expected, got "..type(thread)..")")
		return raisin.thread.wrap(raisin.thread.add(thread, 0, group.thread), group.thread)
	end

	funcs.getPersistence = function(name)
		assert(type(name) ~= "nil", "Invalid argument #1 (expected anything but nil, got "..type(name)..")")
		if fs.exists("persistence.ltn") then
			local fper = fs.open("persistence.ltn", "r")
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
		if fs.exists("persistence.ltn") then
			local fper = fs.open("persistence.ltn", "r")
			tpersist = textutils.unserialize(fper.readAll())
			fper.close()
		end
		if not tpersist[real_name] then
			tpersist[real_name] = {}
		end
		if type(name) == "string" then
			tpersist[real_name][name] = data
			local fpers = fs.open("persistence.ltn", "w")
			fpers.write(textutils.serialise(tpersist))
			fpers.close()
			return true
		end
		return false
	end

	return funcs
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
assert(allium.side, "Allium requires a creative chat module in order to operate")

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

local interpreter = function() -- Main command interpretation thread
	while true do
		local _, message, _, name = os.pullEvent("chat_capture") -- Pull chat messages
		if string.find(message, "!") == 1 then -- Are they for allium?
			args = {}
			for k in string.gmatch(message, "%S+") do -- Put all arguments spaced out into a table
				args[#args+1] = k
			end
			local cmd = args[1]:sub(2, -1) -- Strip the !
			table.remove(args, 1) -- Remove the first parameter given (!command)
			local cmd_exec
			if not string.find(cmd, ":") then -- Did they not specify the plugin source?
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
				local splitat = string.find(cmd, ":")
				local p_name, c_name = string.sub(cmd, 1, splitat-1), string.sub(cmd, splitat+1, -1)
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
					usage = cmd_exec.data.usage
				}
				local function exec_command()
					local stat, err = pcall(cmd_exec.data.command, name, args, data) --Let's execute the command in a safe environment that won't kill allium
					if stat == false then--it crashed...
						allium.tell(name, "&4"..cmd_exec.command.." crashed! This is likely not your fault, but the developer's. Please contact the developer of &a"..cmd_exec.plugin.."&4. Error:\n&c&h[[Click here to place error into chat prompt, so you may copy it if needed for an issue report]]&s[["..err.."]]"..err.."&r")
						printError(cmd.." errored. Error:\n"..err)
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

if not fs.exists("persistence.ltn") then --In the situation that this is a first installation, let's do some setup
	local fpers = fs.open("persistence.ltn", "w")
	fpers.write("{}")
	fpers.close()
end

if not commands.exec("testfor @e[r=1,type=minecraft:armor_stand,team=allium_trackers]") then
	commands.execAsync("kill @e[type=minecraft:armor_stand,team=allium_trackers]")
	commands.execAsync("scoreboard teams add allium_trackers")
	commands.execAsync("summon minecraft:armor_stand ~ ~ ~ {Marker:1,NoGravity:1,Invisible:1}")
	commands.execAsync("scoreboard teams join allium_trackers @e[r=1,type=minecraft:armor_stand]")
end

print("Allium started.")
allium.tell("@a", "&eHello World!")
raisin.manager.run()
_G.allium = nil