HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


autoload -Uz compinit
compinit
_comp_options+=(globdots)

fastfetch -c examples/10.jsonc

export XDG_CONFIG_HOME=$HOME/.config

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/my-omp.toml)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


#aliases

#tmux aliases
alias tmns="tmux new-session -t"
alias tmls="tmux ls"
alias tmat="tmux attach -t"
alias tmas="tmux attach"

alias la="ls -la --color"
alias ll="ls -l --color"
alias ls="ls --color"
