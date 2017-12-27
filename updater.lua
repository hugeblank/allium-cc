local files = {
  startup = "https://raw.githubusercontent.com/roger109z/BetaBot/master/updater.lua",
  startup2 = "https://raw.githubusercontent.com/roger109z/BetaBot/master/startup.lua",
  command = "https://raw.githubusercontent.com/roger109z/BetaBot/master/commands.lua",
  color = "https://raw.githubusercontent.com/roger109z/BetaBot/master/color.lua",
  motd = "https://raw.githubusercontent.com/roger109z/BetaBot/master/motd.txt",
}
for k, v in pairs(files) do
  local site = http.get(v)
  local file = fs.open(k, "w")
  file.write(site.readAll())
  file.close()
  site.close()
end
shell.run("startup2")
