{pkgs}:
with pkgs; [
  # Shell
  bashInteractive
  bash-completion
  starship

  # Modern CLI
  eza
  bat
  ripgrep
  fd
  dust
  tldr

  # Monitoring
  htop
  btop
  glances
  ncdu
  nload
  bmon
  tcpdump

  # Productivity
  tmux
  pay-respects

  # Containers / Automation
  docker
  docker-compose
  podman
  ansible

  # Dev tooling
  git
  python3
  nodejs
  fnm
  rustup
  markdownlint-cli
]
