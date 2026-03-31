# starship
eval "$(starship init zsh)"

source <(fzf --zsh)

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# env variables
source ~/.zshrc.env

# aliases
alias gst="git status"
alias v="nvim"
alias vi="nvim"
alias lg="lazygit"
alias sbrc="source ~/.zshrc"
alias k=kubectl

# import any work-specific zshrc files
if [[ -f ~/.config/work/.zshrc ]]; then
    source ~/.config/work/.zshrc
fi

export AISH_PROVIDER=anthropic
for f in ~/scripts/*.sh; do source "$f"; done

# GPG
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/parker/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/parker/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/parker/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/parker/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
