# BagelBot
BagelBot is a simple lua plugin interface for minecraft.
It uses Computercraft's Command Computer, and Computronics's Creative Chatbox to function.

#API
The current API is as follows, prefixed by "bagelBot." (subject to change):
- out (string username, string parameters): provides the program/command with the name and parameters provided after the command. This is the current method used to transfer data to the command that should be executed.
- tell (string username, string text): output colorcode formatted text to the user, using the & and then a hexadecimal symbol. &g additionally provides clickable text to the user.

#File Structure
If you want to develop a plugin for BagelBot the structure is as follows:
/plugins (directory for all plugins)
	/<Plugin Name> (The name of the plugin)
		/commands (where all commands go)
		/help (where the information for all the commands go. should have the same name as the command it's referring to)
		/threads (where all code that should be put on the same loop as the main command executor should go)