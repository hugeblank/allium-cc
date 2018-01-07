print("Loading BagelBot")
os.loadAPI("color.lua") --Sponsored by roger109z
_G.bagelBot = {}
local mName = "&h(bagel 'n roger wuz here.)<&r&eBagel&6Bot&r>" --bot title
local botcmds = {}
local pluginlist = {"BagelCore"}
local command = {}
local threads = {}
local thelp = {}
local tsuggest = {}
local rowtbl = {}
local cmdamt = 8
local dir = shell.dir()
print("Integrating API...")
_G.bagelBot.tell = function(name, message, hidetag, botname) --bagelBot.tell as documented in README
    local m
    if type(message) == "string" then
        m = message
    else
        m = ""
    end
    if type(botname) ~= "string" then
    	botname = mName
    end
    local _, test = commands.tellraw(name, color.format((function(hidetag)if hidetag then return "" else return botname.."&r " end end)(hidetag)..m))
    if type(message) == "table" then
        for k, v in pairs(message) do
            local _, l = commands.tellraw(name, color.format(v))
        end
    end
    return textutils.serialise(test)
end
_G.bagelBot.findCommand = function(command, plugin, tbl)
	local possiblecmds = {}
	if string.find(command, ":") then
		local splitAt = string.find(command, ":")
		plugin = string.sub(command, 1, splitAt-1)
		command = string.sub(command, splitAt+1)
	end
	if command and not plugin then
		for i = 1, #pluginlist do
			for k, v in pairs(botcmds[pluginlist[i]]) do
				if k == command then
					if tbl == "command" then
						possiblecmds[#possiblecmds+1] = botcmds[pluginlist[i]][command]
					elseif tbl == "help" then
						possiblecmds[#possiblecmds+1] = thelp[pluginlist[i]][command]
					elseif tbl == "suggest" then
						possiblecmds[#possiblecmds+1] = tsuggest[pluginlist[i]][command]
					elseif tbl == "source" then
						possiblecmds[#possiblecmds+1] = pluginlist[i]
					else
						possiblecmds[#possiblecmds+1] = {botcmds[pluginlist[i]][command], thelp[pluginlist[i]][command], tsuggest[pluginlist[i]][command], pluginlist[i]}
					end
				end
			end
		end
		return possiblecmds
	elseif command and plugin then
		if botcmds[plugin] then
			if botcmds[plugin][command] then
				if tbl == "command" then
					return botcmds[plugin][command]
				elseif tbl == "help" then
					return thelp[plugin][command]
				elseif tbl == "suggest" then
					return tsuggest[plugin][command]
				elseif tbl == "source" then
					return plugin
				else
					return {botcmds[plugin][command], thelp[plugin][command], tsuggest[plugin][command], plugin}
				end
			end
		end
		return false
	else
		return false
	end
end
_G.bagelBot.getPersistence = function(name) --bagelBot.getPersistence as documented in README 
	if fs.exists("persistence.json") then
		_, _, plugin = bagelBot.out()
		local fper = fs.open("persistence.json", "r")
		local tpersist = textutils.unserialize(fper.readAll())
		fper.close()
		if not tpersist[plugin] then
			tpersist[plugin] = {}
		end
		if type(name) == "string" then
			return tpersist[plugin][name]
		end
	end
	return false
end
_G.bagelBot.setPersistence = function(name, data) --bagelBot.setPersistence as documented in README
	local tpersist
	if fs.exists("persistence.json") then
		local fper = fs.open("persistence.json", "r")
		tpersist = textutils.unserialize(fper.readAll())
		fper.close()
	end
	if not tpersist[plugin] then
		tpersist[plugin] = {}
	end
	if type(name) == "string" then
		tpersist[plugin][name] = data
		local fpers = fs.open("persistence.json", "w")
		fpers.write(textutils.serialise(tpersist))
		fpers.close()
		return true
	end
	return false
end

print("Loading plugins...")
for _, plugin in pairs(fs.list(dir.."plugins")) do
	if fs.isDir(dir.."plugins/"..plugin) then
		pluginlist[#pluginlist+1] = plugin
		botcmds[plugin] = {}
		thelp[plugin] = {}
		tsuggest[plugin] = {}
		if fs.exists(dir.."plugins/"..plugin.."/init.lua") then --load init.lua
			shell.run(dir.."plugins/"..plugin.."/init.lua")
		end
		if fs.isDir(dir.."plugins/"..plugin.."/threads") then --load threads
			for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/threads")) do
				if loadfile(dir.."plugins/"..plugin.."/threads/"..v) then
					threads[#threads+1] = coroutine.create(loadfile(dir.."plugins/"..plugin.."/threads/"..v))
				else
					print(v.." Could not load successfully.")
				end
			end
		end
		for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/commands")) do --load commands & help entries
			local subAt = string.find(v, "[.]")
			local name = v:sub(1, subAt-1)
			botcmds[plugin][name] = loadfile(dir.."plugins/"..plugin.."/commands/"..v)
			if not botcmds[plugin][name] then
				print("Failed to load !"..plugin..":"..name..". Command will not show up in registrar.")
			end
			if fs.exists(dir.."plugins/"..plugin.."/help/"..name..".txt") then
				local txt = fs.open(dir.."plugins/"..plugin.."/help/"..name..".txt", "r")
				thelp[plugin][name] = txt.readLine()
				tsuggest[plugin][name] = txt.readLine()
				if not tsuggest[plugin][name] then
					tsuggest[plugin][name] = ""
				end
				txt.close()
			else
				thelp[plugin][name] = name.." has no information provided."
				tsuggest[plugin][name] = ""
			end
		end
	end
end
print("Integrating core components...")
local help = function() --!help integration
	local name, args = bagelBot.out()
	if tonumber(args[1]) then
		args[1] = tonumber(args[1])
	elseif args[1] == nil then
		args[1] = 1
	end
	if type(args[1]) == "number" and args[1] > 0 and args[1] <= math.ceil(#rowtbl/cmdamt) then
		local outStr = "&2&l===============&r&eBagelBot !help Menu&r&2&l================&r\n"
		for i = 1+(cmdamt*(args[1]-1)), cmdamt+(cmdamt*(args[1]-1)) do 
			if rowtbl[i] ~= nil then
				outStr = outStr..rowtbl[i]
			else
				outStr = outStr.."\n"
			end
		end
		local bottomInt = 7+string.len(tostring(args[1])..tostring(#rowtbl))
		outStr = outStr.."&2"..string.rep("=", math.ceil((55-bottomInt)/2)-2).."&r&6&l&h(Previous Page)&g(!BagelCore:help "..tostring(args[1]-1)..")<<&r&c&l "..tostring(args[1]).."/"..math.ceil(#rowtbl/cmdamt).." &r&6&l&h(Next Page)&g(!BagelCore:help "..tostring(args[1]+1)..")>>&r&2&l"..string.rep("=", math.floor((55-bottomInt)/2)-3).."&r"
		bagelBot.tell(name, outStr, true)
	elseif type(args[1]) == "number" then
		bagelBot.tell(name, "&cPage does not exist.")
	elseif type(args[1]) == "string" then
		args[1] = string.sub(args[1], 2)
		local clist = bagelBot.findCommand(args[1], nil, "command")
		local pgin = nil
		if type(clist) == "table" or type(clist) == "function" then
			if string.find(args[1], ":") then
				local splitat = string.find(args[1], ":")
				pgin = string.sub(args[1], 1, splitat-1)
				args[1] = string.sub(args[1], splitat+1)
			end
			local slist = bagelBot.findCommand(args[1], pgin, "suggest")
			local hlist = bagelBot.findCommand(args[1], pgin, "help")
			local solist = bagelBot.findCommand(args[1], pgin, "source")
			if not pgin then
				bagelBot.tell(name, "&eMore than one command was found under that name. The command source will be provided if you hover over the command name.")
				for i = 1, #hlist do
					bagelBot.tell(name, "&c&s(!"..solist[i]..":"..args[1].." "..slist[i]..")&h(Click for "..solist[i].."'s !"..args[1].." autofill)!"..args[1].."&r: "..hlist[i])
				end
			else
				bagelBot.tell(name, "&c&s(!"..solist..":"..args[1].." "..slist..")&h(Click for "..solist.."'s !"..args[1].." autofill)!"..args[1].."&r: "..hlist)
			end
		else
			bagelBot.tell(name, "&cCommand does not exist.")
		end
	else
		bagelBot.tell(name, "&cCommand does not exist.")
	end
end
local github = function() --!github integration
	name, args = bagelBot.out()
	bagelBot.tell(name, "Contribute to BagelBot here: &9&n&ihttps://github.com/hugeblank/BagelBot")
end
local plugins = function() --!plugins integration
	name = bagelBot.out()
	local str = ""
	for i = 1, #pluginlist do
		if i < #pluginlist then
			str = str.."&a"..pluginlist[i].."&r, "
		else
			str = str.."&a"..pluginlist[i]
		end
	end
	bagelBot.tell(name, "\nPlugins installed: "..str)
end
--adding commands and integrating help entries for them
botcmds["BagelCore"] = {}
botcmds["BagelCore"]["help"] = help
botcmds["BagelCore"]["github"] = github
botcmds["BagelCore"]["plugins"] = plugins
thelp["BagelCore"] = {}
thelp["BagelCore"]["github"] = "Provides the github repo to check out"
thelp["BagelCore"]["plugins"] = "Lists the name of all plugins installed on the bot"
thelp["BagelCore"]["help"] = "Provides help for help for help for help for help for help"
tsuggest["BagelCore"] = {}
tsuggest["BagelCore"]["github"] = "!github"
tsuggest["BagelCore"]["plugins"] = "!plugins"
tsuggest["BagelCore"]["help"] = "!help"

for i = 1, #pluginlist do
	local plugin = pluginlist[i]
	for k, v in pairs(thelp[plugin]) do --create a table that has rows that are as close to 55 characters large as they can get while respecting spaces.
		local exstr = "!"..k..": "..v
		local row = ""
		for word in string.gmatch(exstr, "%S+") do
			if string.len(row..word) > 55 then
				rowtbl[#rowtbl+1] = row.."\n"
				row = word.." "
			else
				row = row..word.." "
			end
		end
		if row ~= "" then
			rowtbl[#rowtbl+1] = row.."\n"
		end
		for i = 1, #rowtbl do
			if string.find(rowtbl[i], "!"..k..":") then
				rowtbl[i] = string.sub(rowtbl[i], string.len("!"..k..":")+1)
				if #bagelBot.findCommand(k, nil, "command") == 1 then
					rowtbl[i] = "&c&s(!"..k.." "..tsuggest[plugin][k]..")&h(Click for !"..k.." autofill)!"..k.."&r:"..rowtbl[i]
				else
					rowtbl[i] = "&c&s(!"..plugin..":"..k.." "..tsuggest[plugin][k]..")&h(Click for "..plugin.."'s !"..k.." autofill)!"..k.."&r:"..rowtbl[i]
				end
			end
		end
	end
end

local main = function()
	while true do
		local _, _, name, message = os.pullEvent("chat_message") --Pull chat messages
		if string.find(message, "!") == 1 then --are they for BagelBot?
			command = {}
			for k in string.gmatch(message, "%S+") do --put all arguments spaced out into a table
				command[#command+1] = k
			end
			local cmd = string.sub(command[1], 2)
			table.remove(command, 1) --remove the first parameter given (!command)
			local possiblecmds = {}
			if not string.find(cmd, ":") then --did they not specify the plugin source?
				for k, v in pairs(botcmds) do --nope... gonna have to find it for them.
					for l, w in pairs(v) do
						if l == cmd then --well I found it, but there may be more...
							possiblecmds[#possiblecmds+1] = {w, k} --split into command function, source
						end
					end
				end
			else --hey they did! +1 karma.
				local splitat = string.find(cmd, ":")
				if botcmds[string.sub(cmd, 1, splitat-1)] then --check plugin existence
					if botcmds[string.sub(cmd, 1, splitat-1)][string.sub(cmd, splitat+1, -1)] then --check command existence
						possiblecmds[#possiblecmds+1] = {botcmds[string.sub(cmd, 1, splitat-1)][string.sub(cmd, splitat+1, -1)], string.sub(cmd, 1, splitat-1)} --split it into the function, and then the source
					end
				end
			end
			if #possiblecmds == 1 and possiblecmds[1][1] then --is it really a command, and is there only one that is titled this?
				_G.bagelBot.out = function() return name, command, possiblecmds[2] end --bagelBot.out as documented in README
	    		local stat, err = pcall(possiblecmds[1][1]) --Let's execute the command in a safe environment that won't kill bagelbot
	    		if stat == false then--it crashed...
	    			bagelBot.tell(name, "&4"..cmd.." crashed! This is likely not your fault, but the developer's. Please contact the developer of &a"..possiblecmds[1][2].."&4. Error:\n&c"..err)
	    			print(cmd.." errored. Error:\n"..err)
	    		end
	    	elseif #possiblecmds > 1 then --WHAT MORE THAN ONE OUTCOME!?!?
	    		local colstr = ""
	    		for i = 1, #possiblecmds do --idiot, I'm going to have to list them out for you...
	    			if i ~= #possiblecmds then
	    				colstr = colstr.."&a&g(!"..possiblecmds[i][2]..":"..cmd..")&h(Click to run !"..possiblecmds[i][2]..":"..cmd..")"..possiblecmds[i][2].."&r&e, "
	    			else
	    				colstr = colstr.."and &a&g(!"..possiblecmds[i][2]..":"..cmd..")&h(Click to run !"..possiblecmds[i][2]..":"..cmd..")"..possiblecmds[i][2].."&r&e."
	    			end
	    		end --how dare you inconvenience me...
	    		bagelBot.tell(name, "&eCommand collision beween "..colstr.." Click on the plugin that you want to run the command from. Optionally specify the command you want to use by prefixxing the plugin name followed by a colon, and then the command name. Ex: &c&g(!BagelCore:github)!BagelCore:github&r&e.") --REEEEEEEE
    		else --this isn't even a valid command...
	    		bagelBot.tell(name, "&6Invalid Command, use &c&g(!help)!help&r&6 for assistance.") --bleh!
    		end
	    end
	end
end
threads[#threads+1] = coroutine.create(main) --Add main to the thread table

if not fs.exists("persistence.json") then --In the situation that this is a first installation, let's add persistence.json
	local fpers = fs.open("persistence.json", "w")
	fpers.write("{}")
	fpers.close()
end

print("BagelBot started.")
bagelBot.tell("@a", "BagelBot loaded.")
--This clump is pulled and adapted for what I need it for, parallel.waitForAll, for a table of coroutines. Its origin is in /rom/apis/parallel.lua in CraftOS.
local count = #threads
local living = count

local tFilters = {}
local eventData = { n = 0 }
while true do
	for n=1,count do
		local r = threads[n]
		if r then
			if tFilters[r] == nil or tFilters[r] == eventData[1] or eventData[1] == "terminate" then
    			local ok, param = coroutine.resume( r, table.unpack( eventData, 1, eventData.n ) )
				if not ok then
					error( param, 0 )
				else
					tFilters[r] = param
				end
				if coroutine.status( r ) == "dead" then
					threads[n] = nil
					living = living - 1
					if living <= 0 then
						return n
					end
				end
			end
		end
	end
	for n=1,count do
		local r = threads[n]
		if r and coroutine.status( r ) == "dead" then
			threads[n] = nil
			living = living - 1
			if living <= 0 then
				return n
			end
		end
	end
	eventData = table.pack( os.pullEventRaw() )
end
