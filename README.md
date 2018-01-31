# BagelBot
BagelBot is an advanced lua plugin interface for minecraft.
It uses ComputerCraft's Command Computer, and a chat listening device to function. Currently the bot supports detection for Plethora Peripheral's Creative Chat Recorder, and Computronic's Creative Chatbox.

## Install
To install BagelBot, run this command, it's that simple!

**1.** `pastebin run LGwrkjxm`

The installer installs [Eric Wieser's](https://github.com/eric-wieser/) [computercraft-github](https://github.com/eric-wieser/computercraft-github), a github repository downloader that is necessary to download the bot, and the plugins that can be installed.

## Base Commands
`!help`: lists the help entries for the installed plugins.

`!plugins`: Lists the plugins that are installed, based on the name of the directory that they're found in.

`!github`: Links to the github repo for [BagelBot](https://github.com/hugeblank/BagelBot).

## API
The current API is as follows, prefixed by "bagelBot." and then one of the methods listed here:
- out: provides the program/command with the name and parameters provided after the command. This is the current method used to transfer data to the command that should be executed.
	- inputs: **none**
	- outputs: **String** name of user, **Table** arguments given after the command, **String** plugin that the command originates from
- tell: output colorcode formatted text to the user, using the & and then a hexadecimal symbol. &g additionally provides clickable text to the user.
	- inputs: **String** name of user, **String** of text or **Table** of strings, **Boolean** hide the username
	- outputs: **nothing**
- setPersistence: sets data that will remain persistent across a reboot of the bot. Stored nicely in "persistence.json"
	- inputs: **String** name of the persistent value, **Any** data you want to give to that value
	- outputs: **nothing**
- getPersistence: returns the persistent data that was saved to the name.
	- inputs: **String** name of persistent cache
	- output: **Any** data that was stored
- findCommand: returns a command, or data pertaining to a command.
	- inputs: **String** name of command, **String** (optional) name of plugin, **String** (optional) *"command"*; list executable command functions, *"help"*; list help text entries, *"suggest"*; list command suggestion entries, *"source"*; list the plugin sources of executable command functions, *nil*; put all of these into a table, in the same order they appear here.
	- outputs: **Table** of data dependent on what the third parameter was.
- source: returns the current executing source, an alternative way to get the third argument of out.
	- inputs: **none**
	- outputs: **String** name of execution source
- queueCommand: queues a chat based command event dependent on the current peripheral attached
	- inputs: **String** name of player, **String** any command
	- outputs: **nothing**
- getPlayers: provides a table containing player names
	- inputs: **none**
	- outputs: **Table** list of player names

## File Structure
If you want to develop a plugin for BagelBot the file/directory structure is as follows:
* plugins (directory for all plugins)
	* \<Plugin Name> (The name of the plugin)
		* commands (where all commands go)
		* help (where the information for all the commands go. should have the same name as the command it's referring to)
		* threads (where all code that should be put on the same level as the main command executor should go)
		* init.lua (variables and such that you want initialized at the start of the computer)

## Cloning this repository
It's worth noting that there are some places you might want to check out after you fork, and before you start testing your code. 

1. The pastebin [installer](https://www.pastebin.com/LGwrkjxm). You are free to make your own installer to your fork with this code, simply change the `repo` string to "your github username"/"the name of your BagelBot repository".
2. The startup file of your fork. There is a line that has a comment along with it. Change that repo name from the official BagelBot repository to your forked repository, similar to the style shown above.
