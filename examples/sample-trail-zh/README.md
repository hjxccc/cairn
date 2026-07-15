# 示例留痕（脱敏 · 中文）

一支**虚构、完全脱敏**的电商交易团队两周留痕，演示六类内容如何协同（英文版见 `../sample-trail/`）：

- **[tasks/INDEX.md](tasks/INDEX.md)** —— 石标栈：7 个任务，1 个 🚧 在途、1 个 ⏸ 等供应商。`grep 🚧` 就是每日站会。
- **[tasks/03-18.../summary.md](tasks/03-18-payment-timeout-storm/summary.md)** —— 一次收尾，文末答完"两问自检"。
- **[tasks/03-22.../progress.md](tasks/03-22-checkout-v2-rollout/progress.md)** —— 跨会话长任务，从"下一步/卡点"冷启动就能接上。
- **[sop/拉脱敏生产数据到预发.md](sop/拉脱敏生产数据到预发.md)** —— agent 能照跑的 runbook，其中一条前置检查是**踩了一次险之后补的**（反馈闭环在起作用）。
- **[spec/pitfalls.md](spec/pitfalls.md)** —— 三行坑账；注意那条 `修订:03-13` 的就地改写。
- **[docs/decisions/001](docs/decisions/001-幂等键胜过分布式锁.md)** —— 退款为什么用幂等键，把被否的 Redis 锁方案连原因一起写下来，挡住下一个再提的人。

注意**缺席**了什么：没有 `scratch/` 内容（真实仓库里 gitignore，调试垃圾随任务消亡），也没有任何仪式。整条留痕约 150 行 markdown。

> 全部为合成数据：公司、供应商、金额、时间、案件/订单号均为虚构，不对应任何真实系统。
