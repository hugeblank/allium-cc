local files = {
  startup = "https://raw.githubusercontent.com/roger109z/BetaBot/updater.lua",
  startup2 = "https://raw.githubusercontent.com/roger109z/BetaBot/startup.lua",
  command = "https://raw.githubusercontent.com/roger109z/BetaBot/commands.lua",
  color = "https://raw.githubusercontent.com/roger109z/BetaBot/color.lua",
  motd = "https://raw.githubusercontent.com/roger109z/BetaBot/motd.txt",
}
for k, v in pairs(files) do
  local site = http.get(v)
  local file = fs.open(k)
  file.write(site.readAll())
  file.close()
  site.close()
end
shell.run("startup2")
