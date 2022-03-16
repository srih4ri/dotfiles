# Source secret env vars and such
source "$HOME/.config/fish/config_secrets.fish"

#EDITOR
set -gx EDITOR emacsclient

#PATH
set PATH $HOME/.rbenv/bin $PATH
set PATH $HOME/.local/bin $PATH
set PATH ./node_modules/.bin $PATH
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

#ENV
set -x WKHTMLTOPDF (which wkhtmltopdf)

#ALIASES
alias e='emacsclient -n '
alias j='emacsclient ~/.j/journal.log'

#rails
alias dl='tailf log/dev*.log'
alias tl='tailf log/test.log'

# git aliases
alias gst='git status'
alias gco='git checkout'
alias gd='git diff'
alias push='git push'
alias pull='git pull'
alias gcm='git checkout master; or git checkout main'
alias ggpur='git pull --rebase'
alias clean_merged='git branch --merged | grep -v "\*" | grep -v master | grep -v dev | xargs -n 1 git branch -d'
alias grc='git rebase --continue'
alias gdw='git diff -w'
alias grc='git rebase --continue'
alias gpf='git push --force-with-lease'
alias create_test_db='env RAILS_ENV=test rake db:create'
alias whats_wrong='bundle exec rspec spec --fail-fast'
alias run_all_specs='bundle exec rspec spec'

#FUNCTIONS
function s
    if test -e bin/spring && false
        bin/spring rspec $argv
    else
        bundle exec rspec $argv
    end
end

#FUNCTION Git helpers
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
    xdg-open https://(git config --get remote.origin.url|sed -e s/.git//g|sed s,:,/,g)/$argv
end

function first_push
    git push -u origin (current_branch)
end

function tailf
    tail -f $argv
end

function run_changed_specs
    for spec in (git diff master --name-only spec)
        s $spec
    end
end


function start_agent
    echo "Initializing new SSH agent ..."
    ssh-agent -c | sed 's/^echo/#echo/' >$SSH_ENV
    echo succeeded
    chmod 600 $SSH_ENV
    . $SSH_ENV >/dev/null
    ssh-add
end

function test_identities
    ssh-add -l | grep "The agent has no identities" >/dev/null
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
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent >/dev/null
    if [ $status -eq 0 ]
        test_identities
    end
else
    if [ -f $SSH_ENV ]
        . $SSH_ENV >/dev/null
    end
    ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent >/dev/null
    if [ $status -eq 0 ]
        test_identities
    else
        start_agent
    end
end


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

function thin_start
    bundle exec thin start
end

function sidekiq_start
    bundle exec sidekiq
end

function restart_unicorn
    kill -HUP (cat /tmp/unicorn.milky_way_development.pid)
end

function zr
    zeus rake $argv
end

function zc
    zeus c
end

function mg
    mix deps.get
end

function tbp
    tmux break-pane
end

function this_branch_param
    git branch ^/dev/null | grep \* | sed 's/* //' | sed 's/\//-/' | sed s/_/-/g
end

function update_app
    git checkout master; and git pull --rebase; and bundle; and bundle exec rake db:migrate; and yarn
end

status --is-interactive; and rbenv init - | source

export NODE_OPTIONS=--max-old-space-size=4096


## SupermanCO K8s helpers
##

function get_pod_with_name --description "Get pod with a particular name" --argument pod_name
    echo "Looking for pod $pod_name"
    kubectl get pods -o json -l app.kubernetes.io/name=$pod_name | jq -r '.items[0].metadata.name'
end

function execute_command_on_pod --argument pod_name cmd --description "Execute a command on given pod name"
    echo "Executing $cmd on $pod_name"
    kubectl exec -it $pod_name -- $cmd
end

function k_rails_c
    echo "Getting pod for application backend"
    set pod (get_pod_with_name 'application_backend')
    echo "Executing /bin/sh on $pod"
    execute_command_on_pod $pod /bin/sh
end

function k_rails_c_dj
    echo "Getting pod for delayed-job"
    set pod (get_pod_with_name 'delayed-job')
    echo "Executing /bin/sh on $pod"
    execute_command_on_pod $pod /bin/sh
end

function k_login_to_cluster --argument cluster
    aws --profile saml eks --region eu-central-1 update-kubeconfig --name $cluster
end

function k_login_staging
    k_login_to_cluster staging
end

function k_login
    k_login_to_cluster development
end

function rcs
    s (git diff master --name-only spec/**.rb)
end

function lsj
    for file in (git diff master --name-only '*.ts' '*.js')
        eslint $file
    end
end

function lsjf
    for file in (git diff master --name-only '*.ts' '*.js')
        eslint --fix $file
    end
end

function lsr
    for file in (git diff master --name-only '*.rb')
        echo "Checking $file"
        rubocop $file
    end
end

function lsrf
    for file in (git diff master --name-only '*.rb')
        echo "Checking $file"
        rubocop -A $file
    end
end

function a
    ag --ignore='dist' $argv
end

function b --description "Jump to git root dir"
    cd (git rev-parse --show-toplevel)
end

function l
    ls -ltr
end

function t
    tree -L 3
end

function g
    git status .
end

function alexa
    espeak "echo, $argv"
end
