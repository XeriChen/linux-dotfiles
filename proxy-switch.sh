#!/usr/bin/env bash
# ============================================================================
# 代理开关（非侵入式，仅 source 后、调用 proxy_on 才生效，不改全局 git 配置）
#
# 用法：
#   source ./proxy-switch.sh
#   proxy_on                 # 走本地 mihomo（默认 127.0.0.1:7890）
#   git clone https://github.com/...   # 此时自动走代理
#   proxy_off                # 关闭，恢复直连
#
#   gh_clone owner/repo      # 或：用镜像站 clone（无需本地代理）
#   MIRROR=kgithub.com gh_clone owner/repo   # 换镜像站
# ============================================================================

PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
PROXY_PORT="${PROXY_PORT:-7897}"   # mihomo 默认混合端口

proxy_on() {
  export http_proxy="http://${PROXY_HOST}:${PROXY_PORT}"
  export HTTP_PROXY="$http_proxy"
  export https_proxy="http://${PROXY_HOST}:${PROXY_PORT}"
  export HTTPS_PROXY="$https_proxy"
  # socks 端口通常为 http 端口 +1（mihomo 默认 7891）
  export all_proxy="socks5://${PROXY_HOST}:$((${PROXY_PORT} + 1))"
  export ALL_PROXY="$all_proxy"
  echo "代理已开启 -> ${https_proxy} (socks: ${all_proxy})"
}

proxy_off() {
  unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
  echo "代理已关闭，恢复直连"
}

# 用镜像站 clone，无需本地代理
# 默认 ghproxy.com；kgithub.com 用替换域名的方式
gh_clone() {
  local repo="$1"
  local mirror="${MIRROR:-ghproxy.com}"
  local url
  case "$repo" in
    https://github.com/*) url="${repo#https://github.com/}" ;;
    git@github.com:*)     url="${repo#git@github.com:}" ;;
    *)                    url="$repo" ;;
  esac
  if [ "$mirror" = "kgithub.com" ]; then
    git clone "https://kgithub.com/${url}"
  else
    git clone "https://${mirror}/https://github.com/${url}"
  fi
}
