local allium = require("allium")
local stem = allium.register("allium", "0.6.0", "Allium Stem")

local help = function(name, args, data)
	local cmds_per, page = 8, 1 -- Turn this into a per-user persistence preference
	local info = {}
	local out_str = ""
	local addDetails
	local next_command = "!allium:help "

	do -- Just a block for organization of command parsing stuffs
		local function infill(variant, execute)
			local out = {}
			if type(variant) == "string" then
				if variant == "username" then
					local players = allium.getPlayers()
					for i = 1, #players do
						out[#out+1] = " &6-&r &g("..execute..players[i].." )&h(Click to add user "..players[i]..")&a"..players[i]
					end
				elseif variant == "plugin" then
					local list = allium.getInfo()
					for plugin in pairs(list) do
						out[#out+1] = " &6-&r &g("..execute..plugin.." )&h(Click to add plugin "..plugin..")&a"..plugin
					end
				elseif variant == "command" then
					local list = allium.getInfo()
					for plugin, v in pairs(list) do
						for command in pairs(v) do
							local rawcmd = command
							local command = plugin..":"..command
							out[#out+1] = " &6-&r &g("..execute..command.." )&h(Click to add command !"..rawcmd..")&a!"..command
						end
					end
				elseif variant:sub(1, -2) == "position_" then
					local position = allium.getPosition(name).position
					if variant:sub(-1, -1) == "x" then
						out[#out+1] = " &6-&r &g("..execute..position[1].." )&h(Click to add your x position)&a"..position[1]
					elseif variant:sub(-1, -1) == "y" then
						out[#out+1] = " &6-&r &g("..execute..position[2].." )&h(Click to add your y position)&a"..position[2]
					elseif variant:sub(-1, -1) == "z" then
						out[#out+1] = " &6-&r &g("..execute..position[3].." )&h(Click to add your z position)&a"..position[3]
					end
				end
			elseif type(variant) == "function" or type(variant) == "table" then
				local result = {}
				if type(variant) == "function" then
					result = variant()
				else
					result = variant
				end
				for i = 1, #result do
					if type(result[i]) == "string" and not result[i]:find("=") then
						out[#out+1] = " &6-&r &g("..execute..result[i].." )&h(Click to add "..result[i]..")&a"..result[i]
					end
				end
			end
			return out
		end

		local function parse(label, data, execute)
			local prefix, postfix, execution, hover, information = "&6 - &r<&a", "&r>:", "", ""
			if type(data[1]) == "string" then
				information = data[1]
			else
				information = "&oNo information found"
			end
			if data.optional == true then
				prefix, postfix = "&6 - &r[&a", "&r]:"
			end
			if data.clickable == true or data.clickable == nil then
				hover, execution = "Click to add this parameter", execute..label
				if type(data.infill) == "string" then
					execution = execution.."="
				end
			end
			if data.default and tostring(data.default) then -- Overrides infill. default and infill shouldn't even be used in the same place anyways.
				execution = execute..label.."=\"\""..data.default.."\"\"" -- Quoting a quote so it gets placed in chat properly
			end
			local meta = ""
			if #execution ~= 0 then
				meta = meta.."&g("..execution..")"
			end
			if #hover ~= 0 then
				meta = meta.."&h("..hover..")"
			end
			return prefix..meta..label..postfix.." "..information
		end

		addDetails = function(info, args, execute, command)
			if not args[1] then --or info then
					-- We're at the end of parsing and should render possible fields
					local out = {}
					if info then
						for k, v in pairs(info) do
							if type(v) == "table" then
								out[#out+1] = parse(k, v, execute)
							end
						end
					end
					if #out == 0 or not info then
						out = {" &6-&a No more parameters to add!", " &6-&a Click &r&c&h(Click to run command)&g("..command..")here&r&a to run the command", " &6- &eOR&a click on the first line to add the command to the chat input."}
					end
					return out, command
			else -- Otherwise things are going totally as planned and we should just recurse onwards
				local param_data = {}
				local is_tag = args[1]:find("=")
				if is_tag then
					param_data.param = args[1]:sub(1, is_tag-1)
					param_data.tag = args[1]:sub(is_tag+1, -1)
					table.remove(args, 1)
				else
					param_data.param = table.remove(args, 1)
				end
				if is_tag and #param_data.tag == 0 then
					-- If the parameter is an infill thing, and doesn't have a value attached to it:
					if not (info[param_data.param] and info[param_data.param].infill) then
						return "Missing infill information"
					end
					return infill(info[param_data.param].infill, execute..param_data.param.."="), command
				elseif param_data.tag then
					execute = execute..param_data.param.."="..param_data.tag.." "
					command = command..param_data.tag.." "
				else
					execute = execute..param_data.param.." "
					command = command..param_data.param.." "
				end
				return addDetails(info[param_data.param], args, execute, command)
			end
		end
	end

	local function run()
		for i = (cmds_per*(page-1))+1, (cmds_per*page) do
			if info[i] then
				out_str = out_str..info[i].."\\n"
			end
		end
		if #out_str == 0 or page <= 0 then
			data.error("Page does not exist.")
			return
		end
		out_str = "&2===================&r &dAll&5i&r&dum&e Help Menu&r &2===================&r\\n"..out_str
		local template = #(" << "..page.."/"..math.ceil(#info/cmds_per).." >> ")
		local sides = 32-template
		out_str = out_str.."&2"..string.rep("=", sides).."&r &6&l&h(Previous Page)&g("..next_command..(page-1)..")<<&r&c&l "..page.."/"..math.ceil(#info/cmds_per).." &r&6&l&h(Next Page)&g("..next_command..(page+1)..")>>&r &2"..string.rep("=", sides).."&r"
		allium.tell(name, out_str, true)
	end

	local pagenum = tonumber(args[#args])
	if pagenum and pagenum == math.ceil(pagenum) then
		page = pagenum
		args[#args] = nil
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
				info[#info+1] = "&c&g(!allium:help "..p_name..":"..cmd_name..")&h(Click to begin autofill)!"..p_name..":"..cmd_name.."&r: "..entry.info[1]
			end
		end
		return run()
	else -- The first argument is a plugin/command
		next_command = next_command..table.concat(args, " ").." "
		local cnp = args[1]:find(":")
		if cnp then  -- This is a command and plugin
			local p_name, c_name = allium.sanitize(args[1]:sub(1, cnp-1)), allium.sanitize(args[1]:sub(cnp+1, -1))
			if allium.getName(p_name) then
				local c_info = allium.getInfo(p_name)[p_name][c_name]
				if c_info then
					if not c_info.usage then 
						c_info.usage = "" 
					end
					local cmd = table.remove(args, 1)
					local infill_info, infill_text = addDetails(c_info.info, args, "!allium:help "..cmd.." ", "!"..cmd.." ")
					if type(infill_info) == "string" then
						data.error(cmd..": "..infill_info)
						return
					end
					info[#info+1] = "&c&s("..infill_text..")&h(Click to add to chat input)"..infill_text.."&r"
					for i = 1, #infill_info do
						info[#info+1] = infill_info[i]
					end
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
			args[1] = allium.sanitize(args[1])
			if allium.getName(args[1]) then
				for cmd_name, entry in pairs((allium.getInfo(args[1]))[args[1]]) do
					if entry.usage then
						entry.usage = " "..entry.usage
					else
						entry.usage = ""
					end
					info[#info+1] = "&c&g(!allium:help "..args[1]..":"..cmd_name..")&h(Click to begin autofill)!"..cmd_name.."&r: "..entry.info[1]
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
	allium.tell(name, {
		"&dAll&5i&dum &av"..tostring(allium.version).."&r was cultivated with love by &a&h(Check out his repo!)&i(https://github.com/hugeblank)hugeblank&r.",
		"Documentation on Allium can be found here: &9&h(Read up on Allium!)&ihttps://github.com/hugeblank/allium-wiki&r.",
		"Contribute and report issues to Allium here: &9&h(Check out where Allium is grown!)&ihttps://github.com/hugeblank/allium&r.",
		"&6Other Contributors:",
		"&a - &rCommand formatting API by &1&h(Check out his profile!)&i(https://github.com/roger109z)roger109z&r.",
		"&a - &rJSON parsing library by &d&h(Check out their profile!)&i(https://github.com/rxi)rxi&r."
	}, true)
end

local plugins = function(name)
    local pluginlist = {}
    local str = ""
    local plugins = allium.getInfo()
	for p_name in pairs(plugins) do
		local p_str = "&h("..p_name.." v"..tostring(allium.getVersion(p_name))..")"
		if plugins[p_name]["credits"] then
			p_str = p_str.."&g(!"..p_name..":credits)"
		end
		pluginlist[#pluginlist+1] = p_str..allium.getName(p_name)
    end
    str = table.concat(pluginlist, "&r, &a")
	allium.tell(name, "Plugins installed: &a"..str)
end

local info = {
	help = {
		"This command! Helpful",
		page = {
			optional = true,
			clickable = false,
			"Page number to display"
		},
		plugin = {
			optional = true,
			infill = "plugin",
			"Specific plugin to list commands for",
			page = {
				optional = true,
				clickable = false,
				"Page number to display"
			}
		},
		["plugin:command"] = {
			optional = true,
			infill = "command",
			"Specific command to list arguments for",
			page = {
				optional = true,
				clickable = false,
				"Page number to display"
			}
		}
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