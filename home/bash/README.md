# Organized Bash Dotfiles

- Merged your uploaded files:
  - `~/.bashrc` (length: 345 chars)
  - `~/.bash_profile` (length: 133 chars)
  - `~/.bash_aliases` (length: 3429 chars)

- Consolidated aliases into `~/.bashrc.d/10-aliases.sh`
- Moved remaining `.bashrc` content into `~/.bashrc.d/20-user-rc.sh`
- Added a portable `~/.bashrc` that sources `~/.bashrc.d/*.sh` and an `~/.bash_profile` that sources `.bashrc`
