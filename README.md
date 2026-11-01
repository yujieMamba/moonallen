# MoonAllen

MoonBit 原生的**定性时间区间约束推理库**，模块 `yujieMamba/moonallen@0.1.1`。

当系统只知道“阶段 A 在 B 之前或与 B 相接”“标注 C 与 D 重叠”而没有精确时间戳时，MoonAllen 将这些关系作为可组合的约束，进行传播、有限搜索、见证校验和冲突解释。它不是日历、预约排程器或通用 SMT 求解器。

## 安装与最小集成

```sh
moon add yujieMamba/moonallen@0.1.1
```

在消费包的 `moon.pkg` 中导入：

```moonbit
import {
  "yujieMamba/moonallen" @allen,
}
```

业务函数可以这样使用（调用方处理 `AllenError`）：

```moonbit
fn validate() -> @allen.SolveReport raise @allen.AllenError {
  let alg = @allen.Algebra::new()
  let net = @allen.Network::new(["ingest", "publish"])
    .restrict("ingest", "publish", @allen.parse_relset("b|m"))
  @allen.solve(alg, net, @allen.SearchOptions::new())
}
```

调用方应保留 `SolveOutcome` 的三个分支：可满足时校验见证，不可满足时处理冲突，未知时单独处理预算不足。完整的独立消费包位于 `examples/`，均通过公开 API 使用库，并带运行时断言。

## 三个完整工作流

```sh
moon run examples/workflow     # 相对阶段输入 -> 推理见证 -> 错误回边的可验证冲突核
moon run examples/annotation   # 不确定事件标注 -> 精确可能关系 -> 蕴含反例
moon run examples/media        # 具体区间观测 -> 策略检查/合并 -> JSON 和 DOT 报告
```

- **工作流开发者**：输入 ingest/validate/publish 的关系析取，传播后检验推导；为正常流程生成端点见证，对回边输出原始标签冲突核。
- **事件标注工具作者**：输入 speech/gesture/response 的不确定关系，逐原子查询可能性；每个可行关系有独立见证，并用反例否定过强标注。
- **媒体编辑和质检系统**：从合成数值片段导入定性观测，与 caption-contained 等策略合并；正常片段交换快照，越界片段定位冲突。示例不包含第三方媒体或个人数据。

## 关系与语义

所有区间都是满足 `start < end` 的 proper intervals。坐标是整数序关系，不是闭/开区间交集或持续时间计算；相等端点按 Meets 区分。

| token | Relation | A 相对 B |
|---|---|---|
| b / bi | Before / After | 严格在前 / 在后 |
| m / mi | Meets / MetBy | 尾首相接 / 被相接 |
| o / oi | Overlaps / OverlappedBy | 从前方重叠 / 从后方重叠 |
| s / si | Starts / StartedBy | 同起点，A 更短 / 更长 |
| d / di | During / Contains | 严格包含于 / 严格包含 |
| f / fi | Finishes / FinishedBy | 同终点，A 更短 / 更长 |
| eq | Equal | 两端点都相等 |

`b|m` 表示**备选关系**，不是同时成立。`*` 为全部 13 个关系，`-` 为空集（明确矛盾）。重复约束取交集，逆向边自动保持 converse，对角线只允许 eq。冲突保留为空域，而非静默丢弃证据。`Interval::relate` 不做整数减法，可处理 Int 两端极值。

## API 导航

正式签名见 `pkg.generated.mbti`。

| API | 行为 |
|---|---|
| `Relation`, `RelSet`, `Algebra` | 13 关系、位集运算、converse、精确 composition |
| `Network::new/restrict/get` | 不可变命名网络，源证据与当前域分离 |
| `propagate`, `verify_trace` | 有预算路径一致性传播、完整缩减轨迹重放 |
| `solve`, `realize_atomic` | MRV 原子场景搜索；端点等式合并和严格序 DAG 实现 |
| `possible_relations`, `entails` | 可行/不可行/未知三分区；非空前提的蕴含及反例 |
| `explain_unsat`, `verify_core` | 源证据上的删除式 UNSAT 核、独立再验证 |
| `observe`, `check_observations`, `add_observations` | 数值区间到定性观测、部分观测核对 |
| `merge_networks`, `compare_domains` | 按名称合并当前矩阵、域变化统计 |
| `induced`, `rename`, `components` | 诱导子矩阵、重命名、独立分量 |
| `parse_dsl`, `parse_network_json` | 有界数据交换；快照与原始证据分别导出 |
| `render`, `to_dot`, `to_json` | 稳定可读报告、图和机器可读诊断 |

### 保证与不能推导的结论

- `PathConsistent` **不是** SAT 证明；一般 Allen 析取约束不能只靠路径一致性完整判定。
- `Satisfiable(w)` 包含可由 `w.satisfies(net)` 检查的具体序关系见证。见证坐标是端点秩，**不能解读为实际时长或日程**。
- `Unsatisfiable` 来自空域、原子端点不可实现或完整分支排除。节点/操作预算不足返回 `Unknown`，不冒充 UNSAT。
- `entails` 先确认前提可满足，矛盾前提返回 `InconsistentInput`，不作空真承诺。
- 冲突核是原始 sources 的不可满足子集；`minimal=true` 仅表示删除任意一条后不再不可满足，**不是最小条数**。输入为闭包时，核解释的是其原始 sources，而非假设独立来源的推导边。
- `induced` 只是保留当前两两域，不是完整的存在量词消去。
- `verify_trace` 拒绝截断日志；它验证域缩减及状态，不认证公共报告中任意附加计数或冲突标签。

## 格式与预算

DSL：空行及整行 `#` 注释；空格/制表符分词；允许先引用后声明。

```text
interval a
interval b
rel a b b|m input-ready
```

名称以及可选 DSL 标签：1–128 个 ASCII 字符 `[A-Za-z0-9_.-]`。没有标签时自动采用行号标签。JSON 标签允许任意 Unicode（最长 256 个 UTF-16 单元）。格式详见 [docs/formats.md](docs/formats.md)。

硬限制：64 个命名区间，4,096 条 sources，精确搜索最多 24 个区间；文本输入最多 1,048,576 个 UTF-16 单元，DSL 最多 10,000 行，JSON 嵌套最多 16 层。负值或过大预算抛出 `AllenError`。默认每次搜索 10,000 节点/1,000,000 次传播操作，每次传播至多记录 10,000 次缩减。最大允许预算为 1,000,000 节点/10,000,000 次操作/1,000,000 条轨迹。

预算是逻辑工作量，不是毫秒或内存配额。关系可能性查询为**每个 atom 独立**分配预算；蕴含最多两次搜索，核提取为每次删除检查独立预算。服务端应在外部再加请求超时和并发限额。复杂度与语义论证见 [docs/architecture.md](docs/architecture.md)，安全限制见 [SECURITY.md](SECURITY.md)。

## 验证

发布验证工具链：moon 0.1.20261028 / moonc v0.10.18+6c83a7f62（2026-10-28），满足验收要求 moonc ≥ 0.10.16。使用 `Int32` 和当前 JSON 转换语法；不承诺旧编译器兼容。

```sh
moon info && moon fmt
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon build --deny-warn
# 针对 wasm-gc、wasm、js、native 重复严格检查、构建、测试和三个示例
moon test --target js --deny-warn
```

测试包括全部 8,192 关系位集往返、169 composition 项的代数律、全部 2,197 个三节点原子网络与 256 个析取网络的独立端点穷举对照，以及畸形输入、资源上界、空网络、轨迹伪造、Unknown、冲突核和交换边界回归。所有数据和 oracle 由项目本身构造，不依赖网络或商业求解器。

本机 wasm-gc/wasm/js 的检查、构建、49 个测试及三个示例均通过。native 严格类型检查通过；本机缺少 cc/gcc/clang，原生构建与执行由 Linux CI 实测。CI 在干净 Ubuntu runner 安装官方工具链，记录版本，执行全部四个目标。工程规模可运行 `python scripts/audit.py` 复算；不把示例、测试或生成接口计入生产行数，不宣称性能优于其他求解器或完整外部认证。

## 来源、许可与交付

原创实现，Apache-2.0；无第三方 MoonCakes 依赖（仅标准 core）。Allen 理论参考、实现来源边界和相邻项目差异见 [ATTRIBUTION.md](ATTRIBUTION.md)、[docs/competition/duplicate-check.md](docs/competition/duplicate-check.md)。AI 辅助范围见 [AI-USE.md](AI-USE.md)。

本仓库不包含比赛申报书、私人联系资料、认证令牌或自动报名功能。比赛资格与验收由组织方最终决定。

