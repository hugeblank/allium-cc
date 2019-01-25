# Allium
Allium is a simple lua plugin interface for minecraft.
It uses Computercraft's Command Computer, and Plethora Peripherals' Creative Chat Recorder to function.

The command computer can already do many things, being a programmable command block. Allium takes that power to the next level and expands functionality to allow for plugins to be registered. From there you can add commands that get triggered by players, threads that can do command based things without the need of a command to execute them, and data that can be stored in a persistent file so that things you want to hang onto don't get lost in the event of a crash or restart.

Allium uses **[Raisin](https://github.com/hugeblank/raisin/)**, a next generation thread manager made by me, hugeblank. If you're a prospective Allium plugin developer, you may want to skim the documentation, found in the Readme.

Allium also uses a chat text formatting API provided by [roger109z](https://github.com/roger109z/). I (hugeblank) personally haven't touched it (even though it is in my repo) since he's created it as it works flawlessly. 

## Install
To install Allium, run this command, it's that simple!

`pastebin run LGwrkjxm`

The installer installs Apemanzilla's [gitget](http://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/), a github repository downloader that is necessary to download the bot, and the plugins that can be installed.

## Base Commands
`!help`: Lists the info entries for the installed plugins

`!plugins`: Lists the plugins that are installed.

`!credits`: Links to the github repo for [Allium](https://github.com/hugeblank/Allium), and to the people that made Allium.

## API
Quick reference for plugin developers:

### `allium`: 
`assert`: Lua's generic assert, with the ability to set the error level
- **Parameters**
  - _boolean_: condition to test
  - _string_: error message
  - _number_: error level
- **Returns**
  - _none_

`sanitize`: Sanitize plugin names to meet allium's ID standards
- **Parameters**
  - _string_: plugin/command name string
- **Returns**
  - _string_: valid allium plugin/command ID

`tell`: Output colorcode formatted text to the user, using the & and then a hexadecimal symbol. Additional codes are also provided that perform other actions.
- **Parameters**
  - _string_: name of user
  - _string_: text __OR__ _table_: list of text
  - _[string]_: label replacement __OR__ _[boolean]_: hide label
- **Returns**
  - _string_: execution results

`getPlayers`: Lists all online players
- **Parameters**
  - _none_
- **Returns**
  - _table_: list of online players

`getInfo`: Get information for one or all plugins
- **Parameters**
  - _[string]_: allium plugin ID
- **Returns**
  - _table_: table of information organized as `table[plugin][command] = information`

`getName`: Get the human readable name from the plugin ID
- **Parameters**
  - _string_: allium plugin ID
- **Returns**
  - _string_: human readable plugin name

`register`: The big boy, Register an Allium plugin
- **Parameters**
  - _string_: plugin name, converted to allium plugin ID
  - _[string]_: optional manually set human readable plugin name
- **Returns**
  - _table_: list of functions to register commands/threads/persistent data (see below)

### `register`: 
`command`: Register a command within this plugin
- **Parameters**
  - _string_: command name
  - _function_: function to execute
  - _string_: information about the command
  - _[string]_: command usage formatted as `<required | first | arguments> [optional | second | arguments]`
- **Returns**
  - _none_

`thread`: Register a thread within this plugin
- **Parameters**
  - _function_: function to turn into a thread
- **Returns**
  - _none_

`setPersistence`: Sets data that will remain persistent across a reboot of Allium.
- **Parameters**
  - _string_: name of the persistent value
  - _any_: data to assign to value
- **Returns**
  - _none_

`getPersistence`: Sets data that will remain persistent across a reboot of Allium.
- **Parameters**
  - _string_: name of the persistent value
- **Returns**
  - _any_: data that was assigned to that value
---
## Formatting Codes
The following characters are all valid for formatting in `allium.tell` when prefixxed with an `&`.

### Colors
r - reset formatting
0 - black
1 - dark blue
2 - dark green
3 - dark aqua
4 - dark red
5 - dark purple
6 - gold
7 - gray
8 - dark gray
9 - blue
a - green
b - aqua
c - red
d - light purple
e - yellow
f - white

### Actions
g - execute text | `&g(!allium:help)Click for help!&r`
h - hover text | `&h(Hi there :P)Mouse over me!&r`
i - clickable link | `&i(https://google.com)Go to google!&r`
s - suggest text | `&s(I'm in your bar now!)Click on me!&r`

### Emphases
k - obfuscated
l - bold
m - strikethrough
n - italic
o - underline
---
## Cloning this repository
It's worth noting that there are some places you might want to check out after you fork, and before you start testing your code. 

1. The pastebin [installer](https://www.pastebin.com/LGwrkjxm). You are free to make your own installer to your fork with this code, simply change the `repo` string to "your github username"/"the name of your Allium repository".
2. The startup file of your fork. There is a line that has a comment along with it. Change that repo name from the official Allium repository to your forked repository, similar to the style shown above.