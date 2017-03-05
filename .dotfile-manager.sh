#!/bin/sh

# Dotfile Manager
# Use bare git repo to manage your dotfiles
alias dfm="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@"

function dfm_init {
  echo "Cloning dotfiles..."
  git clone --bare https://github.com/cpitt/dotfiles $HOME/.dotfiles

  echo "Checking out config..."
  dfm checkout 2>&1
  if [ $? = 0 ]; then
    echo "Checked out config."
  else
    echo "Backing up pre-existing dot files."
    mkdir -p .dotfiles-backup
    dfm checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
  fi

  echo "Retrying config checkout"
  dfm checkout 2>&1
  if [ $? = 0 ]; then
    echo "checked out config"
  else
    echo "config checkout failed, clean your environment and try again"
    exit 1
  fi

  dfm config status.showUntrackedFiles no

  # Get submodules
  dfm submodule init
  dfm submodule update --remote

  # Run install scripts 
  read -p "Would you like to run bootstrap scripts (y/n):" -n -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    source ./.setup-scripts/bootstrap.sh
  else 
    exit 0
  fi
}

[ ! -d $HOME/.dotfiles ] && dfm_init
