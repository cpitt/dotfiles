#!/bin/zsh
#Check if thefuck is installed and setup alias
[ -x "$(command -v thefuck)" ] && eval $(thefuck --alias f)
