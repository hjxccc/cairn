# 10 分钟上手 cairn（实操教程）

以下每条命令都真实跑过，输出是实测的。

## 0. 前置条件

- `git` 和 `bash` —— Windows 用 **Git Bash**（装 Git for Windows 自带）即可；PowerShell 原生安装在路线图上
- `python3` —— 只有可选的根目录拦截 hook 需要
- 编码 agent（Claude Code / Cursor / Codex …）推荐但**非必需**——约定本身就是纯文件

## 1. 安装（30 秒）

```bash
git clone https://github.com/hjxccc/cairn
cd 你的项目
/path/to/cairn/install.sh .
```

装完三步验证：

```bash
ls .cairn/                                   # → tasks/ scripts/ sop/ spec/ docs/
./.cairn/scripts/mktmp.sh demo && ls .cairn/tasks/   # → 建出 07-14-demo/
tail -3 .gitignore                           # → 个人层两条 ignore 已加
```

重复运行 `install.sh` 安全——永不覆盖已有文件。

## 2. 接上你的 agent（按工具选）

| 工具 | 做法 |
|---|---|
| **Claude Code** | `cp -r /path/to/cairn/skill ~/.claude/skills/cairn`——之后"起个任务/收尾/以前处理过没"agent 全自动接住。可选：把 `hooks/settings-hooks.json` 的条目**追加合并**进项目 `.claude/settings.json`（别整体覆盖），启用根目录拦截 |
| **Cursor / Codex / Windsurf / 任意** | 把 `templates/agent-snippet.md` 贴进 `AGENTS.md` / `.cursorrules` / 规则文件。不需要 hook——约定就是 markdown 指令 |
| **不用 agent** | 直接自己敲下面的命令。文件本身就是产品 |

## 3. 第一天：起第一个任务

出问题了，起任务：

```bash
$ cd "$(./.cairn/scripts/mktmp.sh payment-timeout-debug)"
[mktmp] created: .cairn/tasks/07-14-payment-timeout-debug/
[mktmp]   - scratch/   (gitignored; put debug scripts, dumps, screenshots here)
```

排查两小时，所有一次性产物——探测脚本、数据快照、截图——全丢进 `scratch/`。它在 gitignore 里，随任务一起消亡，这正是设计。

修好了？**收尾**（对 agent 说"收尾"，或手动）：往 `.cairn/tasks/INDEX.md` **顶部**垒一行：

```markdown
- 07-14-payment-timeout-debug — 自家重放cron无抖动=重试风暴；已加上限+抖动 [支付][超时]
```

这一行的规矩：≤120 字符、写**结论**（查到什么/修了什么，不是主题复述）、带 2–4 个 `[关键词]`、新的在上。整个仪式就这一行，最多两分钟。

## 4. 第二周：回报来了

**"以前处理过没？"**

```bash
$ grep -i 超时 .cairn/tasks/INDEX.md
- 07-14-payment-timeout-debug — 自家重放cron无抖动=重试风暴；已加上限+抖动 [支付][超时]
```

一行告诉你：解决过、根因是什么、去哪读详情。省掉整轮重新排障。

**"现在做到哪了？"**——跨会话任务行首标 `- 🚧 `（进行中）或 `- ⏸ `（等外部）：

```bash
$ grep "^- 🚧\|^- ⏸" .cairn/tasks/INDEX.md
- 🚧 07-13-checkout-migration — v2 放量 25%，错误预算健康 [结算][迁移]
- ⏸ 07-11-invoice-fonts — 修复就绪，等供应商字体授权 [发票][pdf]
```

这就是站会。长任务目录里另维护 `progress.md`（目标/已完成/下一步/卡点），断了随时从"下一步"接上。

## 5. 升级：知识长大离开任务

收尾时自问两句：

1. **"这操作以后还会做吗？"** 第二次做同类 → 抽成 `sop/<动词-主题>.md`（何时用/前置检查/编号步骤+预期输出/验证/回滚），`sop/index.md` 挂一行。下次照跑，不再重新探索。踩坑了 → `spec/pitfalls.md` 记一行。
2. **"半年后有人会问为什么吗？"** 会 → 登记 `docs/decisions/NNN-<主题>.md`，把被否的候选写明。以后被推翻？新开一篇、旧篇标 `superseded by NNN`——永不改写历史。

完整实例（7 个任务、一篇从险情长出来的 SOP、一条真实决策）见 [examples/sample-trail](../examples/sample-trail)。

## 6. 团队协作

个人层（`tasks/`、INDEX、`pitfalls.md`）默认 gitignore——足迹是你自己的，确需共享的单文件 `git add -f`。团队层（`sop/`、`docs/`、`spec/<主题>.md`）正常提交，随 clone 走。

## 排障

| 症状 | 处置 |
|---|---|
| `mktmp.sh: command not found` | 带路径跑 `./.cairn/scripts/mktmp.sh`，或补 `chmod +x` |
| hook 没拦根目录垃圾 | 查 `.claude/settings.json` 的 PreToolUse 注册 + `python3` 在 PATH |
| 面板 grep 混进表头文字 | 用锚定版 `grep "^- 🚧\|^- ⏸"` |
| 装错仓库了 | 没有卸载这回事——删 `.cairn/` 和 .gitignore 里那 3 行即可 |
