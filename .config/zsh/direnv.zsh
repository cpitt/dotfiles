eval "$(direnv hook zsh)"

autoload -Uz add-zsh-hook

_direnv_prompt_allow() {
  [[ -f .envrc ]] || return
    direnv status 2>/dev/null | grep -q '^Found RC allowed 0$' && return
    {
    local answer

    printf 'Allow .envrc in %s? [y/N] ' "$PWD"
    read -r answer
    if [[ "$answer" == [yY] ]]; then
      direnv allow . && _direnv_hook
    fi
    }
}
add-zsh-hook chpwd _direnv_prompt_allow
