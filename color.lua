local cTable = {
_r = "white",
_0 = "black",
_1 = "dark_blue",
_2 = "dark_green",
_3 = "dark_aqua",
_4 = "dark_red",
_5 = "dark_purple",
_6 = "gold",
_7 = "gray",
_8 = "dark_gray",
_9 = "blue",
_a = "green",
_b = "aqua",
_c = "red",
_d = "light_purple",
_e = "yellow",
_f = "white"
}
format = function(sText)
    local seperated = {}
    sText = "&r"..sText
    for k in string.gmatch(sText, "[^&]+") do
        seperated[#seperated+1] = {"_"..string.sub(k, 1, 1), string.sub(k, 2)}
    end
    local outText = '["",'
    local prev
    for k, v in pairs(seperated) do
        local color = cTable[v[1]] or prev 
        outText = outText..'{"text":"'..v[2]..'","color":"'..color..'"'
        if v[1] == "_g" then
            outText = outText..',"clickEvent":{"action":"run_command","value":"'..v[2]..'"}'
        end
        outText = outText..'},'
        prev = color
    end
    outText = string.sub(outText, 1, -2)..']'
    return outText
end
