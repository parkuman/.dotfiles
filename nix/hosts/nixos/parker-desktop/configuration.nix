{ config, lib, pkgs, user, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "parker-desktop-nixos";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;




  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };


  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
	

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.firefox.enable = true;

  # to get tree-sitter working inside nvim, we do the non-nix way
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    tree-sitter
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.dc=1"
    "amdgpu.dpm=1"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "proton-pass-cli"
    "steam"
    "steam-unwrapped"
  ];
  environment.systemPackages = with pkgs; [
    vim
    wget
    ghostty
    git
    zsh
  ];

# fonts.packages = with pkgs; [
#       nerd-fronts.jetbrains-mono
# ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # DO NOT CHANGE. Installed April 2nd 2026
  system.stateVersion = "25.11";

}

