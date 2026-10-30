#!/bin/bash
# 单张下载 worker：由 scripts/fetch-origin-png.sh 通过 xargs 并发调用
# 参数：$1 = 图片编号（如 AUT-0001）
#
# 两条硬约束：
# 1) 本机 DNS 会把 *.pages.dev 解析到沙箱假地址（198.18.0.0/15），TLS 握手全断。
#    源站在 Cloudflare 上，任一边缘 IP 都能按 SNI 回源，所以用 --resolve 钉死真实 IP。
# 2) 校验必须"三层"，只查文件头会放过截断文件：
#    a. curl 退出码必须为 0（超时/中断一律判失败）
#    b. 文件末尾必须带 IEND 块（截断的 PNG 没有）
#    c. 体积 > 400 KB 兜底
set -u
id="${1:-}"
[ -z "$id" ] && exit 1

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
OUT="$ROOT/assets/png"
BASE="${BASE:-https://ai-costume-gallery.pages.dev}"
HOST="ai-costume-gallery.pages.dev"
TRIES="${TRIES:-10}"
IPFILE="${IPFILE:-$HERE/cf-ips.txt}"
f="$OUT/$id.png"

PNG_MAGIC="89504e470d0a1a0a"
IEND_TAIL="0000000049454e44ae426082"   # IEND 块尾部 12 字节

valid() {
  [ -f "$1" ] || return 1
  local sz magic tail
  sz=$(stat -f%z "$1" 2>/dev/null || echo 0)
  [ "$sz" -gt 400000 ] || return 1
  magic=$(head -c 8 "$1" | xxd -p 2>/dev/null)
  [ "$magic" = "$PNG_MAGIC" ] || return 1
  tail=$(tail -c 12 "$1" | xxd -p 2>/dev/null)
  [ "$tail" = "$IEND_TAIL" ] || return 1
  return 0
}

if valid "$f"; then echo "SKIP $id"; exit 0; fi
rm -f "$f"

IPS=()
if [ -f "$IPFILE" ]; then
  while IFS= read -r ip; do [ -n "$ip" ] && IPS+=("$ip"); done < "$IPFILE"
fi
n=${#IPS[@]}

mkdir -p "$OUT"
for i in $(seq 1 "$TRIES"); do
  if [ "$n" -gt 0 ]; then
    ip="${IPS[$(( (i-1) % n ))]}"
    curl -sSL --fail -m 180 --connect-timeout 12 --resolve "$HOST:443:$ip" \
      "$BASE/png/$id.png" -o "$f.part" 2>/dev/null
  else
    curl -sSL --fail -m 180 --connect-timeout 12 \
      "$BASE/png/$id.png" -o "$f.part" 2>/dev/null
  fi
  rc=$?
  # rc≠0 → 超时/中断/HTTP 错误，磁盘上可能是半截文件，直接丢弃
  if [ "$rc" -eq 0 ] && valid "$f.part"; then
    mv -f "$f.part" "$f"
    echo "OK $id"
    exit 0
  fi
  rm -f "$f.part"
  sleep 1
done
echo "FAIL $id"
exit 1
