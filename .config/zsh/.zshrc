export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"

[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"



HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=1000
SAVEHIST=1000

mkdir -p -- "${HISTFILE:h}"

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY



bindkey -e



ZSH_CACHE_HOME="$XDG_CACHE_HOME/zsh"
ZCOMPDUMP="$ZSH_CACHE_HOME/zcompdump-$ZSH_VERSION"
ZSHRC_FILE="${ZDOTDIR:-$HOME}/.zshrc"

mkdir -p -- "$ZSH_CACHE_HOME"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_HOME/zcompcache"

autoload -Uz compinit

if [[ ! -f "$ZCOMPDUMP" || "$ZSHRC_FILE" -nt "$ZCOMPDUMP" ]]; then
    compinit -d "$ZCOMPDUMP"
else
    compinit -C -d "$ZCOMPDUMP"
fi

_comp_options+=(globdots)


# ── Executable paths ───────────────────────────────────────────
# Zsh's $path array is tied to $PATH. `typeset -U` removes
# duplicate entries automatically.

typeset -U path PATH

path=(
    "$XDG_CONFIG_HOME/emacs/bin"
    "/opt/riscv32i/bin"
    "$CARGO_HOME/bin"
    "/usr/lib64/mpi/gcc/openmpi5/bin"
    "/usr/local/cuda-13.2/bin"
    $path
)

export PATH

export LD_LIBRARY_PATH="/usr/lib64/mpi/gcc/openmpi5/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"


# ── Zsh plugins ────────────────────────────────────────────────
# Preferred XDG locations:
#   $XDG_DATA_HOME/zsh/zsh-autosuggestions
#   $XDG_DATA_HOME/zsh/zsh-syntax-highlighting
#
# The ~/.zsh fallbacks allow the plugins to keep working while
# you are migrating them.

AUTOSUGGESTIONS_FILE="$XDG_DATA_HOME/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

if [[ ! -r "$AUTOSUGGESTIONS_FILE" ]]; then
    AUTOSUGGESTIONS_FILE="$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

[[ -r "$AUTOSUGGESTIONS_FILE" ]] && source "$AUTOSUGGESTIONS_FILE"


SYNTAX_HIGHLIGHTING_FILE="$XDG_DATA_HOME/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ ! -r "$SYNTAX_HIGHLIGHTING_FILE" ]]; then
    SYNTAX_HIGHLIGHTING_FILE="$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

[[ -r "$SYNTAX_HIGHLIGHTING_FILE" ]] && source "$SYNTAX_HIGHLIGHTING_FILE"


# ── Plugin bindings ────────────────────────────────────────────

bindkey '^[k' autosuggest-accept


# ── Aliases ────────────────────────────────────────────────────

# tmux
alias tmns='tmux new-session -t'
alias tmls='tmux ls'
alias tmat='tmux attach -t'
alias tmas='tmux attach'

# ls
alias la='ls -la --color'
alias lc='ls --color=never'
alias ls='ls --color'

# Editors and tools
alias vim='nvim'
alias kssh='kitten ssh'

# Build commands
alias mkcpp='bear -- g++ -std=c++17 *.cpp'
alias mkc='bear -- gcc *.c'

# tmuxinator
alias mux='tmuxinator.ruby4.0'
alias muxs='tmuxinator.ruby4.0 start --no-attach'


# ── Conda ──────────────────────────────────────────────────────

# >>> conda initialize >>>
# Uncomment this block when Conda is needed.
#
# __conda_setup="$('/home/matijak/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
#
# if [[ $? -eq 0 ]]; then
#     eval "$__conda_setup"
# elif [[ -f "/home/matijak/anaconda3/etc/profile.d/conda.sh" ]]; then
#     source "/home/matijak/anaconda3/etc/profile.d/conda.sh"
# else
#     path=("/home/matijak/anaconda3/bin" $path)
# fi
#
# unset __conda_setup
# <<< conda initialize <<<


# ── Fastfetch ──────────────────────────────────────────────────
# Run only for interactive shells.

if [[ -o interactive && -z ${TMUX-} ]] && (( $+commands[fastfetch] )); then
    fastfetch
fi

# ── Prompt ─────────────────────────────────────────────────────
# Keep prompt initialization near the end of the file.

if (( $+commands[oh-my-posh] )); then
    eval "$(
        oh-my-posh init zsh \
            --config "$XDG_CONFIG_HOME/ohmyposh/my-omp.toml"
    )"
fi

