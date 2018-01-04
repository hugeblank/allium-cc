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
    n = "underline",
    o = "italic",
    k = "obfuscated",
    m = "strikethrough",
}
local actions = {
    s = "suggest_command",
    g = "run_command" ,
    i = "link" ,
}
local other = {
    h = "hoverEvent",
    r = "reset",
}
local dCurrent = {
	format = {
    	bold = false,
    	underline = false,
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
local function copy(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	return ret
end
format = function(sText, bAction)
	if type(bAction) ~= "boolean" then
		bAction = true
	end
    local current = copy(dCurrent)
    local seperated = {}
    sText = "&r"..sText
    for k in string.gmatch(sText, "[^&]+") do
        seperated[#seperated+1] = {string.sub(k, 1, 1), string.sub(k, 2)}
    end
    local outText = '["",'
    local prev
	function escape(tbl)
		for k, v in pairs(tbl) do
			if v[2]:find("\\") == v[2]:len() then
				tbl[k] = {v[1], v[2]:sub(1, -1).."&"..tbl[tonumber(k)+1][1]..tbl[tonumber(k)+1][2]}
				table.remove(tbl, tonumer(k)+1)
				local ret = escape(tbl)
				return ret
			end
		end
		return tbl
	end
	seperated = escape(seperated)
    for k, v in pairs(seperated) do
        if cTable[v[1]] ~= nil then
            current["color"] = cTable[v[1]]
        elseif formats[v[1]] ~= nil then 
			if current["format"][formats[v[1]]] == false then
				current["format"][formats[v[1]]] = true
		    else
				current["format"][formats[v[1]]] = false
			end
		elseif actions[v[1]] ~= nil then
			current["action"] = actions[v[1]]
			local ind = string.find(v[2], ")")
			if ind ~= nil then
            	current["actionText"] = string.sub(v[2], 2, ind-1)
				v[2] = v[2]:sub(ind+1)
			else
				current["actionText"] = v[2]
			end
		elseif other[v[1]] ~= nil then
			if other[v[1]] == "hoverEvent" then
				current["hoverEvent"] = true
				local ind = string.find(v[2], ")")
				if ind ~= nil then
					current["hoverText"] = format(string.sub(v[2], 2, ind-1), false)
					v[2] = v[2]:sub(ind+1)
				else
					current["hoverText"] = v[2]
				end
			elseif other[v[1]] == "reset" then
				current = copy(dCurrent)
			end
		else
			v[2] = "&"..v[1]..v[2]
		end
        outText = outText..'{"text":"'..v[2]..'","color":"'..current["color"]..'"'
		for k, v in pairs(current["format"]) do
			if v then
				outText = outText..",\""..k.."\":true"
			end
		end
		if current["action"] ~= false and bAction then
			outText = outText..',"clickEvent":{"action":"'..current["action"]..'","value":"'..current["actionText"]..'"}'
		end
		if current["hoverEvent"] ~= false and bAction then
			outText = outText..',"hoverEvent":{"action":"show_text","value":"'..current["hoverText"]..'"}'
		end
        outText = outText..'},'
    end
    outText = string.sub(outText, 1, -2)..']'
    return outText
end
