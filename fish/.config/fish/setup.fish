#!/usr/bin/env fish
# 在 Linux 上安装 fish 插件与路径（可选执行）
# 用法: fish setup.fish

set -l fisher_plugins (cat $__fish_config_dir/fish_plugins)

# 安装 fisher（插件管理器）
if not command -sq fisher; and not functions -q fisher
    curl -sfSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
end

for plugin in $fisher_plugins
    fisher install $plugin
end

# 插件全局选项由 options.fish 维护（每次启动加载），setup 只做一次性安装，不写持久变量

# 常见本地 bin 目录加入 PATH
for x in local atuin cargo npm-global
    if test -d ~/.$x/bin
        fish_add_path -U ~/.$x/bin
    end
end
fish_add_path -U $__fish_config_dir/bin

# 提示符由 starship 接管，不再设置 fish 主题
# fish_config theme choose 'TokyoNight Moon'

# 创建 .env 占位（可选环境变量文件）
test -f $__fish_config_dir/.env; or touch $__fish_config_dir/.env

echo "编辑环境变量: nvim $__fish_config_dir/.env"
echo "设为默认 shell: sudo chsh $USER -s (which fish)"
