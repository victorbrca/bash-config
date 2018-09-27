bash-config
===

A simple Bash framework (my own take on `bash-it`).

Installing
---

To install `bash-config`, first clone this repo:

```
git clone https://github.com/victorbrca/bash-config.git
```

Then change into the new directory and run 'bash-config.sh'. The installer will:
* Copy the plugin, theme and config files to `${HOME}/.bash-config`
* Enable `bash-config` in `${HOME}.bashrc`
* Copy the main script to the `${HOME}/bin` folder

```
$ bash bash-config.sh install
Warning!! Running the install will overwrite your config with files from the current dir. Proceed with caution.
Hit "Enter" to continue or "Ctrl+c" to quit:
Creating bash-config dir... ok
Copying files... ok
Enabling config file... ok
Copying bash-config.sh to /home/victor/bin... ok
```

Listing
---

You can use `bash-config list` or `bash-config plugins` to list all plugins and themes available:

```
bash-config Plugins and Themes

Plugins
[ ] apt                        apt and dpkg aliases
[ ] bash-colors                
[ ] bash                       Settings for Bash
[ ] bpm-tools                  Aliases for id3 tag an mp3 file
[ ] exa                        exa aliases
[ ] files                      File manipulation aliases
[ ] fzf                        fzf aliases
[ ] git                        Git aliases
[ ] hugo                       Hugo aliases
[ ] lastpass-cli               Aliases for lastpass-cli
[ ] ls                         ls aliases
[ ] media                      Misc media manipulation aliases
[ ] networking                 Mist networking aliases
[ ] notification               Misc notification aliases
[ ] pacman                     Aliases for pacman
[ ] ssl-tools                  Aliases for SSL
[ ] systemd                    SystemD aliases
[ ] trash-cli                  Converts rm to use trash-cli
[ ] yaourt                     Aliases for yaourt
[ ] yum                        Aliases for yum
[ ] zypper                     Aliases for zypper

Themes
[ ] bubble-lines               A cool and bubbly Bash prompt
[x] powerline-simple           A simplified powerline prompt
[ ] simple-git                 Displays a simple prompt with Git info
[ ] simple                     Displays a simple prompt
```


Enabling/Disabling Themes
---

You can enable or disable themes with the enable/disable command and the option `-t` (for themes).
```
bash-config enable -t powerline-simple

bash-config disable -t simple
```

For more information on themes, look at the [themes](./themes/README.md) page

Enabling/Disabling Plugins
---

Plugins are Bash aliases and functions that when enabled, get loaded to your Bash (via `~/.bashrc`).

To enable plugins, you can specify one or multiple plugins:

```
bash-config enable -p media

bash-config disable -p media
```

Multiple
```
$ bash-config enable -p bash,bpm-tools,exa,files,fzf,git,hugo,lastpass-cli,media,networking,notification,pacman,ssl-tools,systemd,trash-cli,yaourt
Enabled the plugin "bash"
Enabled the plugin "bpm-tools"
Enabled the plugin "exa"
Enabled the plugin "files"
Enabled the plugin "fzf"
Enabled the plugin "git"
Enabled the plugin "hugo"
Enabled the plugin "lastpass-cli"
Enabled the plugin "media"
Enabled the plugin "networking"
Enabled the plugin "notification"
Enabled the plugin "pacman"
Enabled the plugin "ssl-tools"
Enabled the plugin "systemd"
Enabled the plugin "trash-cli"
Enabled the plugin "yaourt"
```

The current list of plugins is:
```
 apt                        apt and dpkg aliases
 bash-colors                
 bash                       Settings for Bash
 bpm-tools                  Aliases for id3 tag an mp3 file
 exa                        exa aliases
 files                      File manipulation aliases
 fzf                        fzf aliases
 git                        Git aliases
 hugo                       Hugo aliases
 lastpass-cli               Aliases for lastpass-cli
 ls                         ls aliases
 media                      Misc media manipulation aliases
 networking                 Mist networking aliases
 notification               Misc notification aliases
 pacman                     Aliases for pacman
 ssl-tools                  Aliases for SSL
 systemd                    SystemD aliases
 trash-cli                  Converts rm to use trash-cli
 yaourt                     Aliases for yaourt
 yum                        Aliases for yum
 zypper                     Aliases for zypper
```
