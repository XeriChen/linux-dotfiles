# 环境变量（Ubuntu 24）
set -gx TERMINAL ghostty   # 终端（上游为 kitty，已改为 ghostty）
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx SHELL (which fish)
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# pnpm（Node 包管理器；Ubuntu 默认 HOME 为 ~/.local/share/pnpm）
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

# 加载 ~/.config/fish/.env（可选，setup.fish 会自动创建空文件）
function load_dotenv
    set -l file
    if test -z "$argv[1]"
        set file "./.env"
    else
        set file $argv[1]
    end
    if not test -f $file
        echo "Error: $file not found." >&2
        return 1
    end
    while read -l line
        set -l trimmed (string trim "$line")
        if string match -q "#*" "$trimmed"
            continue
        end
        set -l parts (string split -m1 "=" "$trimmed")
        if test (count $parts) -lt 2
            continue
        end
        set -l var_name $parts[1]
        set -l var_value $parts[2]
        if test -n "$var_name" -a -n "$var_value"
            set -gx $var_name $var_value
        end
    end < $file
end

if test -f $__fish_config_dir/.env
    load_dotenv $__fish_config_dir/.env
end
