# Loop through everything in ./functions and source it. 

for file in ~/.config/zsh/functions/*.zsh(N); do
  source "$file"
done
