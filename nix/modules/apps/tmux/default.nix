{ config, pkgs, ... }:

let
  copyCmd = if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy";
in

{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      gruvbox
    ];

    extraConfig = /* tmux */ ''
      # 24 bit colours
      set -g default-terminal "tmux-256color"
      set -as terminal-features ",xterm-256color:RGB"

      # re-bind prefix to CTRL+SPACE
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # prefix + g opens lazygit in popup
      bind g display-popup \
        -d '#{pane_current_path}' \
        -w 90% \
        -h 90% \
        -E "lazygit"

      # vi mode for copying
      setw -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${copyCmd}"
      bind P paste-buffer
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${copyCmd}"

      # rename current session to current dir
      bind r run-shell 'tmux rename-session $(basename "#{pane_current_path}")'

      set -g mouse on
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # new panes open in same working directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}
