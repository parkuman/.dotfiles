# Parker's dotfiles

clone the repo in `~` directory.

requirements:

1. stow
2. nvim
3. ghostty
4. tmux
5. [tmux plugin manager](https://github.com/tmux-plugins/tpm) (need to git clone this locally)

then use stow to symlink the files

```bash
cd ~/.dotfiles/
stow .
```

## Nix

I manage my packages and such using Nix.

### MacOS

#### 1. Install deps

```bash
xcode-select --install
```

#### 2. Install Nix

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

#### 3. Enable flakes and nix-command

These are not available by default (as of May 2026).

Add this to `/etc/nix/nix.conf`

```conf
experimental-features = nix-command flakes
```

#### 4. Build

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin/master#darwin-rebuild -- switch --flake ~/.dotfiles/nix#parker-m3
```
