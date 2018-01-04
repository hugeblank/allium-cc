shell.run("fg")
local file = fs.open(".repoList", "r")
if file ~= nil then
    for k in file.readLine do
        shell.run("github clone "..k.." /")
    end
else
    error("No valid repo file!")
end
shell.run("core.lua")
