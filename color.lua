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
    s = "suggest_command"
    g = "run_command" 
    h = "link" 
end
local other = {
    i = "hovertext"
    r = "reset"
}
format = function(sText)
    local current = {}
    local seperated = {}
    sText = "&r"..sText
    for k in string.gmatch(sText, "[^&]+") do
        seperated[#seperated+1] = {string.sub(k, 1, 1), string.sub(k, 2)}
    end
    local outText = '["",'
    local prev
    for k, v in pairs(seperated) do
        local color = cTable[v[1]] or prev 
        outText = outText..'{"text":"'..v[2]..'","color":"'..color..'"'
        if v[1] == "g" then
            local ind = string.find(v[2], ")")
            local action = string.sub(v[2], 2, ind-1)
            outText = string.sub(outText, 1, -(22+string.len(v[2])+string.len(color)))
            outText = outText..'{"text":"'..string.sub(v[2], ind+1)..'","color":"'..color..'"'
            outText = outText..',"clickEvent":{"action":"run_command","value":"'..action..'"}'
        end
        outText = outText..'},'
        prev = color
    end
    outText = string.sub(outText, 1, -2)..']'
    return outText
end
