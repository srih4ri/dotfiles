function cdc --description "Change directory to git repository root"
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$git_root"
        cd "$git_root"
    else
        echo "Not in a git repository" >&2
        return 1
    end
end
