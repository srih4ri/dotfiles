if status is-interactive
    # Commands to run in interactive sessions can go here
end

# >>> coursier install directory >>>
if test -d "$HOME/.local/share/coursier/bin"
    fish_add_path -a "$HOME/.local/share/coursier/bin"
end
# <<< coursier install directory <<<

# opencode
if test -d "$HOME/.opencode/bin"
    fish_add_path "$HOME/.opencode/bin"
end
