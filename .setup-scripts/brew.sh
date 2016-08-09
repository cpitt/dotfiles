#!/bin/sh

function setup_brew {
  #check if homebrew is installed
  brew_bin=$(which brew) 2>&1 > /dev/null
  if [[ $? != 0 ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      echo "unables to install homebrew"
      exit 2
    fi
  else
    echo "updating homebrew"
    brew update 

  fi
  
  echo "installing brew bundle"
  brew tap Homebrew/bundle

  echo "Running brew bundle"
  brew bundle 
}
