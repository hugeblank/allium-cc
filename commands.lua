local nsa = peripheral.wrap("bottom") --chatbox
local wordList = "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa.txt"
local site = http.get(wordList)
local words = {} --list of hangman words
local game = false --if true a game of hangman is going
local let --something for hangman can't remember rn
local word --hangman word
local incorrect = {} --incorrect letters in hangman
local badsyntax = "&6Invalid Syntax!" --Canned answer to give when messing up syntax of a command
local usecoins = false --Toggles whether coin conversions are allowed
local gcoins = {[0]=30,[1]=40,[64]=30,[65]=30,[66]=40,[67]=40,[68]=40,[69]=60,[70]=80,[71]=100,[72]=150,[96]=40,[97]=40,[98]=40,[99]=30,[100]=45,[101]=100,[102]=100,[103]=150} --list of all the coins with their rf values divided by 1000, used for conversions to gamma
local gcommands = { --table with gamma (currency) commands
"&cg login&6: &rMay be used every 24 hours to gain 10 gamma.",
"&cg send <recipient> <amount>&6: &rSends money to recipient",
"&cg balance <player>&6: &rChecks balance",
"&cg mkcoins <amount>&6: &rMakes TE coins from balance",
"&cg usecoins&6: &rConverts coins in inventory to balance",
"&cgshop list [name]&6: &rLists all shops or all shops belonging to a certain player",
"&cgshop create <name> <x> <y> <z> [price]&6: &rCreates a shop using the coordinates as the location of the disk drive for the shop. A price can be added to restrict amounts that can be payed",
"&cgshop remove <name>&6: &rRemoves chosen shop"
}
local gacommands = { --table with admin-only gamma commands
"&cg login&6: &rMay be used every 24 hours to gain 10 gamma.",
"&cg send <recipient> <amount>&6: &rSends money to recipient",
"&cg balance <player>&6: &rChecks balance",
"&cg mkcoins <amount>&6: &rMakes TE coins from balance",
"&cg usecoins&6: &rConverts coins in inventory to balance",
"&cgshop list [name]&6: &rLists all shops or all shops belonging to a certain player",
"&cgshop create <name> <x> <y> <z> [price]&6: &rCreates a shop using the coordinates as the location of the disk drive for the shop. A price can be added to restrict amounts that can be payed",
"&cgshop remove <name>&6: &rRemoves chosen shop",
"&dg setdefault <amount>&6: &rSets amount of money new users start with",
"&dg reset <player> [amount]&6: &rResets player to the default balance or amount specified",
"&dg resetAll&6: &rResets all balances to the default or amount specified",
"&dg money <player> <amount>&6: &rAdds money to player's account or removes if negative"
}
local gamma --Table containing account information
local function gsave() --Saves state of gamma table to file
    local f = fs.open("gamma","w")
    f.write(textutils.serialize(gamma))
    f.close()
end
local function gadd(name) --Adds gamma account information for given user if it doesn't exist
    if not gamma[name] then
        gamma[name] = gamma.default
        gamma.lastLogins[name] = 0 --Makes sure people who login for the first time get to use !g login
    end
end
if (fs.exists("gamma")) then
    local f = fs.open("gamma","r")
    gamma = textutils.unserialize(f.readAll())
    f.close()
else
    gamma = {["default"]=100,["lastLogins"]={}}
end
local _, plrs = commands.testfor("@a")
for i = 1,#plrs do
    gadd(string.sub(plrs[i],7))
end
if not gamma.shops then
    gamma.shops = {}
end
gsave()
repeat --puts the words into the thingy
    local u = site.readLine()
    if u then
        if u:len() > 5 then
           words[#words+1] = u
        end
    end
until u == nil

os.loadAPI("color") --loads the api for minecraft color formatting
local admins = { --table with all server admins(DO NOT TOUCH OR YOUR PR WILL NOT BE ACCEPTED!)
"dannysmc95",
"roger109z",
"hugeblank",
"cyborgtwins",
"EldidiStroyrr"
}
local function isAdmin(name) --checks if admin(DO NOT TOUCH OR YOUR PR WILL NOT BE ACCEPTED!)
    for _, v in pairs(admins) do
        if v == name then
            return true
        end
    end
    return false
end
local mName = "</&cBeta&r>&6Bot" --name of the bot to be used with chat
commands.tellraw("@a", color.format("Starting "..mName))
local tell = function(name, message)--tell is used to tell a player or group of players a formatted message Usage: [NAME/GROUP] [MESSAGE]
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
local function AFKLock()--huge made this so it's pretty shitty imo but I think it keeps afk players in place but idk man
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
local rules = { --table with the rules
"&6*&rUse Common Sense",
"&6*&rNo Griefing Claimed Land", 
"&6*&rYou are Not a Super Hacker, Don’t Hack", 
"&6*&rRespect All Players",
"&6*&rNo Trolling/Flaming",
"&6*&rJust Don’t Be Dumb",
"&6*&rRespect Admins (people with pink (Or green) names)",
"&6*&rOh and Have Fun!"
}
local cList = { --table with avail commands
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
"&c&g!g&6: &rlists gamma commands",
}
local tpList = {} --stores all the tp requests
local function login() --I wasn't sure of a better way to detect login so I made this that checks a list and refreshes every second or so
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
local function main()--the main function it's only a function because I needed to parallel it
    while true do
        local _, _, name, message = os.pullEvent("chat_message") --pulls chat messages
        if string.find(message, "!") == 1 or name == "join" then
            if name ~= "join" then --ok so the events from the login one get sent as the user "join" and that just helps me send the motd
                message = string.sub(message, 2)
            end
            local command = {} --seperates the sub commands
            local file = fs.open("motd", "r")--gets motd from file
                local motd
            if file then
                motd = file.readAll()
                file.close()
            else
                motd = "&2Welcome to the server!\n&2type &c&g!help&2 for commands BetaBot provides."--default motd again it was huge that did this
                writer = fs.open("motd", "w")
                writer.write(motd)
                writer.close()
            end
            if name == "join" then
                tell(message, {motd})--tells player motd
                --print(message)
            end
            for k in string.gmatch(message, "%S+") do--uhhhhhhhh fuck idk what this does
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
            if command[1] == "ping" then --command that replies pong(duh)
                tell(name, "Pong!")
                print("Ponged", name)
            elseif command[1] == "tps" then --replies the server tps
                local _, tps = commands.forge("tps")
                tell("@a", tps[#tps])
                print("Told "..name.." the tps")
            elseif command[1] == "help" then --sends help message
                tell(name, cList)
                print("Sent help to", name)
            elseif command[1] == "rtp" then --random teleport
                commands.spreadplayers(20000, 20000, 1000, 20000, false, name)
                tell(name, "&6Teleported to a random location!")
                print("Sent a player away: ", name)
            elseif command[1] == "rules" then --replies the rules
                tell(name, rules)
                print("Told "..name.." the laws of the land.")
            elseif command[1] == "tpa" or command[1] == "tpahere" then --this is where things get slightly complex but this is the tpa and tpahere command code
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
            elseif command[1] == "tpaccept" then --tpaccept uses a different thing altogether
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
            elseif command[1] == "ragequit" then --lameified version of the ragequit command because I can't kick players with a command computer ;-;
                commands.playsound("minecraft:entity.tnt.primed", "block")
                commands.kill(name)
                print("killed "..name)
            elseif command[1] == "players" then --replies list of players
                tell(name, players)
            elseif command[1] == "motd" then --motd
                if command[2] ~= "set" then
                    tell(name, {motd})
                elseif command[2] == "set" and isAdmin(name) == true and command[3] ~= nil then
                    local file = fs.open("motd", "w") 
                    file.write(string.sub(message, 10))
                    file.close()
                    tell(name, "MotD set!")
                    print(name.." set the MotD")
                else
                    tell(name, "&cFailed!"..tostring(isAdmin(name)))
                end
            elseif command[1] == "hangman" then --hangman
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
            elseif command[1] == "lua" or command[1] == "math" then --the math thing(huge did this so it's shitty as well)
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
            elseif command[1] == "afk" then --afk command that huge did shittily
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
            elseif command[1] == "test" then --shows an output of all color codes for testing my color thingy
                print(textutils.serialise({commands.tellraw(name, color.format("&11&22&33&44&55&66&77&88&99&00&aa&bb&cc&dd&ee&ff\\n &rnewline!"))}))
            elseif command[1] == "stop" and isAdmin(name) == true then --stops the bot
                tell("@a", "&6Stopping...")
                print("Stopping...")
                break
            elseif command[1] == "shrug" then --ftb uses ! for their replacements
                print(name, "shrugged")
            elseif command[1] == "github" then --links to git
                tell("@a", "Make changes to "..mName.."&r at https://github.com/roger109z/BetaBot/")
            elseif command[1] == "g" or command[1] == "gamma" then --gamma is the name I'm giving the currency, similar to my old https one
                if #command == 1 then
                    if (isAdmin(name)) then
                        tell(name,gacommands)
                    else
                        tell(name,gcommands)
                    end
                else
                    if command[2] == "send" then
                        if #command ~= 4 then
                            tell(name,badsyntax)
                        elseif not gamma[command[3]] then
                            tell(name,"&6Player is not in the database")
                        elseif not tonumber(command[4]) or math.floor(tonumber(command[4])) ~= tonumber(command[4]) then
                            tell(name,"&6Invalid number amount")
                        elseif tonumber(command[4]) < 0 then
                            tell(name,"&6Amount cannot be negative")
                        elseif tonumber(command[4]) > gamma[name] then
                            tell(name,"&6Insufficient funds")
                        else
                            gamma[name] = gamma[name] - tonumber(command[4])
                            gamma[command[3]] = gamma[command[3]] + tonumber(command[4])
                            tell(name,"&6"..command[4].."g sent to "..command[3])
                            gsave()
                        end
                    elseif command[2] == "balance" then
                        if not (#command == 2 or #command == 3) then
                            tell(name,badsyntax)
                        elseif #command == 3 and (not gamma[command[3]]) then
                            tell(name,"&6Player is not in the database")
                        else
                            local p
                            if command[3] then
                                p = command[3]
                            else
                                p = name
                            end
                            tell(name,"Balance: "..gamma[p])
                        end
                    elseif command[2] == "mkcoins" then
                        if not usecoins then
                            tell(name,"&6Coin commands are disabled")
                        elseif #command ~= 3 then
                            tell(name,badsyntax)
                        elseif (not tonumber(command[3])) or tonumber(command[3]) < 0 then
                            tell(name,"&6Invalid number amount")
                        elseif tonumber(command[3]) > gamma[name] then
                            tell(name,"&6Insufficient funds")
                        else
                            local left = tonumber(command[3])
                            while left >= 30 do
                                local biggest
                                for k,v in pairs(gcoins) do
                                    if v <= left and ((not gcoins[biggest]) or v > gcoins[biggest]) then
                                        biggest = k
                                    end
                                end
                                if biggest then
                                    commands.give(name,"thermalfoundation:coin",1,biggest)
                                    left = left - gcoins[biggest]
                                    gamma[name] = gamma[name] - gcoins[biggest]
                                else
                                    break
                                end
                            end
                            tell(name,"&6"..tostring(command[3] - left).."g transferred")
                            gsave()
                        end
                    elseif command[2] == "usecoins" then
                        if not usecoins then
                            tell(name,"&6Coin commands are disabled")
                        else
                            local added = 0
                            for k,v in pairs(gcoins) do
                                local a,b = commands.clear(name,"thermalfoundation:coin",k)
                                local num
                                if a then
                                    for i in string.gmatch(b[1],"%S+") do
                                        if tonumber(i) then
                                            num = tonumber(i)
                                            break
                                        end
                                    end
                                    gamma[name] = gamma[name] + num*v
                                    added = added + num*v
                                end
                            end
                            tell(name,"&6"..tostring(added).."g transferred")
                            gsave()
                        end
                    elseif command[2] == "login" then
                        if os.epoch("utc") >= gamma.lastLogins[name] + 86400000 then
                            gamma.lastLogins[name] = os.epoch("utc")
                            gamma[name] = gamma[name] + 10
                            tell(name,"&610g received")
                            gsave()
                        else
                            local t = (gamma.lastLogins[name] + 86400000) - os.epoch("utc")
                            local h = math.floor(t/3600000)
                            t = t - h*3600000
                            local m = math.floor(t/60000)
                            t = t - m*60000
                            local s = math.floor(t/1000)
                            tell(name,"&6"..tostring(h).." hours, "..tostring(m).." minutes, and "..tostring(s).." seconds remaining")
                        end
                    elseif isAdmin(name) then
                        if command[2] == "setdefault" then
                            if #command ~= 3 then
                                tell(name,badsyntax)
                            elseif (not tonumber(command[3])) or tonumber(command[3]) < 0 then
                                tell(name,"&6Invalid number amount")
                            else
                                gamma.default = tonumber(command[3])
                                tell(name,"&6Default balance set to "..command[3])
                                gsave()
                            end
                        elseif command[2] == "reset" then
                            if #command ~= 3 and #command ~= 4 then
                                tell(name,badsyntax)
                            elseif not gamma[command[3]] then
                                tell(name,"&6Name is not in database")
                            elseif command[4] and ((not tonumber(command[4])) or tonumber(command[4]) < 0 or math.floor(tonumber(command[4])) ~= tonumber(command[4])) then
                                tell(name,"&6Invalid number amount")
                            else
                                local m
                                if command[4] then
                                    m = tonumber(m)
                                else
                                    m = gamma.default
                                end
                                gamma[command[3]] = m
                                tell(name,"&6"..command[3].."'s account set to "..tostring(m).."g")
                                gsave()
                            end
                        elseif command[2] == "resetAll" then
                            if #command ~= 2 and #command ~= 3 then
                                tell(name,badsyntax)
                            elseif command[3] and ((not tonumber(command[3])) or tonumber(command[3]) < 0 or math.floor(tonumber(command[4])) ~= tonumber(command[4])) then
                                tell(name,"&6Invalid number amount")
                            else
                                local m
                                if command[3] then
                                    m = tonumber(m)
                                else
                                    m = gamma.default
                                end
                                for k,v in pairs(gamma) do
                                    if k ~= "default" then
                                        gamma[k] = m
                                    end
                                end
                                tell(name,"&6All players reset to "..tostring(m).."g")
                                gsave()
                            end
                        elseif command[2] == "money" then
                            if #command ~= 4 then
                                tell(name,badsyntax) 
                            elseif not gamma[command[3]] then
                                tell(name,"&6Name is not in database") 
                            elseif (not tonumber(command[4])) or math.floor(tonumber(command[4])) ~= tonumber(command[4]) then
                                tell(name,"&6Invalid number amount") 
                            else
                                gamma[command[3]] = gamma[command[3]] + tonumber(command[4])
                                tell(name,"&6"..command[4].."g added to "..command[3].."'s account")
                                gsave()
                            end
                        else
                            tell(name,"&6Invalid command")
                        end
                    else
                        tell(name,"&6Invalid command")
                    end
                end
            elseif command[1] == "gshop" then
                if command[2] == "create" then
                    if #command ~= 6 and #command ~= 7 then
                        tell(name,badsyntax)
                    elseif #command[3] > 16 then
                        tell(name,"&6Max name length is 16")
                    elseif (not tonumber(command[4])) or (not tonumber(command[5])) or (not tonumber(command[6])) or math.floor(tonumber(command[4])) ~= tonumber(command[4]) or math.floor(tonumber(command[5])) ~= tonumber(command[5])or math.floor(tonumber(command[6])) ~= tonumber(command[6]) then
                        tell(name,"&6Invalid number coordinates")
                    elseif command[7] and ((not tonumber(command[7])) or math.floor(tonumber(command[7])) ~= tonumber(command[7]) or tonumber(command[7] < 0)) then
                        tell(name,"&6Invalid number price")
                    elseif gamma.shops[command[3]] then
                        tell(name,"&6"..command[3].." already exists")
                    elseif commands.getBlockInfo(tonumber(command[4]),tonumber(command[5]),tonumber(command[6])).name ~= "computercraft:peripheral" or commands.getBlockInfo(tonumber(command[4]),tonumber(command[5]),tonumber(command[6])).metadata ~= 0 then
                        tell(name,"&6No disk drive at location")
                    else
                        gamma.shops[command[3]] = {}
                        gamma.shops[command[3]].x = tonumber(command[4])
                        gamma.shops[command[3]].y = tonumber(command[5])
                        gamma.shops[command[3]].z = tonumber(command[6])
                        gamma.shops[command[3]].price = tonumber(command[7])
                        gamma.shops[command[3]].user = name
                        tell(name,"&6Shop succesfully created")
                        gsave()
                    end
                elseif command[2] == "list" then
                    if #command ~= 2 and #command ~= 3 then
                        tell(name,badsyntax)
                    elseif command[3] and (not gamma[command[3]]) then
                        tell(name,"&6Player is not in database")
                    else
                        local out = {}
                        for k,v in pairs(gamma.shops) do
                            if (not command[3]) or command[3] == v.user then
                                out[#out+1] = "&5"..k.."&6: owned by &5"..v.user
                                if v.price then
                                    out = out.."&6 for &5"..v.price.."g"
                                end
                            end
                        end
                        tell(name,out)
                    end
                else
                    tell(name,"&6Invalid command")
                end
            else
                if name ~= "join" then --if command unknown it tells them
                    commands.tellraw(name, color.format("&cUnknown Command! Use &6!help &cfor a list of commands."))
                    print(name, command[1])
                end
            end
        end
    end
end
parallel.waitForAny(main, AFKLock, login) --do all the things :)
