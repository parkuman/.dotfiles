#!/bin/bash


# install nix

echo "==================| INSTALLING NIX |=================="
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. /home/$USER/.nix-profile/etc/profile.d/nix.sh


echo "==================| INSTALLING PACKAGES |=================="
nix-env -iA \
	nixpkgs.git \
	nixpkgs.zsh \
	nixpkgs.antibody \
	nixpkgs.neovim \
	nixpkgs.tmux \
	nixpkgs.stow \
	nixpkgs.yarn \
	nixpkgs.fzf 


stow git
stow nvim
stow zsh

echo "==================| SETTING ZSH AS SHELL |=================="
command -v zsh | sudo tee -a /etc/shells # add as valid login shell
sudo chsh -s $(which zsh) $USER # if you have issues with this, change /etc/pam.d/chsh 'required' to 'sufficient'

antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

echo "==================| SETTING NEOVIM PLUGINS |=================="
# install neovim plugins
#nvim --headless +PlugInstall +qall

