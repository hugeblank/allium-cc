local stem = allium.register("allium", "Allium Stem (Core)")

local help = function(name, args, data)
	local cmds_per, page = 7, 1 -- Turn this into a per-user persistence preference
	local info = {}
	local out_str = ""
	local next_command = "!allium:help "

	local function run()
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
		out_str = out_str.."&2"..string.rep("=", sides).."&r &6&l&h[[Previous Page]]&g[["..next_command..(page-1).."]]<<&r&c&l "..page.."/"..math.ceil(#info/cmds_per).." &r&6&l&h[[Next Page]]&g[["..next_command..(page+1).."]]>>&r &2"..string.rep("=", sides).."&r"
		allium.tell(name, out_str, true)
		return
	end

	if tonumber(args[1]) or not args[1] then -- The first argument is nothing or a page number
		local data = allium.getInfo()
		for p_name, commands in pairs(data) do
			for cmd_name, entry in pairs(commands) do
				if entry.usage then
					entry.usage = " "..entry.usage
				else
					entry.usage = ""
				end
				info[#info+1] = "&c&s[[!"..p_name..":"..cmd_name.."]]&h[[!"..p_name..":"..cmd_name..entry.usage.."]]!"..p_name..":"..cmd_name.."&r: "..entry.info[1]
			end
		end
		if tonumber(args[1]) then
			page = tonumber(args[1])
		end
		return run()
	else -- The first argument is a plugin/command 
		args[1] = allium.sanitize(args[1])
		if tonumber(args[2]) then
			page = tonumber(args[2])
		end
		next_command = next_command..args[1].." "
		local cnp = args[1]:find(":")
		if cnp then  -- This is a command and plugin
			local p_name, c_name = args[1]:sub(1, cnp-1), args[1]:sub(cnp+1, -1)
			if allium.getName(p_name) then
				local c_info = allium.getInfo(p_name)[p_name][c_name]
				if c_info then
					local function addDetails(i_table, label, pre_str, sug_cmd, include)
						if not include then
							if i_table.noclick then -- If the parameter is not intended to be clicked (Eg: a username)
								info[#info+1] = pre_str.."<&a"..label.."&r>: "..i_table[1]
							elseif i_table.optional then -- If the parameter is not required
								info[#info+1] = pre_str.."[&a"..label.."&r]: "..i_table[1]
							elseif not (i_table.noclick or i_table.optional) then
								info[#info+1] = pre_str.."<&a&h[[Add this parameter]]&s[["..sug_cmd.." ]]"..label.."&r>: "..i_table[1]
							end
						end
						for param, param_info in pairs(i_table) do
							if param ~= 1 and param ~= "optional" and param ~= "noclick" then
								addDetails(param_info, param, "  "..pre_str, sug_cmd.." "..param)
							end
						end
					end
					if not c_info.usage then c_info.usage = "" end
					info[#info+1] = "&c&s[[!"..p_name..":"..c_name.."]]&h[[!"..c_name..c_info.usage.."]]!"..c_name.."&r: "..c_info.info[1]
					addDetails(c_info.info, c_name, "&6-&r ", "!"..p_name..":"..c_name, true)
					return run()
				else
					data.error("Command !"..args[1].." does not exist")
					return
				end
			else
				data.error("Plugin "..args[1].." does not exist")
				return
			end
		else -- This is just a plugin
			if allium.getName(args[1]) then
				for cmd_name, entry in pairs((allium.getInfo(args[1]))[args[1]]) do
					if entry.usage then
						entry.usage = " "..entry.usage
					else
						entry.usage = ""
					end
					info[#info+1] = "&c&s[[!"..args[1]..":"..cmd_name.."]]&g[[!help "..args[1]..":"..cmd_name.."]]&h[[!"..args[1]..":"..cmd_name..entry.usage.."]]!"..cmd_name.."&r: "..entry.info[1]
				end
				return run()
			else
				data.error("Plugin "..args[1].." does not exist")
				return
			end
		end
	end
end

local credits = function(name)
	allium.tell(name, "This project was cultivated with love by &a&h[[Check out his repo!]]&i[[https://github.com/hugeblank]]hugeblank&r.\nCommand formatting API provided graciously by &1&h[[Check out his repo!]]&i[[https://github.com/roger109z]]roger109z&r.\nContribute and report issues to allium here: &9&n&h[[Check out where allium is grown!]]&ihttps://github.com/hugeblank/allium")
end

local plugins = function(name)
    local pluginlist = {}
    local str = ""
    local plugins = allium.getInfo()
	for p_name in pairs(plugins) do
		local p_str = "&h[[Tag: "..p_name.."]]"
		if plugins[p_name]["credits"] then
			p_str = p_str.."&g[[!"..p_name..":credits]]"
		end
		print(p_str)
		pluginlist[#pluginlist+1] = p_str..allium.getName(p_name)
    end
    str = table.concat(pluginlist, "&r, &a")
	allium.tell(name, "Plugins installed: &a"..str)
end

local info = {
	help = {
		"This command! Helpful."
	},
	plugins = {
		"Lists the name of all plugins installed on allium"
	},
	credits = {
		"Provides credits where they are due"
	}
}

stem.command("help", help, info.help, "[page | plugin name], [page]")
stem.command("plugins", plugins, info.plugins)
stem.command("credits", credits, info.credits)