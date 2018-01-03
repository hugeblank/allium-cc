print("Loading BagelBot")
os.loadAPI("color.lua") --Sponsored by roger109z
_G.bagelBot = {}
local botcmds = {}
local pluginlist = {}
local command = {}
local threads = {}
local thelp = {}
local dir = shell.dir()
local mName = "<&6Bagel&eBot&f>" --bot title
print("Integrating API...")
_G.bagelBot.tell = function(name, message, hidetag) --bagelBot.tell as documented in README
    local m
    if type(message) == "string" then
        m = message
    else
        m = ""
    end
    local _, test = commands.tellraw(name, color.format((function(hidetag)if hidetag then return "" else return mName.."&r " end end)(hidetag)..m))
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
				thelp[name] = txt.readAll()
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
	local pages = math.ceil(#thelp/9)
	local skip = page*9
	local outTbl = {"&cHelp Page: "..tostring(page).."&6&g(!help "..tostring(page-1)..")<<&6 &g(!help "..tostring(page+1)..")>>"}
  local n = 0
	for k, v in pairs(thelp) do
    n = n+1
    if n >= skip-9 and n <= skip then
		  outTbl[#outTbl+1] = "&c&g(!"..k..")"..k..": &r"..v
    end
	end
  if #outTbl >= 1 then
    _G.bagelBot.tell(name, outTbl)
  end
end
local github = function() --!github integration
	name, args = bagelBot.out()
	bagelBot.tell(name, "Contribute to bagelBot here: https://github.com/hugeblank/BagelBot")
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
