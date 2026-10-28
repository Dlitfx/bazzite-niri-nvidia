#!/usr/bin/env bash
# ============================================================
# 新机 AppImage 一键安装
# 用法：bash install-appimages.sh
# 下载到 ~/AppImages/download，给执行权限，同软件只留最新一份
# ============================================================
set -euo pipefail

DIR="$HOME/AppImages/download"
mkdir -p "$DIR"

URLS=(
  # 每行一个下载链接
  "https://github.com/Vysp3r/ProtonPlus/releases/download/v0.6.8/ProtonPlus-0.6.8-anylinux-x86_64.AppImage"
  "https://github.com/buxuku/SmartSub/releases/download/v3.11.0/SmartSub_Linux_3.11.0_x86_64.AppImage"
  "https://github.com/HanversionOvO/BiliMusic/releases/download/v1.0.2/BiliMusic-1.0.2-x86_64.AppImage"
)

for url in "${URLS[@]}"; do
  file="$DIR/${url##*/}"
  echo "下载 ${file##*/}"
  curl -fL --retry 3 -o "$file" "$url"
  chmod +x "$file"
done

# 同一软件只留最新：基础名相同即视为同一软件，保留修改时间最新的
declare -A newest
for f in "$DIR"/*.appimage "$DIR"/*.AppImage; do
  [[ -f $f ]] || continue
  key=$(basename "${f,,}" | sed 's/\.appimage$//; s/[_.-]/ /g' | tr -s ' ' | grep -oE '^[a-z]+')
  [[ -z $key ]] && continue
  if [[ -z ${newest[$key]:-} || $f -nt ${newest[$key]} ]]; then
    newest[$key]="$f"
  fi
done

for f in "$DIR"/*.appimage "$DIR"/*.AppImage; do
  [[ -f $f ]] || continue
  key=$(basename "${f,,}" | sed 's/\.appimage$//; s/[_.-]/ /g' | tr -s ' ' | grep -oE '^[a-z]+')
  [[ -z $key ]] && continue
  if [[ $f != "${newest[$key]}" ]]; then
    echo "删除旧版本 ${f##*/}"
    rm -f "$f"
  fi
done
