# Linux 配置文件仓库（dotfiles）

目标环境：**Ubuntu 24 + fish + starship + ghostty**
管理方式：**GNU Stow**（纯 git 仓库 + 符号链接，结构透明、零黑盒）

> 本仓库在 Windows 上整理，但只在 Linux 上使用，不在此处运行/测试。

> 双远程同步（内容一致）：
> - GitHub：https://github.com/XeriChen/linux-dotfiles
> - Gitee 镜像（国内加速）：https://gitee.com/xeri_chen/linux-dotfiles

---

## 目录结构

```
linux配置文件/
├── README.md
├── bootstrap.sh          # Ubuntu 24 一键部署：系统包 + Neovim 0.11 + fish 插件 + stow
├── install.sh            # 在 Linux 上把各包软链到 $HOME
├── proxy-switch.sh       # 代理开关（非侵入，source 后可用）
├── upstream/             # 克隆的开源配置临时工作区（不纳入 git）
│   └── .gitkeep
├── fish/                 # stow 包：fish
│   └── .config/fish/config.fish
├── starship/             # stow 包：starship
│   └── .config/starship.toml
├── ghostty/              # stow 包：ghostty
│   └── .config/ghostty/config
├── fonts/                # stow 包：UbuntuSansMono NFM（Nerd Font，→ ~/.local/share/fonts）
│   ├── .local/share/fonts/   # 8 个 .ttf（含图标，不含中文）
│   └── LICENCE.txt            # 上游许可证
├── git/                  # stow 包：git
│   └── .gitconfig
├── nvim/                 # stow 包：Neovim（lazy.nvim 管理）
│   └── .config/nvim/
├── codex/                # stow 包：Codex CLI（→ ~/.codex/config.toml + rules）
├── opencode/             # stow 包：OpenCode（→ ~/.config/opencode/opencode.jsonc）
└── claude/               # stow 包：Claude Code（→ ~/.claude/：settings.json + hooks + providers + skills）
```

每个顶层目录是一个 **stow 包**，目录内的相对路径就是它最终在 `$HOME` 下的位置。
例如 `starship/.config/starship.toml` 安装后会变成 `~/.config/starship.toml` 的软链。

---

## 工作流：克隆开源配置 → 改写 → 收进本仓库

1. **拉取上游配置到临时区**（直连即可；抽风时用代理，见下）
   ```bash
   cd upstream
   git clone https://github.com/某作者/dotfiles  repo-a
   git clone https://github.com/某作者/configs     repo-b
   ```
2. **挑选改写**：从 `upstream/repo-*/` 里挑你喜欢的片段，整理进对应的 stow 包
   （`fish/` `starship/` `ghostty/` `git/` `nvim/`）。文件树保持「相对于 `$HOME`」的布局。
3. **提交**
   ```bash
   git add fish starship ghostty git nvim
   git commit -m "feat: 整合 starship/ghostty 配置"
   ```

---

## 在 Linux 上安装

**推荐：一键 bootstrap**（自动装齐所有系统依赖，见 `bootstrap.sh`）：

```bash
git clone <你的远程仓库> ~/linux配置文件
cd ~/linux配置文件
./bootstrap.sh            # 交互确认；--yes 跳过确认；--dry-run 预览
```

**手动安装**（只做 stow 软链，依赖需自己装）：

```bash
sudo apt install stow
git clone <你的远程仓库> ~/linux配置文件
cd ~/linux配置文件
./install.sh
# 撤销某个包： stow -D -t "$HOME" fish
```

> ⚠️ **Neovim 版本**：本仓库 nvim 配置要求 **Neovim >= 0.11**，而 Ubuntu 24.04 自带 0.9.5（API 不兼容）。
> `bootstrap.sh` 会自动添加 `ppa:neovim-ppa/unstable` 安装新版；手动安装请自行处理。
> nvim 包的依赖、LSP、AI 补全（minuet/Ollama）说明见 `nvim/.config/nvim/README.md`。

---

## GitHub 访问（国内）

国内用户可直接克隆 Gitee 镜像（无需代理、速度更快）：

```bash
git clone https://gitee.com/xeri_chen/linux-dotfiles.git ~/linux配置文件
```

实测当前直连 `github.com` 可用。若抽风，二选一：

**A. 本地 mihomo 代理**（需先启动 mihomo，默认端口 7897，可用 `PROXY_PORT=xxxx proxy_on` 覆盖）
```bash
source ./proxy-switch.sh
proxy_on                 # 设置 http_proxy/https_proxy，仅当前 shell 生效
git clone https://github.com/...
proxy_off                # 恢复直连
```

**B. 镜像站 clone**（无需本地代理）
```bash
source ./proxy-switch.sh
gh_clone owner/repo                  # 默认 ghproxy.com
MIRROR=kgithub.com gh_clone owner/repo   # 或换 kgithub.com
```

---

## 字体与中文显示

**关键事实**：Nerd Font（如本仓库的 UbuntuSansMono NFM）**不含中文字形**——它只在原有字体上补了图标（Unicode 私用区），不补 CJK。所以主字体只负责 ASCII 与图标，中文需回退到一款中文等宽字体，否则中文会落到系统默认字体导致半/全宽错位。

**方案（主字体 + 中文回退链）**：
- 主字体：**`UbuntuSansMono NFM`**（Ubuntu Sans Mono 的 Nerd Font patch 版，含图标），由仓库 `fonts/` 包随 git 提供，stow 后落在 `~/.local/share/fonts/`。
- 中文回退：**`Noto Sans Mono CJK SC`**，系统自带，靠 `sudo apt install fonts-noto-cjk` 安装，**不进仓库**。

ghostty 的 `config` 配置回退链（第一行主字体，第二行遇中文回退）：
```
font-family = UbuntuSansMono NFM
font-family = Noto Sans Mono CJK SC
```
> ⚠️ 字体注册名是 **`UbuntuSansMono NFM`**（无空格），不是「Ubuntu Sans Mono NF」；写错 ghostty 会找不到字体。可用 `fc-list | grep -i ubuntusansmono` 核对。

中文回退字体需先安装（`bootstrap.sh` 会自动安装）：
```bash
sudo apt install fonts-noto-cjk      # 提供 Noto Sans Mono CJK SC
```
安装后 `./install.sh` 末尾的 `fc-cache -f` 会刷新缓存；或手动 `fc-cache -f`。

> Starship 官方要求终端启用 Nerd Font，点名推荐 JetBrains Mono / Fira Code / Hack Nerd Font（见 github.com/starship/starship#fonts）。本仓库选 UbuntuSansMono NFM（同为 Nerd Font，含图标），中文靠系统 Noto CJK 回退，兼顾体积与中文混排。
