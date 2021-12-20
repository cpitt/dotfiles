# zmodload zsh/zprof
export DFM_PATH=$HOME/.dotfile-manager.sh
[ -f $DFM_PATH ] && source $DFM_PATH

# Install zplug if it's doesn't exist
export ZPLUG_HOME=$HOME/.zplug
if [ ! -d $ZPLUG_HOME ]; then
  git clone https://github.com/zplug/zplug.git $ZPLUG_HOME
fi

export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=false

source $ZPLUG_HOME/init.zsh

zplug "felixr/docker-zsh-completion", defer:3
zplug "lib/directories", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh, defer:3
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/theme-and-appearance", from:oh-my-zsh
zplug "mafredri/zsh-async", ignore:"*test.zsh"
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh, defer:3
zplug "plugins/thefuck", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/golang", from:oh-my-zsh
zplug "cpitt/zsh-dotenv", defer:3
zplug "plugins/kubectl", from:oh-my-zsh, defer:3
zplug "plugins/yarn", from:oh-my-zsh, defer:3
zplug "plugins/git", from:oh-my-zsh, defer:3
zplug "plugins/ng", from:oh-my-zsh, defer:3
zplug "sindresorhus/pure", use:pure.zsh, as:theme
zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-completions", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "junegunn/fzf", use:"shell/*.zsh", as:plugin, defer:3
zplug "chrisands/zsh-yarn-completions", defer:2
zplug "junegunn/fzf-bin", \
  from:gh-r, \
  as:command, \
  rename-to:fzf, \
  use:"*darwin*amd64*"

zplug check || zplug install 
zplug load

export FZF_CTRL_R_OPTS='--sort --exact'

# Source .secrets if it exists
# .secrets contains keys and other sensitive data for command line utilities
# that do not have alternative ways of storing secrets
[ -f "$HOME/.secrets" ] && source $HOME/.secrets

# add completion path to fpath
fpath=(
  /usr/local/share/zsh/site-functions
  $fpath
)
# Up the allowed open file descriptors
# Useful for watchers in large projects
ulimit -n 2048


export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

export PATH="/usr/local/opt/ruby/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source /usr/local/etc/bash_completion.d/az

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

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"
