{ pkgs, user, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in

{
  programs.gpg = {
    enable = true;
    settings = {
      default-key = user.gpgKey;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
  };
}
