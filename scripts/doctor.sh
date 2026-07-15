#!/usr/bin/env bash
# doctor.sh — cairn 漂移自检（零依赖，纯 bash，只读，绝不自动修）
#
# 揪这些（都从现场现算，不存任何状态）：
#   1. 陈旧标记：🚧 超 STALE_DAYS（默认 14）没动 / ⏸ 超 WAIT_DAYS（默认 60）没动
#   2. 悬空标记：INDEX 的 🚧/⏸ 指向的任务目录/文件不存在
#   3. 重复 slug：INDEX 里同一个任务 slug 出现多行
#   4. 索引死链：INDEX / 各 目录.md / index.md 里的相对链接目标不存在
#   （游离目录默认不报，存量不回填是常态；要看传 --orphans / -v）
#
# 用法：
#   ./.cairn/scripts/doctor.sh                 # 默认阈值
#   ./.cairn/scripts/doctor.sh 30              # 🚧 阈值改 30 天
#   STALE_DAYS=7 WAIT_DAYS=45 ./.cairn/scripts/doctor.sh
#   ./.cairn/scripts/doctor.sh --orphans       # 额外报游离目录
#
# 退出码：0 = 干净；1 = 有需处理项。可挂 CI / pre-commit。

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_dir="$(dirname "$script_dir")"
base_name="$(basename "$base_dir")"
index="$base_dir/tasks/INDEX.md"
tasks_dir="$base_dir/tasks"

STALE_DAYS="${STALE_DAYS:-14}"   # 🚧 进行中
WAIT_DAYS="${WAIT_DAYS:-60}"     # ⏸ 等外部，本就该挂更久
SHOW_ORPHANS="${SHOW_ORPHANS:-0}"
for a in "$@"; do
  case "$a" in
    --orphans|-v) SHOW_ORPHANS=1 ;;
    *[!0-9]*|'')  : ;;
    *)            STALE_DAYS="$a" ;;
  esac
done
now="$(date +%s)"

[[ -f "$index" ]] || { echo "cairn doctor: 找不到 $index" >&2; exit 2; }

last_activity () {  # 任务目录/扁平 md 内「最新文件 mtime」的 epoch，找不到回 MISSING
  local slug="$1"
  if [[ -d "$tasks_dir/$slug" ]]; then
    find "$tasks_dir/$slug" -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -1 | cut -d. -f1
  elif [[ -f "$tasks_dir/$slug.md" ]]; then
    stat -c %Y "$tasks_dir/$slug.md" 2>/dev/null
  else
    echo "MISSING"
  fi
}

urldecode () { printf '%b' "${1//%/\\x}"; }  # 只需处理 %20 这类空格

echo "cairn doctor — $base_name/  (🚧≤${STALE_DAYS}天 / ⏸≤${WAIT_DAYS}天)"
echo

rc=0

# ---- 1+2 在途标记：陈旧 / 悬空 ----
inflight="$(grep -nE '^- [^[:alnum:] ]' "$index" 2>/dev/null || true)"
stale=(); dangling=()
if [[ -n "$inflight" ]]; then
  echo "  在途标记：$(printf '%s\n' "$inflight" | grep -c .) 个，逐个体检…"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    slug="$(printf '%s' "$line" | grep -oE '([0-9]{4}-)?[0-9]{2}-[0-9]{2}-[A-Za-z0-9][A-Za-z0-9-]*' | head -1)"
    [[ -z "$slug" ]] && continue
    if [[ "$line" == *"⏸"* ]]; then mk="⏸"; limit="$WAIT_DAYS"; else mk="🚧"; limit="$STALE_DAYS"; fi
    act="$(last_activity "$slug")"
    if [[ "$act" == "MISSING" ]]; then
      dangling+=("$mk $slug")
    else
      age=$(( (now - act) / 86400 ))
      (( age > limit )) && stale+=("$mk $slug  (最后活动 ${age} 天前，阈值 ${limit})")
    fi
  done <<< "$inflight"
else
  echo "  在途标记：无 🚧/⏸"
fi
echo

if (( ${#stale[@]} > 0 )); then
  echo "⚠️  陈旧（还挂着标记但超阈值没动）:"; printf '   - %s\n' "${stale[@]}"
  echo "   → 收尾（垒 INDEX 一行、去标记）或续上进度"; echo; rc=1
fi
if (( ${#dangling[@]} > 0 )); then
  echo "❌ 悬空（标记指向的任务目录/文件不存在）:"; printf '   - %s\n' "${dangling[@]}"
  echo "   → 修 INDEX 里的 slug 或删掉该行"; echo; rc=1
fi

# ---- 3 重复 slug（整个 INDEX 里同一 slug 多行）----
dups="$(grep -oE '([0-9]{4}-)?[0-9]{2}-[0-9]{2}-[A-Za-z0-9][A-Za-z0-9-]*' "$index" 2>/dev/null | sort | uniq -d || true)"
if [[ -n "$dups" ]]; then
  echo "❌ 重复 slug（INDEX 里同一任务出现多行）:"; printf '   - %s\n' $dups
  echo "   → 合并成一行，避免检索时撞车"; echo; rc=1
fi

# ---- 4 索引死链（INDEX + 各 目录.md / index.md 里的相对链接）----
deadout="$(
  while IFS= read -r md; do
    [[ -z "$md" ]] && continue
    mdir="$(dirname "$md")"
    while IFS= read -r target; do
      [[ -z "$target" ]] && continue
      case "$target" in *://*|\#*|mailto:*|/*) continue ;; esac   # 跳过任何 scheme://、锚点、绝对路径
      t="${target%%#*}"; [[ -z "$t" ]] && continue
      t="$(urldecode "$t")"
      [[ -e "$mdir/$t" ]] || printf '%s → %s\n' "${md#$base_dir/}" "$target"
    done < <(grep -oE '\]\(([^)]+)\)' "$md" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' || true)
  done < <(find "$base_dir" -type f \( -name 'INDEX.md' -o -name '目录.md' -o -name 'index.md' \) \
            -not -path '*/scratch/*' -not -path '*/workspace/*' -not -path '*/backup/*' 2>/dev/null)
)" || true
if [[ -n "$deadout" ]]; then
  echo "❌ 索引死链（相对链接目标不存在）:"
  printf '%s\n' "$deadout" | sed 's/^/   - /'
  echo "   → 修链接或补文件（这类死链最爱藏在 目录.md 里）"; echo; rc=1
fi

# ---- 游离目录（opt-in）----
if [[ "$SHOW_ORPHANS" == "1" && -d "$tasks_dir" ]]; then
  orphan=0
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    grep -qF "$(basename "$d")" "$index" 2>/dev/null || orphan=$((orphan+1))
  done < <(find "$tasks_dir" -mindepth 1 -maxdepth 1 -type d -regextype posix-extended \
            -regex '.*/([0-9]{4}-)?[0-9]{2}-[0-9]{2}-.*' 2>/dev/null)
  echo "ℹ️  游离任务目录（磁盘有、INDEX 没提）: ${orphan} 个（存量不回填属正常，非错误）"; echo
fi

(( rc == 0 )) && echo "✅ 无陈旧/悬空/重复/死链，INDEX 与磁盘一致。" || echo "结论：上面这些需要处理一下。"
exit $rc
