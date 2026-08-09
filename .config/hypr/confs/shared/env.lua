-- Resolve $HOME and $XDG_* to actual paths — hyprlang expands shell
-- variables in `env =` but hl.env() passes the literal string through,
-- so every $VAR must be expanded here before being set.

local home = os.getenv("HOME")
local runtime = os.getenv("XDG_RUNTIME_DIR")
local config_home = home .. "/.config"
local cache_home = home .. "/.cache"
local data_home = home .. "/.local/share"
local state_home = home .. "/.local/state"

-- Cursor and rendering
hl.env("XCURSOR_THEME", "Qogir-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GTK_THEME", "Catppuccin-Dark")
hl.env("RUSTICL_ENABLE", "radeonsi")
hl.env("HSA_OVERRIDE_GFX_VERSION", "10.3.0")

-- XDG base directories (must be set before dependent paths)
hl.env("XDG_CONFIG_HOME", config_home)
hl.env("XDG_CACHE_HOME", cache_home)
hl.env("XDG_DATA_HOME", data_home)
hl.env("XDG_STATE_HOME", state_home)

-- XDG-relative tool paths
hl.env("HISTFILE", state_home .. "/bash/history")
hl.env("CARGO_HOME", data_home .. "/cargo")
hl.env("DOTNET_CLI_HOME", data_home .. "/dotnet")
hl.env("GDBHISTFILE", config_home .. "/gdb/gdb_history")
hl.env("NODE_REPL_HISTORY", state_home .. "/node_repl_history")

-- npm
hl.env("NPM_CONFIG_INIT_MODULE", config_home .. "/npm/config/npm-init.js")
hl.env("NPM_CONFIG_CACHE", cache_home .. "/npm")
hl.env("NPM_CONFIG_TMP", runtime .. "/npm")

-- Python
hl.env("PYTHON_HISTORY", state_home .. "/python_history")
hl.env("PYTHONSTARTUP", config_home .. "/python/pythonrc.py")

-- Virtualenvs
hl.env("WORKON_HOME", data_home .. "/virtualenvs")

-- GTK, cursors, readline
hl.env("GTK2_RC_FILES", config_home .. "/gtk-2.0/gtkrc")
hl.env("XCURSOR_PATH", "/usr/share/icons:" .. data_home .. "/icons")
hl.env("INPUTRC", config_home .. "/readline/inputrc")

-- Shell
hl.env("ZDOTDIR", config_home .. "/zsh")
hl.env("HISTFILE", state_home .. "/zsh/history")

-- Wine
hl.env("WINEPREFIX", data_home .. "/wine")
