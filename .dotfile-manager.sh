#!/bin/bash

# Dotfile Manager
# Use bare git repo to manage your dotfiles
dfm() {
  git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# lazygit alias for dfm
dfml() {
  if ! command -v lazygit &>/dev/null; then
    echo "lazygit could not be found, please install it to use dfml"
    return
  fi
  lazygit --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"
}

# Enable git completions for DFM
autoload -Uz compinit
compinit
compdef dfm=git

# Add helper function to initialize dotfiles
dfm_init() {
  echo "Cloning dotfiles..."
  git clone --bare https://github.com/cpitt/dotfiles "$HOME"/.dotfiles

  echo "Checking out config..."
  if dfm checkout 2>&1; then
    echo "Checked out config."
  else
    echo "Backing up pre-existing dot files."
    mkdir -p .dotfiles-backup
    dfm checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
  fi

  echo "Retrying config checkout"
  if dfm checkout 2>&1; then
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

# Add check to see if dotfiles repo exists, if not run init
[ ! -d "$HOME"/.dotfiles ] && dfm_init
