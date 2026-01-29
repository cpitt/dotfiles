## function that takes in a title and opens a new file in vim with the format YYYY-MM-DD_meetingname.md
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
