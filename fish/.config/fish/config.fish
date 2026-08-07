# Fish 主配置 —— 融合整合版（Ubuntu 24）
# 骨架: archibate/dotfiles (.config/fish) —— vi 模式 / 工具集成 / 插件体系
# starship/fnm/pnpm: lewislulu/terminal-setup 适配 Ubuntu 24
# 注意: 本仓库只在 Linux(Ubuntu 24) 上使用，不在 Windows 运行/测试

# 环境变量 + 私有配置（可选，由 setup.fish 创建 .env）
source $__fish_config_dir/env.fish
if test -f $__fish_config_dir/private.fish
    source $__fish_config_dir/private.fish
end

if status is-interactive

    # ---- 提示符: starship（接管 fish 提示符，不再用 fish 主题）----
    if command -q starship
        starship init fish --print-full-init | source
    end

    # ---- Node 版本管理（可选，未装则跳过）----
    if command -q fnm
        fnm env --use-on-cd --shell fish | source
    end

    # ---- 工具集成（均可选，command -sq 守卫，未装不影响）----
    if command -sq direnv
        direnv hook fish | source
    end
    if command -sq atuin
        atuin init fish --disable-up-arrow | source
    end
    if command -sq zoxide
        zoxide init fish | source
    end
    if command -q fzf
        fzf --fish | source
    end

    # ---- 编辑模式: vi 模式 + 自定义按键 ----
    fish_vi_key_bindings

    # Ctrl+P / Ctrl+N: 上下搜索历史
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    # Ctrl+A / Ctrl+E: 行首 / 行尾
    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    # Ctrl+F / Ctrl+B: 按词移动光标
    bind -M insert \cf forward-bigword forward-single-char
    bind -M insert \cb backward-bigword
    # Ctrl+T: fzf 目录搜索（依赖 fzf.fish 插件）
    bind \ct _fzf_search_directory
    bind -M insert \ct _fzf_search_directory
    # Ctrl+Z: undo（fish 4+ 支持）
    if test (string split '.' $FISH_VERSION)[1] -ge 4
        bind -M insert ctrl-/ undo
    end

    # ---- 加载选项与别名 ----
    source $__fish_config_dir/options.fish
    source $__fish_config_dir/alias.fish

end
