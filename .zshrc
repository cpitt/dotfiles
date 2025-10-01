# zmodload zsh/zprof
export DFM_PATH=$HOME/.dotfile-manager.sh
[ -f $DFM_PATH ] && source $DFM_PATH

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
zplug "plugins/dotenv", from:oh-my-zsh
zplug "zplug/zplug", hook-build:'zplug --self-manage'

# Early interactive tools
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh, defer:1
zplug "plugins/git", from:oh-my-zsh, defer:1
zplug "plugins/starship", from:oh-my-zsh, defer:1

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

# Configure FZF
export FZF_CTRL_R_OPTS='--tmux --sort --exact'

#Auto start tmux when opening a terminal
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=false

# Source .secrets if it exists
# .secrets contains keys and other sensitive data for command line utilities
# that do not have alternative ways of storing secrets
[ -f "$HOME/.secrets" ] && source $HOME/.secrets

# Up the allowed open file descriptors
# Useful for watchers in large projects
ulimit -n 2048


export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

export PATH="/usr/local/opt/ruby/bin:$PATH"


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export NVM_DIR="$HOME/.nvm"
. "$(brew --prefix nvm)/nvm.sh"

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc "/usr/local/opt/nvm/nvm.sh"
. "$HOME/alias.sh"
# write history immediately
setopt INC_APPEND_HISTORY

export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"


# Work Around for open ssl
# export NODE_OPTIONS=--openssl-legacy-provider

HOMEBREW_BUNDLE_FILE="$HOME/Brewfile"

export EDITOR=nvim

