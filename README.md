## Introduction

CLI tool for fetching and updating minecraft mods from CurseForge.

## Usage
```
mmm init <version>      Initiate for mmm
mmm add <mod_id>        Add a new mod
mmm remove <mod_id>     Remove a installed mod
mmm list                List all installed mods
mmm update              Check update for installed mods
```

## Example
```
# switch to your .minecraft folder
$ cd ~/Game/Minecraft/.minecraft

# this will generate the following config files:
# `~/.config/mmm/config.json` used for tracking .minecraft folder path and minecraft version
# `.minecraft/mods.json` used for tracking all installed mod info
$ mmm init 1.16.5
* minecraft folder: /home/tunkshif/Downloads/TMP/Minecraft
* minecraft version: 1.16.5

# install a mod from curseforge.com, the mod id can be found in the url of the curseforge project page
# for example, https://www.curseforge.com/minecraft/mc-mods/jei, then the mod id for JEI is `jei`
# mmm will download the latest mod file according to the minecraft version
# if no matching minecraft version found, it will download the latest uploaded mod
$ mmm add jei
Find jei-1.16.5-7.7.0.99.jar, start downloading...
Done!
```

## TODO

* [x] install specific mod
* [] do version check before download
* [] remove installed mod
* [] update installed mod

## Requirements

* Elixir 1.11

## Installation

### Using `mix escript.install`

The script will be installed into `$HOME/.mix/escripts` by default, remember to add the folder to your `$PATH`.

```sh
mix escript.install git https://github.com/TunkShif/mc-mod-manager
```

### Mannal Installation

```sh
git clone https://github.com/TunkShif/mc-mod-manager && cd mc-mod-manager
MIX_ENV=prod mix escript.build
mv ./mmm /path/to/yout/bin/folder
```