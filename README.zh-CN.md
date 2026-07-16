![cairn —— 有人来过，这条路通](assets/cover.png)

# 🪨 cairn（垒石）

> AI 换个会话就失忆——把项目记忆写进仓库，下次它自己接上，不用你从头讲。

**cairn** 是给 AI 编码 agent（Claude Code / Cursor / Codex …）用的 markdown 原生记忆与进度层。没有框架、没有运行时、没有数据库——只有一套"新鲜感褪去之后仍然在用"的目录约定。

*cairn*（垒石）是登山者在路上垒的石堆路标：它不指挥你怎么走，只告诉后来的人——**有人来过，这条路通**。

[English →](README.md)

![cairn 一次完整循环：起任务 → scratch → 收尾垒一行 → 下次 agent 自动接上](assets/how-it-works-zh.svg)

## 快速开始

**装它：把这句话丢给你的 agent。** 在 Claude Code、Codex 等支持 skill 的 agent 里，直接说：

> 帮我安装 cairn 并在当前项目落地：https://github.com/hjxccc/cairn

它会自己拷 skill、把 `.cairn/` 结构铺进项目、接好根目录拦截 hook。装完之后日常也只说人话，它自动建任务目录、垒 INDEX、查历史、记坑：

> 「起个任务：修登录超时」 → 「记一下进度」 → 「收尾」 → 「这个以前处理过没？」

<details>
<summary><b>想手动装 / 没接 agent？</b></summary>

```bash
git clone https://github.com/hjxccc/cairn
cairn/install.sh /path/to/你的项目          # 幂等，不覆盖已有文件
```

- **Claude Code**：把 `skill/` 拷到 `~/.claude/skills/cairn/`，再把 `hooks/settings-hooks.json` 合并进 `.claude/settings.json`（只追加）。
- **任意 agent**（Cursor / Windsurf…）：把 `templates/agent-snippet.md` 贴进 `AGENTS.md`——约定就是 markdown，不依赖 hook。

</details>

> 前置：`git` + `bash`（Windows 用 Git Bash）；`python3` 只有可选的根目录拦截 hook 才需要。完整教程（含真实输出）见 [docs/tutorial.zh-CN.md](docs/tutorial.zh-CN.md)。

## 解决什么开发痛点

![三个痛点，三个仓库原生的答案](assets/why-cairn-zh.svg)

用 AI agent 干活，这三件事天天硌人：

**① 一开新对话，AI 就"失忆"了。** 项目背景、团队规范、上次改出了啥结论——全在上一段聊天里，新会话两眼一抹黑，你又得从头讲一遍。
→ cairn 把这些**写进仓库**（`INDEX.md`、任务总结、坑账、SOP 都是文件）：会话会关，文件不丢，新会话里 agent 自己把那条翻回来，不用你重讲。

**② 活干到一半，换个会话就"我上次弄到哪了？"** 长任务跨好几天、好几次对话，进度没个准地方放（记在会过期的指针文件里，两周后就没人信了）。
→ cairn 把进度**记在任务自己的 `progress.md`**、INDEX 行首标个 🚧：新会话里 agent 一条 `grep "^- 🚧"` 就列出所有没干完的活，读对应 `progress.md` 的"下一步"接着走，漂移了有只读的 `doctor.sh` 兜底。

**③ 上个月踩过的坑，这个月又踩一遍。** 你踩过、同事踩过、另一个 AI 会话还在踩——因为没人把它记在找得到的地方。
→ cairn 让**坑账一行一坑、SOP 能照跑**：动手前 agent 先翻一遍历史，踩过的直接复用，不重新趟一遍雷。

> 三件事一个共性：**会话会结束，仓库不会忘。** 会话是易失的、说完就散，仓库跟着 git 一直在。cairn 不往每次会话里塞历史（那样又慢又占地方），而是把痕迹留在 repo、要用时 agent 一条 `grep` 就捞回来——为什么用 grep 不用向量库，见 [决策 004](docs/decisions/004-grep-over-vector-search.md)。

## cairn vs 传统做法

不是每项都赢，是不同的成本模型：

| 维度 | 手动规则文件（`.cursorrules`/`CLAUDE.md`） | 重型工作流框架 | **cairn** |
|---|---|---|---|
| 跨会话记忆 | 无——每次重讲 | 预先注入（有，但占上下文） | 痕迹在 repo，检索时才取 |
| 会话启动开销 | 轻 | 每次注入一份规范（某项目实测 ~22KB） | ~1.5KB 规则 + 轻量指针 |
| 历史越攒越多时 | 都堆进规则文件，上下文跟着涨 | 注入内容随启用的规范/状态涨 | 历史留在 repo，启动上下文不跟着涨，命中才读那一个文件 |
| 进度 / 状态 | 没处放 | 框架维护生命周期状态（可能过期） | 长在任务 `progress.md` + INDEX 🚧（`doctor.sh` 揪过期） |
| 找历史 | 翻聊天记录 | 全量预注入，要的那条淹在里面 | agent `grep` 命中（快路径）→ 没中读小索引 |
| 上手 | 贴个文件 | 装框架 + 配置 + 适配层 | 一条命令，或一句话给 agent |
| 团队共享 | 单文件，人人不同 | 框架内共享 | 分层：个人层 gitignore + 团队层入 git |
| 平台耦合 | 绑单一工具 | 需框架协议 + 适配层 | 核心 markdown，不依赖平台 |
| **cairn 的代价 · 检索** | — | — | 关键词字面匹配、不是语义：换个说法可能漏，靠标签 + 小索引兜底，但不保证命中 |
| **cairn 的代价 · 执行** | — | — | 靠约定、非运行时强制：收尾那行得真写、skill 得真加载，否则记忆会缺页 |

重型框架的自动注入适合"想零成本加载 + 流程强约束"的团队；单个规则文件适合"极简单文件"的项目；cairn 适合工作是即兴的（排障、补数、救火）、又想要持久可 grep、可团队共享、还没有机器要喂养——它的赌注是：**在检索时付费，不在每次会话付费。**

## 管什么

六类项目知识，共用一个模式（**一行索引 + 详情文件**）：

| 类型 | 回答 | 位置 | 索引 |
|---|---|---|---|
| **任务留痕** | 做过什么、结论是什么 | `tasks/MM-DD-<topic>/` | `tasks/INDEX.md` |
| **进度** | 做到哪、卡在哪 | 长任务内 `progress.md` | INDEX 的 🚧 标记 |
| **SOP** | 怎么做 X（可重复步骤） | `sop/` | `sop/index.md` |
| **决策** | 系统为什么长这样 | `docs/decisions/NNN-*.md` | 编号文件名 |
| **坑与规约** | 什么会翻车 / 详细规范 | `spec/` | 自身 / AGENTS.md 指针行 |
| **文档** | 方案、文章 | `docs/` | 可选 |

```
.cairn/
├── tasks/
│   ├── INDEX.md              # ⭐ 一行一任务，新的在上
│   └── 07-14-payment-bug/
│       ├── scratch/          # gitignore：调试脚本、数据、截图
│       ├── progress.md       # 只有跨会话长任务才有
│       └── summary.md
├── sop/                      # ⭐ agent 可照跑的步骤化流程
├── spec/
│   ├── pitfalls.md           # 坑账：踩到当场记一行
│   └── <主题>.md             # CLAUDE.md 放不下的详细规约——那边留指针，按需读
├── docs/decisions/           # 轻量决策记录，带 superseded 链
└── scripts/
    ├── mktmp.sh              # 一条命令起任务
    └── doctor.sh            # 揪过期 🚧 标记 + 悬空 INDEX 引用
```

整个"项目记忆"都是可 grep 的纯文本——agent 要用时 `grep 🚧 INDEX.md` 就是进度面板，`grep -i 支付 INDEX.md` 就是"以前处理过没"。

「一个文件夹 + 一个习惯」唯一还会烂的地方，是某个 `🚧` 标记悄悄过期（跟生命周期指针烂掉一个道理）。`./.cairn/scripts/doctor.sh` 是个零依赖 bash，揪四类漂移：挂着标记但任务超过 N 天（默认 🚧 14 / ⏸ 60）没动、标记指向的任务目录已不存在、重复 slug、以及索引里的死链接。它**故意不进 SessionStart hook**——你想查才跑，不是每次开会话都跑。跨仓一把梭：`for d in */.cairn; do (cd "$d/.." && ./.cairn/scripts/doctor.sh); done`。

![cairn 工作原理](assets/architecture-zh.svg)

**典型样例**：[examples/sample-trail](examples/sample-trail)——一个虚构（完全脱敏）的支付团队两周足迹：7 个任务、一次重试风暴复盘、一篇"险情后补了前置检查"的 runbook、一次坑账就地修订、一条"为什么用幂等键不用 Redis 锁"的决策（含被否选项）。全部加起来约 150 行 markdown。

## 一切始于一次"尸检"

我们在一个多仓库生产项目上，完整用了 **5 个月、148 个任务**的重型 AI 工作流框架（就是上面对比表中间那列），然后审计了实际使用情况：

![尸检：同一批任务里各组件的实际使用率](assets/autopsy-survival-zh.svg)

| 组件 | 5 个月后的判决 |
|---|---|
| 日期任务目录（`MM-DD-topic/`） | ✅ 148 个，天天在用 |
| scratch 目录约定 + 根目录拦截 hook | ✅ 无名英雄 |
| 纯 markdown 的可复用 runbook | ✅ 高频引用 |
| 按任务的 JSONL 上下文注入 | ❌ 148 个任务只有 2 个用过 |
| agent 流水线（plan→implement→check→debug） | ❌ 第一个月后废弃 |
| 任务生命周期状态文件（task.json / .current-task） | ❌ 148 个只有 10 个；指针过期数周 |
| 会话日志 journal | ❌ 5 个月写了 7 行 |
| 每次会话注入 22KB 工作流文档 | ❌ 描述一个没人走的流程 |

**规律**：凡是需要纪律去喂养机器的，都死了；凡是"一个文件夹 + 一个习惯"的，都活了。真实的 agent 工作是即兴的——排障、补数、救火——不是 PRD 驱动的流水线。

cairn 提炼的就是这次审计里**持续在用的那几样**——日期任务目录、scratch + 拦截 hook、纯 markdown runbook；再补上尸检暴露缺失的三块（决策记录、反馈闭环、坑账修订）。完整故事见 [docs/philosophy.md](docs/philosophy.md)。

## 六条原则

1. **足迹留在 repo，不在工具里**——markdown + git 是唯一持久层。内置 agent 记忆锁死单机、绑定绝对路径、团队不可见、索引会撑爆。
2. **任务 = 日期文件夹**——一条命令建好，无状态机、无必填字段。
3. **脏净分离**——一次性产物（实测 579MB）进 gitignore 的 `scratch/`，hook 保根目录干净。
4. **永远是索引 + 详情**——检索 = grep 索引再读一个文件。几百条量级下 grep 优于向量库，这才是 repo 记忆的正确规模。
5. **按需检索，零注入**——记得太多是真实故障模式。遗忘 = 不检索，成本为零。
6. **约定优先于机器；状态长在任务身上**——进度标记只在 INDEX 和任务自己的 progress.md 里，绝不放独立指针文件（我们的指针两周就烂了）。任何维护动作超过 2 分钟即设计错误。

## 有依据，不是玄学

六类结构可对应到 LLM agent 认知架构的标准分类 [CoALA](https://arxiv.org/abs/2309.02427)（任务留痕=情景记忆，坑/规约=语义记忆，SOP=程序记忆，INDEX 一行=Generative Agents 的反思压缩层）；升级链（任务→SOP→skill，坑→规则）对应记忆固化的 curator 模式。工程侧则是 SRE runbook / blameless postmortem / ADR supersede 链 / Diátaxis 的 repo 内极简版。详见 [docs/grounding.md](docs/grounding.md)。

## 与同类的区别

- **规格驱动框架**（Spec Kit / BMAD）：编排"计划"；cairn 记录"实际发生了什么"。可共存。
- **agent 任务追踪器**（Beads）：面向多 agent 并行执行的依赖图数据库；cairn 是人类可读的考古层——五年后还能读。
- **Markdown 看板**（Backlog.md）：最近的表亲，管"未来的工作"；cairn 管"过去的知识"+ 轻进度层。
- **内置 agent 记忆**：单机、路径锁定、不进 git；cairn 团队资产入仓、个人足迹可迁移。

## FAQ

**为什么个人层默认不进 git？** 任务足迹是个人的，共享仓库里人人提交等于互相污染。install.sh 默认 gitignore `tasks/` 和 `pitfalls.md`，确需共享的单文件 `git add -f` 显式入库；团队资产（sop/、spec/<主题>.md、decisions/）正常提交。（[决策 001](docs/decisions/001-personal-layer-not-in-git.md)）

**详细的编码规范/领域约定放哪？** 不放 AGENTS.md——那里只放 200 行内的"每次必须遵守"。详细规约放 `spec/<主题>.md`（进 git），AGENTS.md 留一行指针（"改 X 前先读 spec/x.md"），agent 按需读全文——要分层，不要自动注入。

**为什么不做 CLI 工具？** 尸检结论：机器会死。cairn 是一个 40 行 bash 脚本 + 一个可选 hook + 约定。没有东西需要升级，没有东西会坏，拷走即迁移。

**必须用 Claude Code 吗？** 不。skill 和 hook 是 Claude Code 的糖；约定本身对任何能读 AGENTS.md 的 agent 都成立——甚至不用 agent 也成立。

**存量老任务怎么办？** 不回填。半途而废的迁移比不迁移更糟。只往前建索引，老档案用 `ls tasks/ | grep` 兜底。

## License

MIT
