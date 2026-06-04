{
  config,
  pkgs,
  user,
  ...
}:

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
  imports = [
    ../../../modules/apps/gpg
    ../../../modules/apps/gpu-screen-recorder
    ../../../modules/apps/tmux
  ];
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
      obsidian
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
        signingKey = user.gpgKey;
      };
      commit.gpgSign = true;
      tag.gpgSign = true;
    };
  };
  programs.lazygit.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = /* bash */ ''
      # this is a weird hack so I can still use my zshrc on other machines but also on nix
      source "${config.home.homeDirectory}/.dotfiles/.zshrc"
    '';
  };
  programs.starship = {
    enable = true;
    settings = pkgs.lib.importTOML ../../../../.config/starship.toml;
  };
  programs.zoxide.enable = true;

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles_config}/${subpath}";
    recursive = true;
  }) configs;

}
