# =========================
# Modern replacements
# =========================
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --icons --git"
alias la="eza -lha --icons --git"

alias cat="bat --style=plain --paging=never"
alias grep="rg --color=auto"
alias find="fd"
alias du="dust"
alias tree="eza --tree --level=2"

# Use htop instead of top (with sudo, env preserved)
alias top="please htop"

# =========================
# Git shortcuts
# =========================
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate --all"
alias gco="git checkout"

# =========================
# System Monitoring
# =========================
alias h="htop"                     # htop shortcut
alias b="btop"                     # btop shortcut
alias g="glances"                  # glances overview
alias psu="ps aux"                 # process tree
alias memtop="ps aux --sort=-%mem | head -n 15"
alias cputop="ps aux --sort=-%cpu | head -n 15"

# =========================
# Disk / Filesystem
# =========================
alias dux="ncdu"                   # ncdu explorer
alias dus="du -sh * | sort -h"     # size summary
alias dfh="df -h"                  # disk usage

# =========================
# Networking
# =========================
alias net="ifconfig"
alias ports="sudo lsof -i -P -n | grep LISTEN"
alias conns="sudo lsof -i -P -n"
alias snif="sudo tcpdump -i any"
alias nmon="nload"
alias bmonn="bmon"
alias iftopn="sudo iftop -i en0"   # replace en0 with your interface

# =========================
# Multiplexing
# =========================
alias tm="tmux"
alias tml="tmux ls"
alias tma="tmux attach -t"
alias tmk="tmux kill-session -t"

# =========================
# Containers / VMs
# =========================
alias d="docker"
alias dps="docker ps"
alias dpa="docker ps -a"
alias drm="docker rm -f"
alias drmi="docker rmi"
alias dsh="docker exec -it"

alias mp="multipass"
alias mpls="multipass list"
alias mpsh="multipass shell"

# =========================
# Automation / Config mgmt
# =========================
alias ans="ansible"
alias ansp="ansible-playbook"

# =========================
# Logs
# =========================
alias logs="tail -f /var/log/system.log"
alias dmesg="dmesg | less"

# =========================
# Quality of life
# =========================
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Sudo with manners (trailing space allows chaining aliases)
alias please="sudo -E "

alias update="brew update && brew upgrade && brew cleanup"
alias py="python3"

# =========================
# Functions
# =========================

# Show top N processes by memory
topmem() {
  ps aux --sort=-%mem | head -n "${1:-10}"
}

# Show top N processes by CPU
topcpu() {
  ps aux --sort=-%cpu | head -n "${1:-10}"
}

# Watch disk usage in real time
watchdu() {
  watch -n "${1:-2}" 'df -h'
}

# Quick SSH (usage: sshh user host)
sshh() {
  if [ $# -lt 2 ]; then
    echo "Usage: sshh user host"
    return 1
  fi
  ssh "$1@$2"
}

# Check which processes are listening on a given port
portcheck() {
  if [ -z "$1" ]; then
    echo "Usage: portcheck <port>"
    return 1
  fi
  sudo lsof -i :"$1"
}

# Tail logs with a search term (usage: loggrep term)
loggrep() {
  if [ -z "$1" ]; then
    echo "Usage: loggrep <search-term>"
    return 1
  fi
  sudo grep -i "$1" /var/log/system.log | tail -n 50
}

# Qemu start (example usage: qemu-start myvm.img 4G 2)
alias rocky-aarch64='qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -m 2048 \
  -smp 2 \
  -bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
  -drive file=$HOME/Images/rocky10-aarch64.img,format=qcow2 \
  -nographic \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=udp::67-:67,hostfwd=udp::69-:69 \
  -device virtio-net-device,netdev=net0,mac=52:54:00:12:34:56'
