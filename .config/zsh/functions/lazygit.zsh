lazygit() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    command lazygit "$@"
  else
    command lazygit --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
  fi
}
