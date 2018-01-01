local files = { "https://raw.githubusercontent.com/roger109z/BetaBot/master/updater.lua", "https://raw.githubusercontent.com/roger109z/BetaBot/master/startup.lua", "https://raw.githubusercontent.com/roger109z/BetaBot/master/core.lua", "https://raw.githubusercontent.com/roger109z/BetaBot/master/color.lua", "https://raw.githubusercontent.com/roger109z/BetaBot/master/motd.txt"}
local getName = function(index) local t = {} local name for i in string.gmatch(files[index], "[^/]+") do t[#t+1] = i end return t[#t] end
for i = 1, #files do shell.run("rm "..getName(i)) shell.run("wget "..files[i], getName(i)) end
shell.run("mkdir plugins")
term.clear()