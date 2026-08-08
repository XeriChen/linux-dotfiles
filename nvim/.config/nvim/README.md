# Neovim 配置（Ubuntu 24 适配版）

> 本目录是 stow 包 `nvim/`，安装后为 `~/.config/nvim/`。
> 配置源自 [archibate/dotfiles](https://github.com/archibate/dotfiles)（`dotfiles-nvim`），
> 已按 Ubuntu 24 适配并遵循本仓库的「快捷键原教旨」原则（不覆盖默认键位）。

## 依赖

**Neovim 版本要求 >= 0.11**（配置使用了 0.11 的 treesitter API 与 LSP API）。
Ubuntu 24.04 自带的 Neovim 是 0.9.5，**不满足要求**，需从 PPA 安装新版：

```bash
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update && sudo apt install neovim
```

一键部署（含以上步骤）可直接运行仓库根目录的 `./bootstrap.sh`。

### 系统依赖（Ubuntu 24 apt）

```bash
sudo apt install git lazygit yazi fd-find bat fzf ripgrep eza zoxide \
                 git-delta exiftool cargo
# bat/fd 的 Ubuntu 命令名为 batcat/fdfind，需要符号链接（bootstrap.sh 会自动处理）：
mkdir -p ~/.local/bin
ln -sf "$(command -v batcat)" ~/.local/bin/bat
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
```

> 其中 `cargo` 用于构建 `nvim-mcp` 插件（`mcp.lua`，可选，构建失败不影响其他插件）；
> `exiftool` 供图像/音频类插件读取元数据；`lazygit`/`yazi` 是 `git/.gitconfig` 与 fish 的 `y` 函数依赖。

### LSP 服务器

`lua/plugins/lsp.lua` 通过 Mason 自动安装：

```lua
"lua_ls", "bashls", "pyright", "rust_analyzer", "ts_ls",
"html", "cssls", "jsonls", "yamlls", "fish_lsp",
```

首次启动 nvim 时 Mason 会自动安装（`automatic_installation = true`）。
部分服务器需要额外系统库：

- `rust_analyzer`：需本机装有 Rust（`rustup` 或 `apt install rustc cargo`）
- `pyright`：需 Python 3（`apt install python3`）

## 安装配置

```bash
test -d ~/.config/nvim && mv ~/.config/nvim{,.backup}
git clone <你的仓库> ~/linux配置文件
cd ~/linux配置文件 && ./bootstrap.sh   # 或手动：stow -t "$HOME" nvim
```

## 启动

```bash
nvim +Lazy sync   # 首次：安装全部插件
nvim
```

插件由 lazy.nvim 管理（`lua/plugins/*.lua`），首次启动自动克隆安装，耗时取决于网络；
国内网络可先 `source ./proxy-switch.sh && proxy_on`。

## AI 补全（minuet，可选）

`lua/plugins/minuet.lua` 默认接入本地 **Ollama**（`qwen2.5-coder`，FIM 接口）：

```bash
# 安装 Ollama（非 NVIDIA 卡用 ollama-vulkan / ollama-cpu）
sudo apt install ollama        # 或按官网脚本安装
ollama pull qwen2.5-coder:14b  # 或更小的 7b/3b 模型
sudo systemctl enable ollama.service --now
```

- 模型与上下文在 `minuet.lua` 中配置；`context_window` 需与 Ollama 的 `num_ctx` 匹配：
  ```bash
  ollama run qwen2.5-coder:14b
  >>> /set parameter num_ctx 8192
  >>> /save qwen2.5-coder:14b
  ```
- 接入在线 API（如 DeepSeek）：改 `provider_options` 的 `api_key`（环境变量名）与 `end_point`。

> [!WARNING]
> 大上下文窗口会显著降低推理速度并占用更多显存。

## 故障排查

### `<leader>ff` 报 `'fzf' extension doesn't exist` / `libfzf.so: 没有那个文件或目录`

`telescope-fzf-native.nvim` 的 C 源码需要编译为 `build/libfzf.so`。
lazy.nvim 只在安装/更新时执行 `build = "make"`；若首次构建失败或 build 目录被清空，问题会持续存在。

修复：

```vim
:Lazy build telescope-fzf-native.nvim
```

或手动重建：

```bash
cd ~/.local/share/nvim/lazy/telescope-fzf-native.nvim && make
```

### 颜色异常

本配置遵循原教旨原则：不设第三方主题，使用 nvim 内置默认高亮（`colorscheme default`）。
若颜色仍异常，检查终端是否启用真彩色（`termguicolors` 已在 options.lua 开启）。

## 目录结构

```
nvim/
└── .config/nvim/
    ├── init.lua            # 入口：加载 config/* 与 lazy.nvim
    ├── lua/
    │   ├── config/         # options / keymaps / lazy-setup
    │   └── plugins/        # 各插件 spec（lazy.nvim import "plugins"）
    ├── lazy-lock.json      # 插件版本锁（由 lazy.nvim 维护）
    ├── .luarc.json         # lua-language-server 配置
    └── .stylua.toml        # stylua 格式配置
```
