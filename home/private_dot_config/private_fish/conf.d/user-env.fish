# Load user-level secrets from ~/.env into every fish shell.
if test -r $HOME/.env
    for line in (cat $HOME/.env)
        # skip blanks and comments
        if string match -qr '^\s*(#|$)' -- $line
            continue
        end
        set -l kv (string split -m 1 '=' -- $line)
        if test (count $kv) -ne 2
            continue
        end
        set -l key (string trim -- $kv[1])
        set -l val (string trim -- $kv[2])
        set key (string replace -r '^export\s+' '' -- $key)
        # strip surrounding quotes
        set val (string replace -r '^"(.*)"$' '$1' -- $val)
        set val (string replace -r "^'(.*)'\$" '\$1' -- $val)
        if string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $key
            set -gx $key $val
        end
    end
end
