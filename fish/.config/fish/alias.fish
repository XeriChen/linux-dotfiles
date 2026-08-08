# 别名与实用函数（骨架: archibate，剔除个人工作流 box/cmd/opencode/paru）
# exa 已停止维护 -> Ubuntu 24 用 eza（含兼容 fallback）

# ---- 基础 ----
set -q PAGER; or set -g PAGER less
set -q EDITOR; or set -g EDITOR nvim

# 列表命令: eza 优先，其次 exa，最后 ls
if command -sq eza
    abbr -a s 'eza'
    abbr -a l 'eza -lAtr'
else if command -sq exa
    abbr -a s 'exa'
    abbr -a l 'exa -lAtr'
else
    abbr -a s 'ls'
    abbr -a l 'ls -lAtr'
end

abbr -a g 'git'
abbr -a p 'python3'
abbr -a b "$EDITOR"
abbr -a v "$PAGER"
abbr -a j 'z'   # zoxide 的 z（需 zoxide init fish）

# ---- Git 快捷（abbr 展开式）----
abbr -a gs 'git status'
abbr -a ga 'git add --all'
abbr -a gad 'git add'
abbr -a gc 'git commit -m'
abbr -a gco 'git checkout'
abbr -a gcm 'git commit'
abbr -a gca 'git commit --amend'
abbr -a gq 'git pull'
abbr -a gk 'git reset'
abbr -a gkh 'git reset --hard'
abbr -a gka 'git reset HEAD^'
abbr -a gkha 'git reset --hard HEAD^'
abbr -a gp 'git push'
abbr -a gg 'git switch'
abbr -a ggo 'git switch -c'
abbr -a grs 'git restore --staged'
abbr -a grc 'git rm --cached'
abbr -a gr 'git restore'
abbr -a gd 'git diff'
abbr -a gdc 'git diff --cached'
abbr -a gda 'git diff HEAD^'
abbr -a gm 'git merge'
abbr -a gma 'git merge --abort'
abbr -a gl 'git log'
abbr -a gll 'git log --graph --oneline --decorate'
abbr -a gt 'git stash'
abbr -a gtp 'git stash pop'
abbr -a gcl 'git clone'
abbr -a gcl1 'git clone --depth=1'
abbr -a gsm 'git submodule'
abbr -a gsmu 'git submodule update --init --recursive'
abbr -a gb 'git branch'
abbr -a g0 'cd (git rev-parse --show-toplevel)'
abbr -a ggkhm 'git switch main && git reset --hard origin/main'

# ---- 配置编辑 ----
abbr -a fishconf "$EDITOR $__fish_config_dir/config.fish && source $__fish_config_dir/config.fish"
abbr -a fishenv "$EDITOR $__fish_config_dir/.env && load_dotenv $__fish_config_dir/.env"

# ---- tmux 快捷 ----
function tmux_pager_view
    tmux capture-pane -pS - | $PAGER
end
abbr -a ta 'tmux attach'
abbr -a tl 'tmux ls'
abbr -a tv 'tmux_pager_view'

# ---- yazi：退出后自动 cd 到所选目录 ----
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# ---- 其他实用函数 ----
function mcd -a path
    mkdir -p $path
    cd $path
end

# gethub: clone GitHub 仓库到 ~/Codes/github.com/user/repo（已存在则 cd 进入）
function gethub -a repo
    if test -z "$repo"
        echo "Usage: gethub user/repo"
        return 1
    end
    if not string match -qr '^[^/]+/[^/]+$' $repo
        echo "Error: Invalid format. Expected: user/repo"
        return 1
    end
    set gh_base_dir ~/Codes/github.com
    set clone_dir $gh_base_dir/$repo
    if test -d $clone_dir
        cd $clone_dir
        return
    end
    mkdir -p (dirname $clone_dir)
    git clone git@github.com:$repo.git $clone_dir; and cd $clone_dir
end

# SSH key 切换（多账号场景；推荐 ~/.ssh/config 用 Host 别名自动匹配）
function set-ssh-key
    set -l key "$HOME/.ssh/$argv[1]"
    if not test -f "$key"
        echo "Key not found: $key" >&2
        echo "Available keys:" >&2
        for f in ~/.ssh/*.pub
            echo "  "(basename $f .pub) >&2
        end
        return 1
    end
    ssh-add -D 2>/dev/null
    ssh-add "$key"
    echo "Active SSH key: $argv[1]"
end

# docker 包装: 不在 docker 组时自动 sudo -g docker（未装 docker 则不影响）
if id -nG | grep -vq '\bdocker\b'
    if command -sq docker
        function docker
            command sudo -g docker -- docker $argv
        end
    end
    if command -sq docker-compose
        function docker-compose
            command sudo -g docker -- docker-compose $argv
        end
    end
end

# nano -> $EDITOR 包装
if set -q EDITOR
    function nano
        command $EDITOR $argv
    end
end
