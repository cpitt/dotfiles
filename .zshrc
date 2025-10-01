#Setup and Execute Dotfile Manager
export DFM_PATH=$HOME/.dotfile-manager.sh
[ -f $DFM_PATH ] && source $DFM_PATH

# Source .secrets if it exists
# .secrets contains keys and other sensitive data for command line utilities
# that do not have alternative ways of storing secrets
[ -f "$HOME/.secrets" ] && source $HOME/.secrets


#Auto start tmux when opening a terminal
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=false

# Configure FZF
export FZF_CTRL_R_OPTS='--tmux --sort --exact'

#Setup Path 
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"

#Setup Brewfile location
export HOMEBREW_BUNDLE_FILE="$HOME/Brewfile"

#Set default editor
export EDITOR=nvim

# write history immediately so it can be shared between multiple sessions, useful when running tmux
setopt INC_APPEND_HISTORY

# Install zplug if it's doesn't exist
export ZPLUG_HOME=$HOME/.zplug
if [ ! -d $ZPLUG_HOME ]; then
  git clone https://github.com/zplug/zplug.git $ZPLUG_HOME
fi

source $ZPLUG_HOME/init.zsh

# Core libraries and early environment
zplug "lib/directories", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/termsupport", from:oh-my-zsh
zplug "plugins/dotenv", from:oh-my-zsh
zplug "zplug/zplug", hook-build:'zplug --self-manage'

# Early interactive tools
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh, defer:1
zplug "plugins/git", from:oh-my-zsh, defer:1
zplug "plugins/starship", from:oh-my-zsh, defer:1
zplug "plugins/docker-compose", from:oh-my-zsh, defer:1
zplug "plugins/brew", from:oh-my-zsh, defer:1
zplug "lukechilds/zsh-nvm", defer:1

# Completions before compinit (no defer >=2)
zplug "zsh-users/zsh-completions"

# Deferred / heavier UI + helpers (load after compinit)
zplug "plugins/thefuck", from:oh-my-zsh, defer:2
# Use the source method for initializing key mapping so that it doesn't interfere with the FZF plugin. 
ZVM_INIT_MODE=sourcing
zplug "jeffreytse/zsh-vi-mode", defer:2
zplug "junegunn/fzf", use:"shell/*.zsh", as:plugin, defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:3

zplug check || zplug install 
zplug load



test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
