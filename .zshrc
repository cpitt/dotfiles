# Avoid inheriting stale zsh function paths after Homebrew zsh upgrades.
fpath=(
  /opt/homebrew/share/zsh/site-functions
  /opt/homebrew/opt/zsh/share/zsh/functions
)
export FPATH="${(j.:.)fpath}"

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
export PATH="$HOME/.local/bin:$PATH"

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
# Install Antidote Plugins
#############################################################

source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

# Homebrew supplies the additional completion definitions in $fpath. Initialize
# completion before loading Oh My Zsh plugins that call compdef.
autoload -Uz compinit
compinit

antidote load "$HOME/.zsh_plugins.txt"
