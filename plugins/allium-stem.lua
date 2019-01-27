local stem = allium.register("allium", "Allium Stem (Core)")

local help = function(name, args, data)
	local cmds_per, page = 7, 1 -- Turn this into a per-user persistence preference
	local info = {}
	local out_str = ""
	local next_command = "!allium:help "

	if args[1] == nil then
		page = 1
	elseif not tonumber(args[1]) then
		args[1] = allium.sanitize(args[1])
		if allium.getName(args[1]) then
			for cmd_name, entry in pairs((allium.getInfo(args[1]))[args[1]]) do
				if entry.usage then
					entry.usage = " "..entry.usage
				else
					entry.usage = ""
				end
				info[#info+1] = "&c&s(!"..args[1]..":"..cmd_name..")&h(!"..args[1]..":"..cmd_name..entry.usage..")!"..cmd_name.."&r: "..entry.info
			end
		else
			data.error("Plugin "..args[1].." does not exist")
			return
		end
		next_command = next_command..args[1].." "
		if tonumber(args[2]) then
			page = tonumber(args[2])
		end
	elseif tonumber(args[1]) then
		page = tonumber(args[1])
	else
		meta.usage(name)
	end

	if #info == 0 then
		local data = allium.getInfo()
		for p_name, commands in pairs(data) do
			for cmd_name, entry in pairs(commands) do
				if entry.usage then
					entry.usage = " "..entry.usage
				else
					entry.usage = ""
				end
				info[#info+1] = "&c&s(!"..p_name..":"..cmd_name..")&h(!"..p_name..":"..cmd_name..entry.usage..")!"..p_name..":"..cmd_name.."&r: "..entry.info
			end
		end
	end

	for i = (cmds_per*(page-1))+1, (cmds_per*page) do
		if info[i] then
			out_str = out_str..info[i].."\n"
		end
	end

	if out_str == "" or page <= 0 then
		data.error("Page does not exist.")
		return
	end

	out_str = "&2===================&r &dAll&5i&r&dum&e Help Menu&r &2===================&r\n"..out_str

	local template = #(" << "..page.."/"..math.ceil(#info/cmds_per).." >> ")
	local sides = math.ceil((64/2)-template)

	out_str = out_str.."&2"..string.rep("=", sides).."&r &6&l&h(Previous Page)&g("..next_command..(page-1)..")<<&r&c&l "..page.."/"..math.ceil(#info/cmds_per).." &r&6&l&h(Next Page)&g("..next_command..(page+1)..")>>&r &2"..string.rep("=", sides).."&r"
	allium.tell(name, out_str, true)
end

local credits = function(name)
	allium.tell(name, "This project was cultivated with love by &a&h(Check out his repo!)&i(https://github.com/hugeblank)hugeblank&r.\nCommand formatting API provided graciously by &1&h(Check out his repo!)&i(https://github.com/roger109z)roger109z&r.\nContribute and report issues to allium here: &9&n&h(Check out where allium is grown!)&ihttps://github.com/hugeblank/allium")
end

local plugins = function(name)
    local pluginlist = {}
    local str = ""
    local plugins = allium.getInfo()
    for p_name in pairs(plugins) do
        pluginlist[#pluginlist+1] = "&h(Tag: "..p_name..")"..allium.getName(p_name)
    end
    str = table.concat(pluginlist, "&r, &a")
	allium.tell(name, "Plugins installed: &a"..str)
end

stem.command("help", help, "This command! Helpful.", "[page/plugin name], [page]")
stem.command("plugins", plugins, "Lists the name of all plugins installed on allium")
stem.command("credits", credits, "Provides credits where they are due")