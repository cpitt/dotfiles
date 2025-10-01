#!/bin/bash
setToken() {
  #do things with parameters like $1 such as
  ~/mfa.sh $1 $2
  source ~/.token_file
  echo "Your creds have been set in your env."
}
alias mfa=setToken

alias vi=vim

## fucntion that takes in a title and opens a new file in vim with the format YYYY-MM-DD_meetingname.md
makenote() {
  if [ -z "$1" ]; then
    echo "Please provide a note title."
    return 1
  fi
  local meeting_name="$1"
  local date_str
  date_str=$(date +%Y-%m-%d)
  local file_name="${date_str}_${meeting_name}.md"
  nvim "$file_name"
}
