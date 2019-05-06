# Allium

Allium is a simple lua plugin interface for minecraft.
It uses Computercraft's Command Computer, and Plethora Peripherals' Creative Chat Recorder to function.

The command computer can already do many things, being a programmable command block. Allium takes that power to the next level and expands functionality to allow for plugins to be registered. From there you can add commands that get triggered by players, threads that can do command based things without the need of a command to execute them, and data that can be stored in a persistent file so that things you want to hang onto don't get lost in the event of a crash or restart.

Installation instructions and further information, in a more digestable form can be found on the [wiki](https://hugeblank.github.io/Allium-wiki/).

## Forking this repository

There are some places you might want to check out after you fork, and before you start testing your code.

1. The pastebin [installer](https://www.pastebin.com/LGwrkjxm). You are free to make your own installer to your fork with this code, simply change the `repo` string to "[your github username] [the name of your Allium repository] [the branch you want to clone from] [location]".
2. The startup file of your fork. Set the `deps` and `allium` values to true in the `update` section in `/cfg/allium.lson` file, and make sure to replace the marked line with your repo, like above. Additionally, redirect the depman instance and/or listing to your own, if necessary.