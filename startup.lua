shell.run("fg")
if fs.exists("/.repoList") then
    local file = fs.open("/.repoList", "r")
    for k in file.readLine do
        shell.run("github clone "..k.." /")
    end
    file.close()
else
    local file = fs.open("/.repoList", "w")
    file.write("hugeblank/BagelBot") --Forkers change this to their repository.
    file.close()
    error("No valid repo file! Default repo file created!")
end
shell.run("core.lua")
