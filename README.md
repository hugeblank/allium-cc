# BagelBot
BagelBot is a simple lua plugin interface for minecraft.
It uses Computercraft's Command Computer, and Computronics's Creative Chatbox to function.
## Install
It is highly recommended that you use ccgithub to clone the repository into your command computer.

**1.** `pastebin run p8PJVxC4`

You can view the repository here: https://github.com/eric-wieser/computercraft-github

From installing this, you can now install a variety of BagelBot plugins that are also found on github. Plugins for BagelBot can be quite hefty in terms of how many files they have, and ccgithub is the best option for installation.

To install BagelBot, run this command

**2.** `github clone hugeblank/BagelBot`

and just like that, BagelBot is installed.

## API
The current API is as follows, prefixed by "bagelBot." (subject to change):
- out: provides the program/command with the name and parameters provided after the command. This is the current method used to transfer data to the command that should be executed.
	- inputs: **none**
	- outputs: **String** name of user, **Table** arguments given after the command
- tell: output colorcode formatted text to the user, using the & and then a hexadecimal symbol. &g additionally provides clickable text to the user.
	- inputs: **String** name of user, **String** of text or **Table** of strings, **Boolean** hide the username
	- outputs: **nothing**
- setPersistence: sets data that will remain persistent across a reboot of the bot. Stored nicely in "persistence.json"
	- inputs: **String** name of the persistent value, **Any** data you want to give to that value
	- outputs: **nothing**
- getPersistence: returns the persistent data that was saved to the name.
	- inputs: **String** name of persistent cache
	- output: **Any** data that was stored

## File Structure
If you want to develop a plugin for BagelBot the file/directory structure is as follows:
* plugins (directory for all plugins)
	* \<Plugin Name> (The name of the plugin)
		* commands (where all commands go)
		* help (where the information for all the commands go. should have the same name as the command it's referring to)
		* threads (where all code that should be put on the same loop as the main command executor should go)
		* init.lua (variables and such that you want initialized at the start of the computer)
