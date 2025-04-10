#!/bin/bash

function setup_brew {
	#check if homebrew is installed
	if ! command -v brew >/dev/null; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		if ! command -v brew >/dev/null; then
			echo "unables to install homebrew"
			exit 2
		fi
	else
		echo "updating homebrew"
		brew update

	fi

	echo "Running brew bundle"
	brew bundle
}
