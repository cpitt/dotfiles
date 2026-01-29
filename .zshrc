##############################################################
#Setup and Execute Dotfile Manager
##############################################################
export DFM_PATH=$HOME/.dotfile-manager.sh
[ -f $DFM_PATH ] && source $DFM_PATH

# Source .secrets if it exists
# .secrets contains keys and other sensitive data for command line utilities
# that do not have alternative ways of storing secrets
[ -f "$HOME/.secrets" ] && source $HOME/.secrets

# Source .zshrc.local if it exists
[ -f "$HOME/.zshrc.local" ] && source $HOME/.zshrc.local

# Source all config files in ~/.config/zsh/
for file in ~/.config/zsh/*.zsh(N); do
  source "$file"
done


###############################################################
#Setup Path 
###############################################################
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


#################################################################
# Setup plugin default variables
#################################################################

#Auto start tmux when opening a terminal
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=false

# Use the source method for initializing key mapping so that it doesn't interfere with the FZF plugin. 
export ZVM_INIT_MODE=sourcing

# Configure FZF
export FZF_DEFAULT_OPTS='--tmux center --style full'
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"


#############################################################
# Install Zplug and Plugins
#############################################################

# Install zplug if it's doesn't exist
export ZPLUG_HOME=$HOME/.zplug
if [ ! -d $ZPLUG_HOME ]; then
  git clone https://github.com/zplug/zplug.git $ZPLUG_HOME
fi

source $ZPLUG_HOME/init.zsh

# Core libraries and early environment
zplug "lib/theme-and-appearance", from:oh-my-zsh
zplug "lib/directories", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "/catppuccin/zsh-syntax-highlighting", as:theme, use:"themes/catppuccin_mocha-zsh-syntax-highlighting.zsh" 
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
zplug "jeffreytse/zsh-vi-mode", defer:3
zplug "junegunn/fzf", use:"shell/*.zsh", as:plugin, defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:3

zplug check || zplug install 
zplug load
