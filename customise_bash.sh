alias ll='ls -laFh'
alias ws='cd /home/fanta/workspace'
alias c='clear'
alias tm='tmux'
alias d='cd /home/fanta/Downloads'

export PATH="/home/fanta/.local/bin:$PATH"

# pyenv

export PATH="$PATH:/home/fanta/.pyenv/bin"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export MY_VENV="default"
if [ "$PYENV_VERSION" != "$MY_VENV" ]; then
  pyenv activate $MY_VENV
fi
