print("Loading BagelBot")
os.loadAPI("color.lua") --Sponsored by roger109z
_G.bagelBot = {}
local easterEgg = {"urmomhavetriplegay", "https://www.pornhub.com","does anyone know the command for !help?", "What's the name of that one bagel dude...", "BagelBot is pretty badass", "gucci gang", "Sorry people, this is a christian minecraft server, so no swearing.", "hugeblank added random easter egg bogus to this crap and still hasn't implemented (insert feature here)!!! REEEE!"}
local mName = "&g("..easterEgg[math.random(1, #easterEgg)]..")<&eBagel&6Bot&r>" --bot title
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
_G.bagelBot.getPersistence = function(name) --bagelBot.getPersistence as documented in README
	if fs.exists("persistence.json") then
		local fper = fs.open("persistence.json", "r")
		local tpersist = textutils.unserialize(fper.readAll())
		fper.close()
		return tpersist[plugin][name]
	else
		return false
	end
end
_G.bagelBot.setPersistence = function(name, data) --bagelBot.setPersistence as documented in README
	local tpersist
	if fs.exists("persistence.json") then
		local fper = fs.open("persistence.json", "r")
		tpersist = textutils.unserialize(fper.readAll())
		fper.close()
	end
	tpersist[plugin][name] = data
	local fpers = fs.open("persistence.json", "w")
	fpers.write(textutils.serialise(tpersist))
	fpers.close()
end

print("Loading plugins...")
for _, plugin in pairs(fs.list(dir.."plugins")) do
	if fs.isDir(dir.."plugins/"..plugin) then
		pluginlist[#pluginlist+1] = plugin
		if fs.exists(dir.."plugins/"..plugin.."/init.lua") then --load init.lua
			shell.run(dir.."plugins/"..plugin.."/init.lua")
		end
		if fs.isDir(dir.."plugins/"..plugin.."/threads") then --load threads
			for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/threads")) do
				threads[#threads+1] = coroutine.create(loadfile(dir.."plugins/"..plugin.."/threads/"..v))
			end
		end
		for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/commands")) do --load commands & help entries
			local name = v:sub(1, -5)
			botcmds[plugin][name] = loadfile(dir.."plugins/"..plugin.."/commands/"..v)
			if fs.exists(dir.."plugins/"..plugin.."/help/"..name..".txt") then
				local txt = fs.open(dir.."plugins/"..plugin.."/help/"..name..".txt", "r")
				thelp[plugin][name] = txt.readLine()
				tsuggest[plugin][name] = txt.readLine()
				if not tsuggest[plugin][name] then
					tsuggest[plugin][name] = "!"..name
				end
				txt.close()
			else
				thelp[plugin][name] = name.." has no information provided."
				tsuggest[plugin][name] = "!"..name
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
		outStr = outStr.."&2"..string.rep("=", math.ceil((55-bottomInt)/2)-2).."&r&6&l&h(Previous Page)&g(!help "..tostring(args[1]-1)..")<<&r&c&l "..tostring(args[1]).."/"..math.ceil(#rowtbl/cmdamt).." &r&6&l&h(Next Page)&g(!help "..tostring(args[1]+1)..")>>&r&2&l"..string.rep("=", math.floor((55-bottomInt)/2)-3).."&r"
		bagelBot.tell(name, outStr, true)
	elseif type(args[1]) == "number" then
		bagelBot.tell(name, "&cPage does not exist.")
	elseif type(args[1]) == "string" and thelp[args[1]] then
		bagelBot.tell(name, "&c&s("..tsuggest[args[1]]..")&h(Click for !"..args[1].." autofill)&r!"..args[1]..":"..thelp[args[1]])
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
botcmds["BagelCore"]["help"] = help
botcmds["BagelCore"]["github"] = github
botcmds["BagelCore"]["plugins"] = plugins
thelp["BagelCore"]["github"] = "Provides the github repo to check out"
thelp["BagelCore"]["plugins"] = "Lists the name of all plugins installed on the bot"
thelp["BagelCore"]["help"] = "Provides help for help for help for help for help for help"
tsuggest["BagelCore"]["github"] = "!github"
tsuggest["BagelCore"]["plugins"] = "!plugins"
tsuggest["BagelCore"]["help"] = "!help"

for k, v in pairs(thelp) do --create a table that has rows that are exactly 55 characters large
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
			rowtbl[i] = "&c&s("..tsuggest[k]..")&h(Click for !"..k.." autofill)!"..k.."&r:"..rowtbl[i]
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
			if not string.find(cmd, ":") then
				for k, v in pairs(botcmds) do
					for l, w in pairs(v) do
						if l == cmd then
							possiblecmds[#possiblecmds+1] = w
						end
					end
				end
			else
				local splitat = string.find(":")
				possiblecmds[#possiblecmds+1] = botcmds[string.sub(cmd, 1, splitat-1)][string.sub(cmd, splitat+1, -1)]
			end
			_G.bagelBot.out = function() return name, command end --bagelBot.out as documented in README
			if #possiblecmds == 1 then --is it really a command?
	    		possiblecmds[1]() --Let's execute the command
	    	elseif #possiblecmds > 1 then
	    		bagelBot.tell(name, "&eCommand collision. Specify the command you want to use by prefixxing the plugin name followed by a colon, and then the command name. ex: &c&g(!BagelCore:github)!BagelCore:github")
    		else --this isn't a valid command...
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
