#!/usr/bin/env bash
# cairn-cost.sh — 估算 cairn 的「token 足迹」，零依赖纯 bash（只读，不改任何文件）。
#
# 回答「用 cairn 每次会话多花多少 token」：
#   1. 常驻税（always-on）：每次会话都会被加载/注入的那部分 —— cairn 的核心卖点是这个要小。
#      = 固定前言（≈ 120 tok，常量）+ 在途面板（随 🚧/⏸ 数量涨，是这里唯一会膨胀的量）。
#   2. 按需（on-demand）：只有真做 cairn 动作时才付 —— SKILL 载入、grep 命中、读一个任务文件。
#
# token 是估算：中文按 ~0.6 tok/字、拉丁/符号按 ~0.28 tok/字（贴近现代 o200k/Claude 分词）；
# 要精确值加 --tiktoken（需本机装 python+tiktoken，否则自动回退估算）。
#
# 用法：
#   ./.cairn/scripts/cairn-cost.sh              # 足迹报告
#   ./.cairn/scripts/cairn-cost.sh --tiktoken   # 用真 tokenizer（有则精确）
#   PANEL_WARN=1500 ./.cairn/scripts/cairn-cost.sh   # 在途面板超 N tok 告警（默认 1500）
#
# 退出码：0 = 面板在预算内；1 = 在途面板超阈值，该收几个尾了。

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_dir="$(dirname "$script_dir")"
base_name="$(basename "$base_dir")"
index="$base_dir/tasks/INDEX.md"
PANEL_WARN="${PANEL_WARN:-1500}"
USE_TIKTOKEN=0
for a in "$@"; do case "$a" in --tiktoken) USE_TIKTOKEN=1 ;; esac; done

[[ -f "$index" ]] || { echo "cairn-cost: 找不到 $index" >&2; exit 2; }

# est_tokens <file>  → 打印估算 token 数（中文 0.6 + 其余 0.28 tok/字）。
# 纯 bash：UTF-8 里 CJK 多为 3 字节、ASCII 为 1 字节，用「字节数 - 字符数」推断 CJK 占比。
est_tokens () {
  local f="$1" chars bytes cjk other
  chars=$(wc -m < "$f" | tr -d ' ')
  bytes=$(wc -c < "$f" | tr -d ' ')
  # UTF-8 里 CJK 多为 3 字节、ASCII 为 1 字节：cjk ≈ (bytes-chars)/2，other ≈ chars-cjk
  cjk=$(( (bytes - chars) / 2 ))
  (( cjk < 0 )) && cjk=0
  (( cjk > chars )) && cjk=$chars
  other=$(( chars - cjk ))
  # 估 token：中文 0.6、其余 0.28（用整数算：*60/100、*28/100）
  echo $(( cjk*60/100 + other*28/100 ))
}

tiktoken_tokens () {  # 精确：python+tiktoken，失败回退 est_tokens
  local f="$1"
  if (( USE_TIKTOKEN )); then
    local n
    n=$(python - "$f" <<'PY' 2>/dev/null || true
import sys
try:
    import tiktoken; enc=tiktoken.get_encoding("o200k_base")
    print(len(enc.encode(open(sys.argv[1],encoding="utf-8").read())))
except Exception: pass
PY
)
    [[ -n "$n" ]] && { echo "$n"; return; }
  fi
  est_tokens "$f"
}

# 抽在途面板（🚧/⏸ 行）到临时文件量它
panel="$(mktemp)"; trap 'rm -f "$panel"' EXIT
grep -E '^- [^[:alnum:] ]' "$index" 2>/dev/null > "$panel" || true
inflight=$(grep -c . "$panel" || true)

idx_tok=$(tiktoken_tokens "$index")
panel_tok=$(tiktoken_tokens "$panel")
FIXED_PREAMBLE=120   # session-start 固定前言的经验常量（tok）
alwayson=$(( FIXED_PREAMBLE + panel_tok ))
label="估算"; (( USE_TIKTOKEN )) && python -c "import tiktoken" 2>/dev/null && label="tiktoken 精确"

echo "cairn-cost — $base_name/   （token: $label）"
echo
echo "【每次会话·常驻税 always-on】≈ ${alwayson} tok"
echo "   固定前言（常量）            ≈ ${FIXED_PREAMBLE} tok"
echo "   在途面板（${inflight} 条 🚧/⏸）      ≈ ${panel_tok} tok   ← 唯一会随时间涨的量"
echo
echo "【按需·检索时才付 on-demand】"
echo "   INDEX.md 全文（grep 时才碰） ≈ ${idx_tok} tok  ($(wc -l < "$index" | tr -d ' ') 行)"
echo "   SKILL.md（触发场景才载入）   ≈ 见 skill 目录，整会话至多一次"
echo
echo "【对照】被尸检的重型框架：每次会话静态注入 22KB ≈ 5000–7000 tok"
echo

if (( panel_tok > PANEL_WARN )); then
  echo "⚠️  在途面板 ${panel_tok} tok 超阈值 ${PANEL_WARN} —— 收几个尾（改写/去 🚧）能直接降常驻税。"
  echo "    看在途：grep \"^- 🚧\\|^- ⏸\" $index"
  exit 1
fi
echo "✅ 常驻税在预算内（在途面板 ${panel_tok} ≤ ${PANEL_WARN} tok）。"
