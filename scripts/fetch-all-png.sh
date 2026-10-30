#!/bin/bash
# 反复跑 fetch-origin-png.sh，直到 1407 张 PNG 全部到位或达到最大轮次。
# 网络出口不稳时（TLS 握手直接断、整站不可达）靠这个自己爬起来继续。
# 用法：bash scripts/fetch-all-png.sh
#   环境变量：PAR 并发数（默认 6）、MAXPASS 最大轮次（默认 30）、BACKOFF 起始等待秒（默认 60）

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

IDS="scripts/png-ids.txt"
OUT="assets/png"
PAR="${PAR:-10}"
MAXPASS="${MAXPASS:-30}"
BACKOFF="${BACKOFF:-60}"
LOG="logs/fetch-all.log"

mkdir -p "$OUT" logs
total=$(grep -c . "$IDS")
echo "[$(date '+%F %T')] 目标 ${total} 张，并发 ${PAR}，最多 ${MAXPASS} 轮" | tee -a "$LOG"

# 预检：出口不通时直接退避等待，别让 1407 条各自空转重试
# 本机 DNS 会把 pages.dev 解析到沙箱假地址，所以预检也走 cf-ips.txt 里的真实边缘 IP
HOST="ai-costume-gallery.pages.dev"
IPFILE="scripts/cf-ips.txt"
# 只统计"真正完整"的 PNG：体积足够 + IEND 结尾（截断文件不算）
count_ok() {
  local n=0 f
  for f in "$OUT"/*.png; do
    [ -e "$f" ] || continue
    [ "$(stat -f%z "$f" 2>/dev/null || echo 0)" -gt 400000 ] || continue
    [ "$(tail -c 12 "$f" | xxd -p 2>/dev/null)" = "0000000049454e44ae426082" ] && n=$((n+1))
  done
  echo "$n"
}

net_ok() {
  local ip code
  ip=$(head -1 "$IPFILE" 2>/dev/null)
  if [ -n "$ip" ]; then
    code=$(curl -sS -m 10 --connect-timeout 8 --resolve "$HOST:443:$ip" -o /dev/null -w '%{http_code}' \
      "https://$HOST/thumbs/SPR-0001.webp" 2>/dev/null)
  else
    code=$(curl -sS -m 10 --connect-timeout 8 -o /dev/null -w '%{http_code}' \
      "https://$HOST/thumbs/SPR-0001.webp" 2>/dev/null)
  fi
  [ "$code" = "200" ]
}

pass=0
pf_fail=0
PF_MAX="${PF_MAX:-30}"   # 预检连续失败上限，防止网络长期不通时无限等待
wait_s="$BACKOFF"
while [ "$pass" -lt "$MAXPASS" ]; do
  pass=$((pass+1))
  have=$(count_ok)
  [ "$have" -ge "$total" ] && break

  if ! net_ok; then
    pf_fail=$((pf_fail+1))
    if [ "$pf_fail" -gt "$PF_MAX" ]; then
      echo "[$(date '+%F %T')] 预检连续失败 ${pf_fail} 次，放弃本轮任务（已有 ${have}/${total}）" | tee -a "$LOG"
      break
    fi
    echo "[$(date '+%F %T')] 第 ${pass} 轮预检失败(${pf_fail}/${PF_MAX})：原站不可达，等 ${wait_s}s（已有 ${have}/${total}）" | tee -a "$LOG"
    sleep "$wait_s"
    wait_s=$(( wait_s * 2 )); [ "$wait_s" -gt 600 ] && wait_s=600
    pass=$((pass-1))   # 预检失败不计入轮次，避免网络断太久把额度耗光
    continue
  fi
  pf_fail=0; wait_s="$BACKOFF"

  echo "[$(date '+%F %T')] === 第 ${pass} 轮开跑，当前已有 ${have}/${total} ===" | tee -a "$LOG"

  PAR="$PAR" bash scripts/fetch-origin-png.sh "$IDS" >> "$LOG" 2>&1

  now=$(count_ok)
  gained=$((now - have))
  echo "[$(date '+%F %T')] 本轮新增 ${gained}，累计 ${now}/${total}" | tee -a "$LOG"
  [ "$now" -ge "$total" ] && break

  if [ "$gained" -le 0 ]; then
    echo "[$(date '+%F %T')] 本轮零进展，疑似出口网络不通，等待 ${wait_s}s 后重试" | tee -a "$LOG"
    sleep "$wait_s"
    wait_s=$(( wait_s * 2 )); [ "$wait_s" -gt 900 ] && wait_s=900
  else
    wait_s="$BACKOFF"
    sleep 3
  fi
done

final=$(count_ok)
echo "[$(date '+%F %T')] 结束：${final}/${total} 张，占用 $(du -sm "$OUT" | awk '{print $1}') MB" | tee -a "$LOG"
[ "$final" -lt "$total" ] && echo "未完成。网络恢复后重跑：bash scripts/fetch-all-png.sh" | tee -a "$LOG"
exit 0
