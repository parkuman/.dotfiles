if [[ -f /usr/local/bin/acre_terminal_setup ]]; then
 source /usr/local/bin/acre_terminal_setup
fi
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# bun completions
[ -s "/Users/parker/.bun/_bun" ] && source "/Users/parker/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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

# acre related
alias awslog="aws-azure-login --profile acre --no-prompt mode=gui"
