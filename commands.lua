local nsa = peripheral.wrap("bottom")
local wordList = "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa.txt"
local site = http.get(wordList)
local words = {}
local game = false
local let
local word
local incorrect = {}
repeat
    local u = site.readLine()
    if u then
        if u:len() > 5 then
           words[#words+1] = u
        end
    end
until u == nil

os.loadAPI("color")
local admins = {
"dannysmc95",
"roger109z",
"hugeblank",
"cyborgtwins",
--"LDDestroyrr",
"EldidiStroyrr",
}
local function isAdmin(name)
    for _, v in pairs(admins) do
        if v == name then
            return true
        end
    end
    return false
end
local mName = "</&cBeta&r>&6Bot"
commands.tellraw("@a", color.format("Starting "..mName))
local tell = function(name, message)
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
local function AFKLock()
    while true do
        local file = fs.open("persistence.json", "r")
        local isAFK
        if file then
            isAFK = textutils.unserialize(file.readAll())
            file.close()
        else
            isAFK = {}
            local writer = fs.open("persistence.json", "w")
            writer.write(textutils.serialize(isAFK))
            writer.close()
        end
        for k, v in pairs(isAFK) do
            local _, res = commands.tp(v[1], v[2], "~", v[4])
        end
        sleep()
    end
end
local rules = {
"&6*&rUse Common Sense",
"&6*&rNo Griefing Claimed Land", 
"&6*&rNo abusing bugs", 
"&6*&rRespect Admins (people with pink names)"
}
local cList = {
"&c&g!ping&6: &rPong!",
"&c&g!help&6: &rShows this message",
"&c&g!tps&6: &rShows the overall tps of the server",
"&c&g!rtp&6: &rRandom Teleport",
"&c&g!rules&6: &rShows the server rules",
"&c&g!tpa&6: &rAsks to teleport to a player",
"&c&g!tpahere&6: &rAsks to teleport a player to you",
"&c&g!ragequit&6: &rBlows you up then kills you",
"&c&g!players&6: &rshows current online players",
"&c&g!hangman&6: &rstarts a game of hangman",
"&c&g!math&6: &rperforms any mathematical equation you throw at it",
"&c&g!afk&6: &rToggles AFK status and puts you in a safe place",
"&c&g!motd&6: &rshows message of the day",
"&c&g!github&6: &rshows how to edit me!",
}
local tpList = {}
local function login()
    local players = {}
    while true do
        local _, plrs = commands.testfor("@a")
        for k, v in pairs(plrs) do
            local v = string.sub(v, 7)
            if players[v] == nil then
                players[v] = v
                print(v.." joined")
                os.queueEvent("chat_message", "", "join", v)
            end
        end
        players = {}
        for _, v in pairs(plrs) do
            players[string.sub(v, 7)] = string.sub(v, 7)
        end
        sleep(1)
    end
end
local function main()
    while true do
        local _, _, name, message = os.pullEvent("chat_message")
        if string.find(message, "!") == 1 or name == "join" then
            if name ~= "join" then
                message = string.sub(message, 2)
            end
            local command = {}
            local file = fs.open("motd.txt", "r")
                local motd
            if file then
                motd = file.readAll()
                file.close()
            else
                motd = "&2Welcome to the server!\n&2type &c&g!help&2 for commands BetaBot provides."
                writer = fs.open("motd.txt", "w")
                writer.write(motd)
                writer.close()
            end
            if name == "join" then
                tell(message, {motd})
                --print(message)
            end
            for k in string.gmatch(message, "%S+") do
                command[#command+1] = k
            end
            local _, plrs = commands.testfor("@a")
            local players = {}
            for _, v in pairs(plrs) do
                players[string.sub(v, 7)] = string.sub(v, 7)
            end
            for k, _ in pairs(tpList) do
                if players[k] == nil then
                    tpList[k] = nil
                end
            end
            if command[1] == "ping" then
                tell(name, "Pong!")
                print("Ponged", name)
            elseif command[1] == "tps" then
                local _, tps = commands.forge("tps")
                tell("@a", tps[#tps])
                print("Told "..name.." the tps")
            elseif command[1] == "help" then
                tell(name, cList)
                print("Sent help to", name)
            elseif command[1] == "rtp" then
                commands.spreadplayers(20000, 20000, 1000, 20000, false, name)
                tell(name, "&6Teleported to a random location!")
                print("Sent a player away: ", name)
            elseif command[1] == "rules" then
                tell(name, rules)
                print("Told "..name.." the laws of the land.")
            elseif command[1] == "tpa" or command[1] == "tpahere" then
                if type(players[command[2]]) == "nil" then
                    command[2] = nil
                end
                if command[2] == nil then
                    tell(name, "&cPlayer Unavailable!")
                else
                    local dir
                    local tphere
                    if command[1] == "tpa" then
                        dir = "to teleport to you"
                    else
                        dir = "you to teleport to them"
                        tphere = true
                    end
                    print(tell(command[2], name.." would like "..dir.." type or click: &6&g!tpaccept "..name.."&r to accept"))
                    tell(name, "Sent Teleport Request To: &6"..command[2])
                    if tpList[command[2]] == nil then
                        tpList[command[2]] = {}
                    end
                    tpList[command[2]][name] = {name, tphere}
                end
            elseif command[1] == "tpaccept" then
                if tpList[name] ~= nil then
                    if tpList[name][command[2]] ~= nil then
                        local thing = tpList[name][command[2]]
                        if not thing[2] then
                            commands.tpl(command[2], name)
                        else
                            commands.tpl(name, command[2])
                        end
                        tell(name, "Teleport request accepted")
                        tell(command[2], "Teleport request accepted")
                        tpList[command[2]] = nil
                        if not tphere then
                            print("Teleported "..command[2].." to "..name)
                        else
                            print("Teleported "..name.." to "..command[2])
                        end
                    end
                else
                    tell(name, "&cNo Teleport requests at this time")
                end
            elseif command[1] == "ragequit" then
                commands.playsound("minecraft:entity.tnt.primed", "block")
                commands.kill(name)
                print("killed "..name)
            elseif command[1] == "players" then
                tell(name, players)
            elseif command[1] == "motd" then
                if command[2] ~= "set" then
                    tell(name, {motd})
                elseif command[2] == "set" and isAdmin(name) == true and command[3] ~= nil then
                    local file = fs.open("motd.txt", "w") 
                    file.write(string.sub(message, 10))
                    file.close()
                    tell(name, "MotD set!")
                    print(name.." set the MotD")
                else
                    tell(name, "&cFailed!"..tostring(isAdmin(name)))
                end
            elseif command[1] == "hangman" then
                if game ~= true then
                    if command[2] == "start" then
                        game = true
                        word = words[math.random(1, #words)] 
                        let = {}
                        for k in string.gmatch(word, ".") do
                            let[#let+1] = {k, false}
                        end
                        guess = ""
                        for k, v in pairs(let) do
                            guess = guess.."_ "
                        end
                        tell("@a", "&6Game of hangman started! type !hangman and your single letter guess or the whole word.\\nHint: &1"..guess)
                        print("hangman started by: "..name.." the word is: "..word) 
                    else
                        tell(name, "&6Classic hangman! to start a game type or click: &c&g!hangman start&6 to start a game!")
                    end
                else
                    if command[2] == nil then
                        tell(name, "&cPlease provide a letter to guess!")
                        guess = ""
                        for k, v in pairs(let) do
                            if v[2] == false then
                                guess = guess.."_ "
                            else
                                guess = guess..v[1].." "
                            end
                        end
                        tell("@a", "&1"..guess)
                        tell("@a", "&6"..tostring(#incorrect).." incorrect guesses!")
                    else
                        local test = false
                        if string.len(command[2]) == 1 then
                            for k, v in pairs(let) do
                                if v[1] == string.lower(command[2]:sub(1, 1)) then
                                    let[k][2] = true
                                    test = true
                                end
                            end
                        else
                            if command[2] == string.lower(word) then
                                test = true
                                for k, v in pairs(let) do
                                    v[2] = true
                                end
                            end
                        end
                        if test == true then
                            tell("@a", name.." &2guessed correctly!")
                            local cnt = 0
                            local cntMx = 0
                            for _, v in pairs(let) do
                                cntMx = cntMx+1
                                if v[2] == true then
                                    cnt = cnt+1
                                end
                            end
                            if cnt == cntMx then
                                tell("@a", "&2You Won! The word was: &6"..word)
                                game = false
                            end
                        else
                            incorrect[#incorrect+1] = command[2]
                            tell("@a", name.." &cguessed incorrectly!")
                            if #incorrect >= 10 then
                                tell("@a", "&cRan out of guesses! game over! The word was: &6"..word)
                                game = false
                            else
                                tell("@a", "&6"..tostring(10-#incorrect).." guesses left")
                            end
                        end
                        if game then
                            guess = ""
                            for k, v in pairs(let) do
                                if v[2] == true then
                                    guess = guess..v[1].." "
                                else
                                    guess = guess.."_ "
                                end
                            end
                            tell("@a", "&1"..guess)
                        else 
                            incorrect = {}
                            word = nil
                            guess = ""
                            let = {}
                        end
                    end
                end
            elseif command[1] == "lua" or command[1] == "math" then
                local eqn = ""
                local hf = true
                for i = 2, #command do
                    eqn = eqn..command[i]
                end
                if eqn:find("function") then hf = false end
                if hf then
                    local ver
                    local func = loadstring("return "..eqn)
                    if func then
                        setfenv(func, {math = math})
                        ver, ans = pcall(func)
                    else
                        ver = false
                    end
                    if ver then
                        tell(name, "&2Answer: &6"..tostring(ans))
                        print("told "..name.." that "..eqn.." = "..tostring(ans))
                    else
                        tell(name, "&cNot a valid equation!")
                    end
                else
                    tell(name, "&cOkay you can stop trying to test the bounds now.")
                end
            elseif command[1] == "afk" then
                local file = fs.open("isAFK.txt", "r")
                local isAFK = textutils.unserialize(file.readAll())
                file.close()
                local function save(t)
                    local file = fs.open("isAFK.txt", "w")
                    file.write(textutils.serialize(isAFK))
                    file.close()
                end
                local afk = false
                for i = 1, #isAFK do
                    if isAFK[i][1] == name then
                        afk = true
                    end
                end
                if afk == false then
                    local amod = {}
                    local _, res = commands.tp(name, "~ ~ ~")
                    for i in res[1]:gmatch("%S+") do
                        amod[#amod+1] = i:gsub("[,]", "")
                    end
                    tell("@a", "&6*"..name.." is AFK.")
                    print(name.." is AFK.")
                    isAFK[#isAFK+1] = {name, amod[4], amod[5], amod[6]}
                    commands.setblock(amod[4], "253", amod[6], "barrier 0")
                    commands.tp(name, amod[4], "254", amod[6])
                    save(isAFK)
                else
                    for i = 1, #isAFK do
                        if isAFK[i][1] == name then
                            local temppos = isAFK[i]
                            table.remove(isAFK, i)
                            save(isAFK)
                            commands.setblock(temppos[2], "253", temppos[4], "air 0")
                            commands.tp(table.concat(temppos, " "))
                            tell("@a", "&6*"..name.." is no longer AFK.")
                            print(name.." is no longer AFK.")
                        end
                    end
                end
            elseif command[1] == "test" then
                print(textutils.serialise({commands.tellraw(name, color.format("&11&22&33&44&55&66&77&88&99&00&aa&bb&cc&dd&ee&ff\\n &rnewline!"))}))
            elseif command[1] == "stop" and isAdmin(name) == true then
                tell("@a", "&6Stopping...")
                print("Stopping...")
                break
            elseif command[1] == "shrug" then
                print(name, "shrugged")
            elseif command[1] == "github" then
                tell("@a", "Make changes to "..mName.."&r at https://github.com/roger109z/BetaBot/")
            else
                if name ~= "join" then
                    commands.tellraw(name, color.format("&cUnkown Command! Use &6!help &cfor a list of commands."))
                    print(name, command[1])
                end
            end
        end
    end
end
parallel.waitForAny(main, AFKLock, login)
