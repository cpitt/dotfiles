# Cpitt's Dotfile

My dotfiles managed using a bare git repository

## Installation

```sh

curl -Lks https://raw.githubusercontent.com/cpitt/dotfiles/master/.dotfile-manager.sh | /bin/bash
```

## Pulling dotfiles from repo

```sh
dfm pull
```

## Adding/updating new/changed dotfiles

```sh
dfm add .newFile
dfm commit -m 'adding .newFile'
dfm push
```

## Using Lazygit with dfm

```sh
dfml
```
