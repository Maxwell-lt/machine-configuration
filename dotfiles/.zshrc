# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
setopt appendhistory autocd notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/maxwell/.zshrc'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

autoload -Uz compinit
compinit
# End of lines added by compinstall
eval "$(direnv hook zsh)"
export EDITOR="nvim"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

