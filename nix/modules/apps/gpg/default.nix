{ pkgs, user, ... }:
let
  isDarwin = pkgs.stdend.isDarwin;
in {
  programs.gpg = {
    enable = true;
    settings.default-key = user.gpgKey;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = if isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry-curses
  };
}
