# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Settings
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Plugins (Note: Ensure these are cloned to $ZSH_CUSTOM/plugins/)
plugins=(
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  zsh-completions 
  zsh-history-substring-search 
  zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

# --- Navigation & Storage ---
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias sd='cd ~/storage/shared'
alias docs='cd ~/storage/shared/Documents'
alias dl='cd ~/storage/shared/Download'
alias dcim='cd ~/storage/shared/DCIM'
alias zrc='nano ~/.zshrc'
alias reload='source ~/.zshrc'

# --- Modern CLI Tools ---
alias ls='eza --icons --group-directories-first'
alias l='eza -lh --icons --group-directories-first'
alias la='eza -lah --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias rg='rg --smart-case'

# --- yt-dlp ---
alias ytv='yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" --merge-output-format mp4 -o "~/storage/shared/Download/%(title)s.%(ext)s"'
alias yta='yt-dlp -x --audio-format mp3 -o "~/storage/shared/Download/%(title)s.%(ext)s"'

# --- Package Management ---
alias up='pkg update && pkg upgrade -y'
alias in='pkg install'
alias clean='pkg clean && rm -rf ~/.cache/*'

# --- Termux Specific Functions ---

# Copy file contents to Android Clipboard
catcopy() {
  if [[ -f "$1" ]]; then
    termux-clipboard-set < "$1"
    echo "📋 Contents of '$1' copied to clipboard."
  elif [[ -z "$1" ]]; then
    echo "Usage: catcopy <filename>"
  else
    echo "Error: File '$1' not found."
  fi
}

# Paste Android clipboard into a new file
clip-paste() {
  if [[ -n "$1" ]]; then
    termux-clipboard-get > "$1"
    echo "📄 Clipboard saved to '$1'."
  else
    termux-clipboard-get
  fi
}

# Quick access to Termux battery and hardware info
sysinfo() {
  echo "--- Battery Status ---"
  termux-battery-status
  echo "\n--- WiFi Connection ---"
  termux-wifi-connectioninfo
}

cppath() {
  local path_to_copy
  # If no argument, use current directory. If argument, get absolute path of file.
  if [[ -z "$1" ]]; then
    path_to_copy=$(pwd)
  else
    path_to_copy=$(realpath "$1")
  fi

  echo -n "$path_to_copy" | termux-clipboard-set
  echo "📍 Path copied to clipboard: $path_to_copy"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export TERM=xterm-256color
