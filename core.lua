print("Loading BagelBot")
os.loadAPI("color.lua") --Sponsored by roger109z
_G.bagelBot = {}
local command = {}
local threads = {}
local thelp = {}
local dir = shell.dir()
local mName = "<&6Bagel&eBot>" --bot title
print("Integrating API...")
_G.bagelBot.tell = function(name, message, hidetag)
    local m
    if type(message) == "string" then
        m = message
    else
        m = ""
    end
    local _, test = commands.tellraw(name, color.format((function(hidetag)if hidetag then return "" else return mName.."&r: " end end)(hidetag)..m))
    if type(message) == "table" then
        for k, v in pairs(message) do
            local _, l = commands.tellraw(name, color.format(v))
        end
    end
    return textutils.serialise(test)
end
_G.bagelBot.getPersistence = function(name)
	if fs.exists("persistence.json") then
		local fper = fs.open("persistence.json", "r")
		local tpersist = textutils.unserialize(fper.readAll())
		fper.close()
		return tpersist[name]
	else
		return false
	end
end
_G.bagelBot.setPersistence = function(name, data)
	if fs.exists("persistence.json") then
		local fper = fs.open("persistence.json", "r")
		local tpersist = textutils.unserialize(fper.readAll())
		fper.close()
	end
	tpersist[name] = data
	local fpers = fs.open("persistence.json", "w")
	fpers.write(textutils.serialise(tpersist))
	fpers.close()
end
print("Loading plugins...")
for _, plugin in pairs(fs.list(dir.."plugins")) do
	if fs.exists(dir.."plugins/"..plugin.."/init.lua") then
		loadfile(dir.."plugins/"..plugin.."/init.lua")()
	end
	if fs.isDir(dir.."plugins/"..plugin.."/threads") then
		for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/threads")) do
			threads[#threads+1] = coroutine.create(loadfile(v))
		end
	end
	for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/commands")) do
		local name = v:sub(1, -5)
		_G.commands[name] = loadfile(dir.."plugins/"..plugin.."/commands/"..v)
		if fs.exists(dir.."plugins/"..plugin.."/help/"..name..".txt") then
			local txt = fs.open(dir.."plugins/"..plugin.."/help/"..name..".txt", "r")
			thelp[name] = txt.readAll()
			txt.close()
		else
			thelp[name] = name.." has no information provided."
		end
	end
end
print("Integrating core components...")
local help = function()
	name, args = bagelBot.out()
	if args[1] == "help" then
		bagelBot.tell(name, "This one is tricky to understand, so it has been omitted.")
	elseif args[1] == nil then
		for k, v in pairs(thelp) do
			bagelBot.tell(name, "&6*&r &g&c!"..k.."&r: "..v, true)
		end
	else
		bagelBot.tell(name, thelp[args[1]])
	end
end
commands["help"] = help
local main = function()
	while true do
		local _, _, name, message = os.pullEvent("chat_message")
		if string.find(message, "!") == 1 then
			command = {}
			for k in string.gmatch(message, "%S+") do
				command[#command+1] = k
			end
			local cmd = string.sub(command[1], 2)
			table.remove(command, 1)
			if commands[cmd] ~= nil then
				_G.bagelBot.out = function() return name, command end
	    		local _, out = commands[cmd](table.concat(command)) --the parameter here is only for vanilla command implementation. Use bagelBot.out if you want access to the arguments (they come in a nice table too).
    			if out then bagelBot.tell(name, out[1].." beep") end
    		else
	    		bagelBot.tell(name, "&6Invalid Command, use &c&g!help&r&6 for assistance.")
    		end
	    end
	end
end
threads[#threads+1] = coroutine.create(main)

if not fs.exists("persistence.json") then
	local fpers = fs.open("persistence.json")
	fpers.write("{}")
	fpers.close()
end

print("BagelBot started.")
bagelBot.tell("@a", "BagelBot loaded.")
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