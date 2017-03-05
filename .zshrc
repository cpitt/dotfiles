# Install zplug if it's doesn't exist
export DFM_PATH=$HOME/.dotfile-manager.sh
[ -f $DFM_PATH ] && source $DFM_PATH

export ZPLUG_HOME=$HOME/.zplug
if [ ! -d $ZPLUG_HOME ]; then
  git clone https://github.com/zplug/zplug.git $ZPLUG_HOME
fi

export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=false

source $ZPLUG_HOME/init.zsh

zplug "felixr/docker-zsh-completion"
zplug "lib/directories", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh, defer:3
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/theme-and-appearance", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/thefuck", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "mafredri/zsh-async," from:github
zplug "sindresorhus/pure," use:pure.zsh, as:theme
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "junegunn/fzf-bin", \
    from:gh-r, \
    as:command, \
    rename-to:fzf, \
    use:"*darwin*amd64*" \
    hook-build:'./install --key-bindings --completion --no-update-rc'


zplug check || zplug install
zplug load 

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_CTRL_R_OPTS='--sort --exact'

alias vim=nvim

# source .secrets if it exists
# .secrets contains keys and other sensitive data for command line utilities
# that do not have alternative ways of storing secrets
[ -f ~/.secrets ] && source .secrets

ulimit -n 2048
