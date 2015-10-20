#EDITOR
set EDITOR emacsclient
#PATH
set -x PATH $PATH $HOME/.rbenv/bin $HOME/bin $HOME/code/tiny_scripts/scripts $GOPATH/bin $HOME/.composer/vendor/bin

#GO
set -x GOPATH $HOME/go

#Node
set NPM_PACKAGES "$HOME/.npm-packages"
set -x PATH  $PATH $NPM_PACKAGES/bin
set NODE_PATH "$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

#Ruby
set -gx RBENV_ROOT $HOME/.rbenv
. (rbenv init -|psub)

#emacs
alias e='emacsclient -n'
alias j='emacsclient ~/.j/journal.log'

#pacman
alias pacin='sudo pacman -S'

#rails
alias dl='tailf log/development.log'
alias tl='tailf log/test.log'

# git aliases
alias gst='git status'
alias gco='git checkout'
alias gd='git diff'
alias push='git push'
alias pull='git pull'
alias gcm='git checkout master'
alias ggpur='git pull --rebase'
alias clean_merged='git branch --merged | grep -v "\*" | grep -v master | grep -v dev | xargs -n 1 git branch -d'
alias grc='git rebase --continue'
alias gdw='git diff -w'
alias grc='git rebase --continue'
alias gpf='git push --force-with-lease'
alias create_test_db='env RAILS_ENV=test rake db:create'
alias whats_wrong='bundle exec rspec spec --fail-fast'
alias run_all_specs='bundle exec rspec spec'
function run_spec
  bundle exec rspec $argv
end
#Git helpers
function current_branch
  git rev-parse --abbrev-ref HEAD
end

function set_upstream
  git branch --set-upstream-to=origin/(current_branch) (current_branch)
end

#Github helpers
# Gho
# Open github pages for current directory's repo
# gho pulls opens pull requests page
# gho issues to open issues page
function gho
  open https://(git config --get remote.origin.url|sed -e s/.git//g|sed s,:,/,g)/$argv
end

function pr
  git push
  hub pull-request -i $argv[1]
  gho
end

# Fish git prompt
set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '☡'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'


function fish_prompt
  set last_status $status

  set_color $fish_color_cwd
  printf '%s' (prompt_pwd)
  set_color normal

  printf '%s ' (__fish_git_prompt)

  set_color normal
end

function start_agent
  echo "Initializing new SSH agent ..."
  ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
  echo "succeeded"
  chmod 600 $SSH_ENV
  . $SSH_ENV > /dev/null
  ssh-add
end

function test_identities
  ssh-add -l | grep "The agent has no identities" > /dev/null
  if [ $status -eq 0 ]
    ssh-add
    if [ $status -eq 2 ]
      start_agent
    end
  end
end

#SSH
setenv SSH_ENV $HOME/.ssh/environment

if [ -n "$SSH_AGENT_PID" ]
  ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
  if [ $status -eq 0 ]
    test_identities
  end
else
  if [ -f $SSH_ENV ]
    . $SSH_ENV > /dev/null
  end
  ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
  if [ $status -eq 0 ]
    test_identities
  else
    start_agent
  end
end


# Load fishmarks (http://github.com/techwizrd/fishmarks)
. $HOME/.fishmarks/marks.fish


#Sudo helper
function .runsudo --description 'Run current command line as root'
  set cursor_pos (echo (commandline -C) + 5 | bc)
  commandline -C 0
  commandline -i 'sudo '
  commandline -C "$cursor_pos"
end

function fish_user_key_bindings
  bind \es '.runsudo'
end

funcsave fish_user_key_bindings
