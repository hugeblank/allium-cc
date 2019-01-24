--shell.openTab("shell")
--[[if fs.exists("/.repoList") then
    local file = fs.open("/.repolist", "r")
    for k in file.readLine do
        shell.run("github clone "..k)
    end
    file.close()
else
    local file = fs.open("/.repolist", "w")
    file.write("hugeblank/BagelBot /") --Forkers change this to their repository.
    file.close()
    error("No valid repo file! Default repo file created!")
end]]
shell.run("allium.lua")
local mod = peripheral.wrap("top")
mod.uncapture(".")
