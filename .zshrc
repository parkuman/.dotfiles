# starship
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

# aider
alias aider="aider --config ~/.config/.aider.conf.yml"

# import any work-specific zshrc files
if [[ -f ~/.config/work/.zshrc ]]; then
    source ~/.config/work/.zshrc
fi
