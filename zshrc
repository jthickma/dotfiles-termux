# ~/.zshrc (Termux) — simplified

# ---------- History (early) ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY
setopt SHARE_HISTORY INC_APPEND_HISTORY
setopt EXTENDED_GLOB

# ---------- zsh behavior ----------
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ---------- Termux integration ----------
# Helps CLI apps that try to open URLs/files in a browser.
# Also makes xdg-open/open behave consistently on Android.
if command -v termux-open >/dev/null 2>&1; then
  export BROWSER=termux-open
  alias xdg-open='termux-open'
  alias open='termux-open'
fi


ZSH_AUTOCOMPLETE="$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
[[ -r "$ZSH_AUTOCOMPLETE" ]] && source "$ZSH_AUTOCOMPLETE"

bindkey              '^I'         menu-complete
bindkey "$terminfo[kcbt]"         reverse-menu-complete

# 2) In the completion menu: Tab/Shift-Tab move selection
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]"         reverse-menu-complete

# 3) Arrow keys always move the cursor even while menu is open (Termux-friendly escape codes)
bindkey -M menuselect '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M menuselect '^[[C'  .forward-char  '^[OC'  .forward-char

# 4) Enter always submits the command line even when a menu is open
bindkey -M menuselect '^M' .accept-line

# ---------- Oh My Zsh ----------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  command-not-found
  colored-man-pages
  copyfile
  copypath
  zsh-autocomplete
)

# Completion cache location (Oh My Zsh will run compinit)
ZSH_COMPDUMP="$HOME/.cache/zcompdump-${ZSH_VERSION}"
mkdir -p "$HOME/.cache"
# Common completion UX
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# ---- Clipboard compatibility for OMZ copyfile/copypath ----
# Many tools/plugins expect pbcopy/pbpaste; map them to Termux clipboard.
if command -v termux-clipboard-set >/dev/null 2>&1; then
  alias pbcopy='termux-clipboard-set'
fi
if command -v termux-clipboard-get >/dev/null 2>&1; then
  alias pbpaste='termux-clipboard-get'
fi

# ---------- Pure prompt (load after OMZ) ----------
# Ensure you have cloned pure to ~/.zsh/pure
if [[ -d "$HOME/.zsh/pure" ]]; then
  fpath+=("$HOME/.zsh/pure")
  autoload -U promptinit && promptinit
  prompt pure

  # Pure tuning
  PURE_CMD_MAX_EXEC_TIME=5
  PURE_HIDE_VIRTUALENV=1
  zstyle ':prompt:pure:git:*' async yes
fi

# ---------- zsh-autosuggestions tuning ----------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ---------- fzf (Ctrl+R, Alt+C, etc.) ----------
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
  fi
fi

# ---------- Aliases ----------
# Shell management
alias mizsh='micro ~/.zshrc'
alias zsource='source ~/.zshrc'
alias cl='clear'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias sd='cd /sdcard'
alias dl='cd /sdcard/Download'
alias st='cd ~/storage/shared'
alias stdl='cd ~/storage/shared/Download'
alias stdcim='cd ~/storage/shared/DCIM'
alias stpics='cd ~/storage/shared/Pictures'

# Common tools
alias grep='grep --color=auto'
alias py3='python3'
alias path='print -rl -- ${(s.:.)PATH}'

# Listing (prefer eza if installed; fall back to ls)
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -lahF --git'
  alias la='eza -A'
else
  alias ll='ls -lahF'
  alias la='ls -A'
fi
alias l='ls -1'

# Termux package management
alias upd='pkg update && pkg upgrade'
alias updi='pkg update && pkg upgrade -y'
alias piy='pkg install -y'
alias rem='pkg uninstall'
alias search='pkg search'
alias pkgs='pkg list-installed'
alias pkgfiles='dpkg -L'
alias pkgowns='dpkg -S'

# Termux utilities
alias storage='termux-setup-storage'
alias share='termux-share'
alias tinfo='termux-info'
alias treload='termux-reload-settings'
alias toast='termux-toast'

# Termux: quick device/network info
alias batt='termux-battery-status'
alias wifi='termux-wifi-connectioninfo'
alias ip4='ip -4 addr show'
alias ipr='ip route'
alias ports='ss -tulpen'
alias ipinfo='termux-wifi-connectioninfo 2>/dev/null || termux-telephony-deviceinfo'

# Quick Android settings intents
alias settings='am start -a android.settings.SETTINGS'
alias wifiui='am start -a android.settings.WIFI_SETTINGS'
alias btui='am start -a android.settings.BLUETOOTH_SETTINGS'

# Media rescan (may be blocked on newer Android)
alias rescan='am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard'

# Torch/vibrate (requires Termux:API app + termux-api pkg)
alias torchon='termux-torch on'
alias torchoff='termux-torch off'
alias vib='termux-vibrate -d 100'

# Clipboard (requires Termux:API app + termux-api pkg)
alias cpy='termux-clipboard-set'
alias pst='termux-clipboard-get'

# ---------- Functions ----------

# Create a directory and cd into it
mkcd() {
  [[ -z "$1" ]] && { echo "Usage: mkcd <dir>"; return 1; }
  mkdir -p -- "$1" && cd -- "$1"
}

# Copy file contents to clipboard
# Usage: catcopy filename.txt
catcopy() {
  if [[ -f "$1" ]]; then
    termux-clipboard-set < "$1"
    echo "Copied contents of '$1' to clipboard."
  else
    echo "File '$1' not found."
    return 1
  fi
}

# Total size of *.<ext> files in current directory only
totalsize() {
  [[ -z "$1" ]] && { echo "Usage: totalsize <extension>"; return 1; }
  local ext="$1"
  local matches=(*."$ext"(N))
  (( ${#matches} )) || { echo "No *.$ext files in current directory."; return 1; }
  du -ch -- "${matches[@]}" 2>/dev/null | tail -1
}

# Total size of *.<ext> files recursively under current directory
totalsize-r() {
  [[ -z "$1" ]] && { echo "Usage: totalsize-r <extension>"; return 1; }
  local ext="$1"
  local matches=(**/*."$ext"(N))
  (( ${#matches} )) || { echo "No *.$ext files under current directory."; return 1; }
  du -ch -- "${matches[@]}" 2>/dev/null | tail -1
}

# List file sizes for *.<ext> recursively, plus per-directory totals
sizetree() {
  [[ -z "$1" ]] && { echo "Usage: sizetree <extension>"; return 1; }
  local ext="$1"

  echo "--- Individual File Sizes (*.$ext) ---"
  find . -type f -iname "*.$ext" -print0 | xargs -0 du -h 2>/dev/null | sort -hr

  echo ""
  echo "--- Total Directory Sizes (*.$ext) ---"
  find . -type f -iname "*.$ext" -exec dirname {} \; \
    | sort -u \
    | xargs -I {} du -sh {} 2>/dev/null \
    | sort -hr
}

# Download TikTok URLs listed in a file using yt-dlp
# Usage: dl-tiktok urls.txt
dl-tiktok() {
  [[ -z "$1" ]] && { echo "Usage: dl-tiktok <filename.txt>"; return 1; }
  command -v yt-dlp >/dev/null 2>&1 || { echo "yt-dlp not found. Install: pkg install yt-dlp"; return 1; }
  [[ -f "$1" ]] || { echo "File '$1' not found."; return 1; }

  local OUTPUT_DIR="$HOME/storage/shared/Movies/tiktok"
  mkdir -p "$OUTPUT_DIR"

  yt-dlp -a "$1" \
    -o "${OUTPUT_DIR}/%(uploader)s/%(uploader)s%(upload_date)s.%(ext)s" \
    --restrict-filenames \
    --ignore-errors
}

# ---------- Syntax highlighting (load last) ----------
ZSH_SYNTAX_HIGHLIGHTING="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$ZSH_SYNTAX_HIGHLIGHTING" ]] && source "$ZSH_SYNTAX_HIGHLIGHTING"

# --- dotfiles backup (dotbackup) ---
# Backup current Termux dotfiles into ~/dotfiles-termux and commit/push.
dotbackup() {
  local repo="$HOME/dotfiles-termux"
  [[ -d "$repo/.git" ]] || { echo "dotbackup: repo not found at $repo"; return 1; }

  (
    set -e
    cd "$repo"

    cp -f "$HOME/.zshrc" "$repo/zshrc"

    mkdir -p "$repo/oh-my-zsh/custom"
    cp -a "$HOME/.oh-my-zsh/custom/." "$repo/oh-my-zsh/custom/"

    mkdir -p "$repo/termux"
    cp -a "$HOME/.termux/." "$repo/termux/" 2>/dev/null || true

    mkdir -p "$repo/micro"
    cp -a "$HOME/.config/micro/." "$repo/micro/" 2>/dev/null || true

    git add -A
    if git diff --cached --quiet; then
      echo "dotbackup: no changes"
      exit 0
    fi

    git commit -m "Snapshot $(date -Iseconds)"
    git push
    echo "dotbackup: pushed"
  )
}
# --- end dotbackup ---
