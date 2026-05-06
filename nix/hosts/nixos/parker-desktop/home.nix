{ config, pkgs, user, ... }:

let
  dotfiles_config = "${config.home.homeDirectory}/.dotfiles/.config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
    ghostty = "ghostty";
    tmux = "tmux";
    opencode = "opencode";
  };
in

{
  home = {
    stateVersion = "25.11";

    username = user.username;
    homeDirectory = "/home/${user.username}";

    sessionVariables = {
      PROTON_PASS_KEY_PROVIDER = "fs";
    };

    packages = with pkgs; [
      # development
      fzf
      gcc
      lazygit
      neovim
      nixpkgs-fmt
      nodejs
      opencode
      ripgrep
      starship
      tmux

      # gaming
      discord
      mangohud
      heroic

      # other
      proton-pass-cli # not in 25.11

      # audio
      easyeffects
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = user.email;
        name = user.name;
      };
    };
  };
  programs.lazygit.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    shellAliases = {
      gst = "git status";
      v = "nvim";
    };
    initContent = ''
    source "${config.home.homeDirectory}/.zshrc.env"
    '';
  };
  programs.starship = {
    enable = true;
    # TODO:
    # settings = pkgs.lib.importTOML ../starship.toml;
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles_config}/${subpath}";
      recursive = true;
    })
    configs;

}
