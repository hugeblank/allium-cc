print("Loading BagelBot") --Sponsored by roger109z
os.loadAPI("color.lua")
_ENV.bagelBot = {}
local command = {}
local threads = {}
local help = {}
local mName = "&6Bagel&eBot"
print("Integrating API...")
_ENV.bagelBot.tell = function(name, message)
    local m
    if type(message) == "string" then
        m = message
    else
        m = ""
    end
    local _, test = commands.tellraw(name, color.format(mName.."&r: "..m))
    if type(message) == "table" then
        for k, v in pairs(message) do
            local _, l = commands.tellraw(name, color.format(v))
        end
    end
    return textutils.serialise(test)
end
print("Loading plugins...")
local dir = shell.dir()
for _, plugin in pairs(fs.list(dir.."/plugins")) do 
	if fs.isDir() then
		for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/commands") do
			local name = v.sub(1, v.find(".")-1)
			commands[name] = loadfile(v)
			if fs.exists(dir.."plugins/"..plugin.."/help/"..name..".txt") then
				local txt = fs.open(dir.."plugins/"..plugin.."/help/"..name..".txt", "r")
				help[name] = txt.readAll()
				txt.close()
			else
				help[name] = name.." has no information provided."
			end
		end
		for _, v in pairs(fs.list(dir.."plugins/"..plugin.."/threads") do
			threads[#threads+1] = coroutine.create(loadfile(v))
		end
	end
end
print("Integrating main thread...")
local main = function()
	while true do
		local _, _, name, message = os.pullEvent("chat_message")
		if string.find(message, "!") == 1 then
			for k in string.gmatch(message, "%S+") do
	        	command[#command+1] = k
	    	end
	    	table.remove(command, 1)
	    	_ENV.bagelBot.out = function() return name, command end
	    	local _, out = commands[cmd](message) --the parameter "message" here is only for vanilla command implementation. Use bagelBot.out if you want access to the arguments (they come in a nice table too).
	    	tell(name, out[1])
	    end
	end
end
threads[#threads+1] = coroutine.create(main)


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
            end
        end
    end
    eventData = table.pack( os.pullEventRaw() )
end