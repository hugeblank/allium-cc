print("Loading BagelBot")
os.loadAPI("color.lua") --Sponsored by roger109z
_G.bagelBot = {}
local mName = "&g(urmomhavetriplegay)<&eBagel&6Bot&r>" --bot title
local botcmds = {}
local pluginlist = {}
local command = {}
local threads = {}
local thelp = {}
local tsuggest = {}
local tthelp = {}
local tstring = ""
local rowtbl = {}
local cmdamt = 18
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
		return tpersist[name]
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
	tpersist[name] = data
	local fpers = fs.open("persistence.json", "w")
	fpers.write(textutils.serialise(tpersist))
	fpers.close()
end

print("Loading plugins...")
for _, plugin in pairs(fs.list(dir.."plugins")) do
	pluginlist[#pluginlist+1] = plugin
	if fs.isDir(dir.."plugins/"..plugin) then
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
			botcmds[name] = loadfile(dir.."plugins/"..plugin.."/commands/"..v)
			if fs.exists(dir.."plugins/"..plugin.."/help/"..name..".txt") then
				local txt = fs.open(dir.."plugins/"..plugin.."/help/"..name..".txt", "r")
				thelp[name] = txt.readLine()
				tsuggest[name] = txt.readLine()
				txt.close()
			else
				thelp[name] = name.." has no information provided."
			end
		end
	end
end
print("Integrating core components...")
local help = function() --!help integration
	local name, args = bagelBot.out()
	local page = args[1]
	if tonumber(page) == nil then
		page = 1
	end
	local outStr = "&2&l=================&r&eBagelBot !help Menu&r&2&l=================&r\n"
	outStr = outStr..tthelp[page]
	local bottomInt = 7+string.len(tostring(page)..tostring(#tthelp))
	outStr = outStr.."&2&l"..string.rep("=", math.ceil((55-bottomInt)/2)-1).."&6&g(!help "..tostring(page-1)..")<<&r&c "..tostring(page).."/"..#tthelp.." &6&g(!help "..tostring(page+1)..")>>&r&2&l"..string.rep("=", math.floor((55-bottomInt)/2)-1)
	bagelBot.tell(name, outStr, true)
end
local github = function() --!github integration
	name, args = bagelBot.out()
	bagelBot.tell(name, "Contribute to BagelBot here: &1&n&ihttps://github.com/hugeblank/BagelBot")
end
local plugins = function() --!plugins integration
	name = bagelBot.out()
	local str = ""
	for i = 1, #pluginlist do
		if i < #pluginlist then
			str = str.."&a"..pluginlist[i].."&f, "
		else
			str = str.."&a"..pluginlist[i]
		end
	end
	bagelBot.tell(name, "\nPlugins installed: "..str)
end
--adding commands and integrating help entries for them
botcmds["help"] = help
botcmds["github"] = github
botcmds["plugins"] = plugins
thelp["github"] = "Provides the github repo to check out"
thelp["plugins"] = "Lists the name of all plugins installed on the bot"
thelp["help"] = "Provides help for help for help for help for help for help"
tsuggest["github"] = "!github"
tsuggest["plugins"] = "!plugins"
tsuggest["help"] = "!help"

for k, v in pairs(thelp) do --create a string that has rows that are exactly `cmdamt` large
	local fstr = "!"..k..": "..v
	local fftbl = {} --rows of words >=55 chars long
	local pstr = "" --row of words >=55 chars long
	for word in string.gmatch(fstr, "%S+") do --add each word to a line until it's closest to 55 chars it can get
		local preword
		if word == "!"..k..":" then --if the word is this then assign a different preword to take its place
			if not tsuggest[k] then --if it doesn't have a suggested command, fill it in.
				tsuggest[k] = "!"..k
			end
			preword = "&c&g(!"..k..")!"..k.."&r" 
		end
		if string.len(pstr..word.." ") > 55 then --if the string combined with the word is larger than 55 chars, pack the string up, and reset it.
				if preword then --but don't forget to add what is needed
					pstr = string.sub(pstr, string.len("!"..k..":"))
					pstr = preword..pstr
				end
			fftbl[#fftbl+1] = pstr.."\n"
			pstr = word.." "
		else --otherwise, assign words normally
			if preword then --but don't forget to add what is needed
				pstr = string.sub(pstr, string.len("!"..k..":"))
				pstr = preword..pstr
			end
			pstr = pstr..word.." "
		end
	end
	if pstr ~= "" then --if the string isn't blank, and the word loop hasn't been exited, assign it its own row
		fftbl[#fftbl+1] = pstr.."\n"
	end
	if #rowtbl+#fftbl < cmdamt then --if the existing rows in addition with the incoming rows is smaller than `cmdamt` slap them in
		for i = 1, #fftbl do
			rowtbl[#rowtbl+1] = fftbl[i]
		end
	else --otherwise, convert `rowtbl` into a string of `cmdamt` lines, set the remaining rows in a table to `rowtbl`, and add it all to `tthelp`
		for i = 1, #rowtbl do
			tstring = tstring..rowtbl[i]
		end
		rowtbl = fftbl
		tthelp[#tthelp+1] = tstring
	end
end
--clean things up a bit.
tstring = nil
rowtbl = nil
thelp = nil

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
			if botcmds[cmd] ~= nil then --is it really a command?
				_G.bagelBot.out = function() return name, command end --bagelBot.out as documented in README
	    		botcmds[cmd]() --Let's execute the command
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
