{ config, pkgs, user, ... }:

let
  dotfiles_config = "${config.home.homeDirectory}/.dotfiles/.config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
    ghostty = "ghostty";
    opencode = "opencode";
  };
in

{
  imports = [ ../../../modules/shared/tmux.nix ];
  home = {
    stateVersion = "25.11";

    username = user.username;
    homeDirectory = "/home/${user.username}";

    sessionVariables = {
      # proton pass cli won't start without this as it tries to use the native keyright
      PROTON_PASS_KEY_PROVIDER = "fs";
    };

    packages = with pkgs; [
      # gaming
      discord
      mangohud
      heroic

      # other
      proton-pass-cli # not in 25.11
      wl-clipboard # for programmatically copying to clipboard

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
    initContent = ''
    source "${config.home.homeDirectory}/.dotfiles/.zshrc"
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
