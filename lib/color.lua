local this = {}

local cTable = {
    ["0"] = "black",
    ["1"] = "dark_blue",
    ["2"] = "dark_green",
    ["3"] = "dark_aqua",
    ["4"] = "dark_red",
    ["5"] = "dark_purple",
    ["6"] = "gold",
    ["7"] = "gray",
    ["8"] = "dark_gray",
    ["9"] = "blue",
    a = "green",
    b = "aqua",
    c = "red",
    d = "light_purple",
    e = "yellow",
    f = "white"
}
local formats = {
    l = "bold",
    n = "underlined",
    o = "italic",
    k = "obfuscated",
    m = "strikethrough",
}
local actions = {
    s = "suggest_command",
    g = "run_command" ,
    i = "open_url" ,
}
local other = {
    h = "hoverEvent",
    r = "reset",
}
local dCurrent = {
	format = {
    	bold = false,
    	underlined = false,
    	italic = false,
    	obfuscated = false,
    	strikethrough = false,
	},
    color = "white",
    hoverEvent = false,
    action = false,
	actionText = "",
	hoverText = "",
}
local function escape(tbl)
	for k, v in pairs(tbl) do
		if v[2]:find("\\") == v[2]:len() then
			tbl[k] = {v[1], v[2]:sub(1, -2).."&"..tbl[tonumber(k)+1][1]..tbl[tonumber(k)+1][2]}
			table.remove(tbl, tonumber(k)+1)
			local ret = escape(tbl)
			return ret
		end
	end
	return tbl
end
local function copy(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		if type(v) ~= "table" then
			ret[k] = v
		else
			ret[k] = copy(v)
		end
	end
	return ret
end
this.format = function(sText, bAction)
	if type(bAction) ~= "boolean" then
		bAction = true
	end
    local current = copy(dCurrent)
    local seperated = {}
    sText = "&r"..sText
    for k in string.gmatch(sText, "[^&]+") do
        seperated[#seperated+1] = {k:sub(1, 1), k:sub(2)}
    end
    local outText = '["",'
    local prev
	seperated = escape(seperated)
    for _, toParse in pairs(seperated) do
        if cTable[toParse[1]] ~= nil then
            current["color"] = cTable[toParse[1]]
        elseif formats[toParse[1]] ~= nil then 
			if current["format"][formats[toParse[1]]] == false then
				current["format"][formats[toParse[1]]] = true
		    else
				current["format"][formats[toParse[1]]] = false
			end
		elseif actions[toParse[1]] ~= nil then
			current["action"] = actions[toParse[1]]
			local ind, bck = string.find(toParse[2], "%[%[.*%]%]")
			if ind ~= nil then
            	current["actionText"] = toParse[2]:sub(ind+2, bck-2)
				toParse[2] = toParse[2]:sub(bck+1)
			else
				current["actionText"] = toParse[2]
			end
		elseif other[toParse[1]] ~= nil then
			if other[toParse[1]] == "hoverEvent" then
				current["hoverEvent"] = true
				local ind, bck = string.find(toParse[2], "%[%[.*%]%]")
				if ind ~= nil then
					current["hoverText"] = this.format(toParse[2]:sub(ind+2, bck-2), false)
					toParse[2] = toParse[2]:sub(bck+1)
				else
					current["hoverText"] = toParse[2]
				end
			elseif other[toParse[1]] == "reset" then
				current = copy(dCurrent)
			end
		else
			toParse[2] = "&"..toParse[1]..toParse[2]
		end
        outText = outText..'{"text":"'..toParse[2]..'","color":"'..current["color"]..'"'
		for k, v in pairs(current["format"]) do
			if v then
				outText = outText..",\""..k.."\":true"
			end
		end
		if current["action"] ~= false and bAction then
			outText = outText..',"clickEvent":{"action":"'..current["action"]..'","value":"'..current["actionText"]..'"}'
		end
		if current["hoverEvent"] ~= false and bAction then
			outText = outText..',"hoverEvent":{"action":"show_text","value":'..current["hoverText"]..'}'
		end
        outText = outText..'},'
    end
    outText = string.sub(outText, 1, -2)..']'
    return outText
end

this.deformat = function(string)
    local seperated = {}
	local out = ""
    for k in string.gmatch(sText, "[^&]+") do
        seperated[#seperated+1] = {string.sub(k, 1, 1), string.sub(k, 2)}
    end
	seperated = escape(seperated)
	for k, v in pairs(seperated) do
		out = out..v
	end
	return out
end

return this