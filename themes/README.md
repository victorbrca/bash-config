Themes
===

Bash prompt themes that can be enabled with `bash-config`.

Only one theme can be enabled at time. If more than one theme is enabled you will get a warning; if no theme is enabled you also get a warning:

```
[bash-config] too many themes enabled
```

```
[bash-config] No themes are enabled
```

The following themes are available:

```
bubble-lines               A cool and bubbly Bash prompt
powerline-simple           A simplified powerline prompt
simple-git                 Displays a simple prompt with Git info
simple                     Displays a simple prompt
```

- - -

bubble-lines
---

See https://github.com/victorbrca/bubble-lines.git for the main project.

![](https://raw.githubusercontent.com/victorbrca/bubble-lines/master/images/prompt.1.png)

The prompt provides the following information:

- Previous exit code
- Username
- Current path
- Battery status
- sudo cached credentials
- Git status

```
●─[victor]─[~/.bash-config/themes]─[⏻ 80%]─[ⵌ]─[master  ✚87]─●
|    |                 |              |      |         |- Git status
|    |                 |              |      |- sudo cached
|    |                 |              |- Battery status
|    |                 |- CWD
|    |- Username
|- Exit code
```

- - -

powerline-simple
---

See https://github.com/victorbrca/powerline-simple.git for the main project.

![](https://raw.githubusercontent.com/victorbrca/powerline-simple/master/images/prompt.png)

The prompt provides the following information:

- Previous exit code
- Username
- Hostname (when connecting via SSH)
- Battery status
- sudo cached credentials
- Current path
- Git status

- - -

simple-git
---

```
~/bin  master  ✚49 ✓ $
```

The prompt provides the following information:

- Hostname (when connecting via SSH)
- Current path
- Git status
- Previous exit code

- - -

simple
---

```
/etc/systemd ✓ $
```

The prompt provides the following information:

- Hostname (when connecting via SSH)
- Current path
- Previous exit code
