eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# env variables - fetched async to avoid startup delay
_load_secrets() {
  local api_key
  api_key="$(pass-cli item view pass://-qWe2nBAInEUGU1geCss9a-z2-RMHxuCcDk9fKSjQ5I2Ta-kL8_y5Ym7dOPSd3TBsW8aPnQ7vjkeAoA55Nqc3A==/4gwUn7Hm7-k8avYy3RcSLm-JpnBa_DZUD4z5TicRmgrQdvpSfzNDK6eprL_5hS43Q0PuMa9v7J07_fi85gsCSw==/api_key 2>/dev/null)"
  if [[ -n "$api_key" ]]; then
    export ANTHROPIC_API_KEY="$api_key"
    export OPENCODE_ANTHROPIC_API_KEY="$api_key"
  fi
}
_load_secrets &!

# aliases
alias gst="git status"
alias v="nvim"
alias vi="nvim"
alias lg="lazygit"
alias sbrc="source ~/.zshrc"
alias k=kubectl
alias oc=opencode

# import any work-specific zshrc files
if [[ -f ~/.config/work/.zshrc ]]; then
    source ~/.config/work/.zshrc
fi

export AISH_PROVIDER=anthropic
for f in ~/.dotfiles/scripts/*.sh; do source "$f"; done

# GPG
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
