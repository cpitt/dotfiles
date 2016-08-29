#!/bin/sh

function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

echo "Cloning dotfiles..."
git clone --bare https://github.com/cpitt/dotfiles2 $HOME/.dotfiles


echo "Checking out config..."
config checkout 2>&1
if [ $? = 0 ]; then
  echo "Checked out config."
else
  echo "Backing up pre-existing dot files."
  mkdir -p .dotfiles-backup
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi

echo "Retrying config checkout"
config checkout 2>&1
if [ $? = 0 ]; then
  echo "checked out config"
else
  echo "config checkout failed, clean your environment and try again"
  exit 1
fi

config config status.showUntrackedFiles no

# Get submodules
config submodule init
config submodule update

# Run install scripts 
read -p "Would you like to run bootstrap scripts (y/n):" -n -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  source ./.setup-scripts/bootstrap.sh
else 
  exit 0
fi
