#!/bin/bash
# 从原站 ai-costume-gallery.pages.dev 拉取 PNG 原图到 assets/png/（不进 git）
# - 断点续传：已完整（>500KB 且 PNG magic 正确）的文件自动跳过，可反复重跑
# - 并发 + 重试：该站走代理时 TLS 握手高频失败，纯单线程反而更慢
# 用法：PAR=8 bash scripts/fetch-origin-png.sh <id清单文件>

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

IDS="${1:-/tmp/png_ids.txt}"
OUT="assets/png"
PAR="${PAR:-8}"
TRIES="${TRIES:-10}"
LOG="logs/fetch-png.log"
PROG="logs/fetch-png-progress.txt"
FAIL="logs/fetch-png-failed.txt"

if [ ! -f "$IDS" ]; then
  echo "找不到 id 清单：$IDS" >&2
  exit 1
fi

mkdir -p "$OUT" logs
chmod +x scripts/fetch-one-png.sh
: > "$FAIL"

total=$(grep -c . "$IDS")
echo "[$(date +%H:%M:%S)] 开始：共 ${total} 张，并发 ${PAR}，单张最多重试 ${TRIES} 次" | tee -a "$LOG"

start=$(date +%s)
grep . "$IDS" | TRIES="$TRIES" xargs -P "$PAR" -n1 ./scripts/fetch-one-png.sh > "$PROG" 2>/dev/null

count() { local n; n=$(grep -c "^$1" "$PROG" 2>/dev/null); echo "${n:-0}"; }
ok_n=$(count OK)
skip_n=$(count SKIP)
fail_n=$(count FAIL)
grep '^FAIL' "$PROG" 2>/dev/null | awk '{print $2}' > "$FAIL"

el=$(( $(date +%s) - start ))
sz=$(du -sm "$OUT" | awk '{print $1}')
echo "=== 完成：新增 ${ok_n}，跳过 ${skip_n}，失败 ${fail_n}，目录 ${sz} MB，耗时 $((el/60)) 分 $((el%60)) 秒 ===" | tee -a "$LOG"
if [ "${fail_n}" -gt 0 ]; then
  echo "失败清单：$FAIL（直接重跑本脚本即可补齐）" | tee -a "$LOG"
fi
exit 0
