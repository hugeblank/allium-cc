# Allium
Allium is a simple lua plugin interface for minecraft.
It uses Computercraft's Command Computer, and Plethora Peripherals' Creative Chat Recorder to function.

The command computer can already do many things, being a programmable command block. Allium takes that power to the next level and expands functionality to allow for plugins to be registered. From there you can add commands that get triggered by players, threads that can do command based things without the need of a command to execute them, and data that can be stored in a persistent file so that things you want to hang onto don't get lost in the event of a crash or restart.

Allium uses **[Raisin](https://github.com/hugeblank/raisin/)**, a next generation thread manager made by me, hugeblank. If you're a prospective Allium plugin developer, you may want to skim the documentation, found in the Readme.

Allium also uses a chat text formatting API provided by [roger109z](https://github.com/roger109z/). I (hugeblank) personally haven't touched it (even though it is in my repo) since he's created it as it works flawlessly.

## Install
To install Allium, run this command, it's that simple!

`pastebin run LGwrkjxm`

The installer installs:

- The Allium Repo - allium.lua, plugins/allium-stem.lua, colors.lua, readme.md

- The Raisin Repo - raisin/raisin.lua, raisin/readme.md

- Apemanzilla's [gitget](http://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/), a github repository downloader that is necessary to download Allium, and the plugins that can be installed. 

- repolist.csh - A _Craftos SHell_ file, where you can gitget various plugins and utilities and keep them up to date.

- startup.lua - startup file that runs the repolist file, then runs Allium. When Allium crashes/exits it will reboot after 3 seconds unless interrupted.

- persistence.ltn - A _Lua Table Notation_ file containing all serialized persistence entries for each plugin.

**Want More?** Check out the [wiki](https://github.com/hugeblank/Allium/wiki/)!

## Forking this repository
It's worth noting that there are some places you might want to check out after you fork, and before you start testing your code. 

1. The pastebin [installer](https://www.pastebin.com/LGwrkjxm). You are free to make your own installer to your fork with this code, simply change the `repo` string to "[your github username] [the name of your Allium repository] [the branch you want to clone from] [location]".
2. The startup file of your fork. Change the debug variable, and make sure to replace the marked line with your repo, like above.