#! /bin/zsh
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1

# Retire the previous override so plain `brew bundle` remains project-local.
unset HOMEBREW_BUNDLE_FILE

# Manage the personal bundle stored at Homebrew's global Brewfile location.
brew-personal() {
  brew bundle "$@" --global
}

# Manage the optional work bundle enabled by a machine-local configuration.
brew-work() {
  if [[ -z ${WORK_BREWFILE:-} ]]; then
    print -u2 "Work dependencies are not enabled on this machine"
    return 1
  fi

  brew bundle "$@" --file="$WORK_BREWFILE"
}
