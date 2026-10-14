# 选题、语义查重与发布前复核

日期：2026-10-14。目标赛事按 moonbit-hackathon-builder 固定“新生态项目建设”要求执行；检索流程使用已安装 `osc2026-guide` 的 Project Research Guide，不把其 August/OSC 入口规则替换本次规则。本文件是公开工程证据摘要，不是申报书或组织方查重结论。

## 方法与实际检索范围

按任务/算法/格式而非仅项目名展开：`allen`, `Allen algebra`, `interval algebra`, `qualitative`, `temporal`, `interval`, `path consistency`, `composition`, `STN`, `STNU`, `rcc8`, `causal`, `clock`；三个替代领域还检索 `egraph`, `rewriting`, `datalog`, `dbf`, `dbase`, `shapefile`, `mincost`, `min-cost`。MoonCakes 执行 `moon search KEYWORD --limit 80` 或 `--limit 100`，阅读相关包精确版本公开 manifest、README、接口及实际源码/测试；搜索为相关性匹配，不能把无关命中当能力重叠。

- `allen` 返回 6 个模块，`interval algebra` 返回 15 个模块，`qualitative` 返回 2 个模块；分别是响应中报告的模块数，不代表逐一完整人工审查。核心返回是 signals、符号数学等词法邻近，未提供所需区间关系网络流程。
- GitHub 仓库检索 `allen language:MoonBit`、`temporal constraint language:MoonBit`、`"interval algebra" MoonBit` 返回 0；代码反向检索 `"path_consistency" language:MoonBit`、`"interval_algebra" language:MoonBit`、`qualitative temporal language:MoonBit` 返回 0。泛词 `Allen` 有 676 条，只看前 100 条，不能据此断言全站唯一。
- 阅读官方 [awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit) 列表：核对 time/graph/temporal/constraint 等相邻条目；图算法不等于 Allen 约束求解。它是人工维护的非完整生态列表。
- GitHub 赛事相关仓库查询 `moonbit hackathon 2026` 返回 18 个仓库摘要；含时序变换 moonts、排班 RosterWeave 等，任务分别为数值序列/资源公平分配，不是关系代数推理。查看 [官方 Hackathon2026](https://github.com/moonbitlang/Hackathon2026) 的完整 main 树（前端网站），没有把该树当作完整参赛名单。未声称逐一克隆全部参赛仓库。
- 阅读永久项目注册表的相关完整指纹（含完成、预留、拒绝和 external-checked）。实现前已在排他锁下重新读取并原子预留 MoonAllen；本次发布前再读，不能依赖旧快照。

原始搜索响应和下载的相邻源码仅用于本地研究，不随包复制；下面给出公开可复查的精确包和接口证据。搜索结果会变化、中文/非英文命名与私有未索引项目仍可能漏检；本报告只是记录范围内未发现成熟直接替代，不是唯一性保证。

## 不同领域候选与淘汰

| 候选 | 可复用工作流 | 实际重叠证据 | 决定 |
|---|---|---|---|
| 等式饱和 e-graph | rewrite -> equality saturation -> extraction | [CAIMEOX/moon_egg@0.1.0](https://mooncakes.io/docs/CAIMEOX/moon_egg) 的 `egraph.mbt`、`extract.mbt`、`math_test.mbt` 已覆盖核心流程；Apache-2.0 | 直接重合，淘汰；应扩展既有库而非换名重建 |
| DBF 读写与验证 | schema/bytes -> typed records -> write-back | [liyun6666/moon-shapefile@0.1.1](https://mooncakes.io/docs/liyun6666/moon-shapefile) 的 `dbf/reader.mbt`、`writer.mbt`、`reader_wbtest.mbt`、`validation_wbtest.mbt` 已含字段、记录和删除行；MIT | 直接重合，淘汰；DBF 已是其正式子包 |
| 最小费用流 | graph -> bounded flow/cost -> slope | [manabeai/ac-library-mbt@0.1.0](https://mooncakes.io/docs/manabeai/ac-library-mbt) 中 `McfGraph` 的 flow/slope 实现与接口；Apache-2.0 | 算法核心直接重合，淘汰 |
| MoonAllen | 相对区间关系 -> 闭包/搜索 -> 见证、反例或源冲突核 | 见相邻能力矩阵 | 通过有界语义检查，自动选定 |

选择评分（每项 0–5；是设计评估，不是实测性能）：MoonAllen 的三类下游复用 5、独立核心价值 5、可验证性 5、可交付规模 4、生态差异 4，总计 23/25。其余候选触发直接重复门禁，不以高分绕过。MoonAllen 不另造数据库/媒体服务，仅提供三个系统可共享的关系推理引擎。

## 相邻项目源码能力矩阵

| 精确版本与许可 | 实读证据 | 已有核心 | MoonAllen 是否重做 |
|---|---|---|---|
| [cauchyQ/moonbit-slotplan@0.1.0](https://github.com/cauchyQ/moonbit-slotplan), Apache-2.0 | `pkg.generated.mbti`, `interval.mbt`, `availability_overlay.mbt`, `batch.mbt`, `moonbit-slotplan_wbtest.mbt` | 数值区间可用性、周模板、预约资源分配、时间线布局 | 否；不提供预约/资源/周模板。相对区间不确定性、composition、场景 SAT 与反例并非其流程 |
| [yyyt0807/moonbitemporal@0.2.0](https://github.com/yyyt0807/moonbitemporal), Apache-2.0 | root interface 与账本/导出实现、examples | valid-time / knowledge-time 修订账本、时间窗比较与回溯 | 否；不保存修订/知识时间。来源标签只是约束解释，不是时间数据库 |
| [marianoguerra/temporal@0.1.1](https://github.com/marianoguerra/temporal), Apache-2.0 | calendar/instant/duration 实现和接口 | ECMAScript Temporal 日期、时区、时长 | 否；proper interval 只看序关系，不处理时区/历法/单位 |
| 永久 MoonRecur | 完整注册指纹 | RFC 5545 风格递推求值、civil-calendar occurrence | 否；不解析/展开重复规则 |
| 永久 MoonDag | 完整注册指纹 | DAG/CPM 数值依赖与工期分析 | 否；不用 DAG 工期优化。内部严格端点 DAG 是原子关系可实现性检查，不对业务任务计算关键路径 |
| 永久 MoonConcept / MoonQP | 完整注册指纹 | 形式概念格 / 数值凸优化（MoonQP 后续通用范围查重结论已撤回，未作为通过项目推荐） | 否；虽都有约束/闭包术语，不同模型和输出 |
| 永久 MoonWell | 完整注册指纹 | LAS 2.0 井深曲线校验、多测次深度对齐和来源拼接 | 否；不读取 LAS、重采样深度或拼接井曲线，interval 只是共用词汇 |

其他强制保留项目 MoonBench（运行时基准门禁）、MoonContract（HTTP/OpenAPI 契约）、MoonShard（内容定义分块与重建）在领域/输入/输出上也不同。没有因为改名字或改账号而忽略任何注册条目。

## 为什么独立项目而非扩展邻居

slotplan 接受已知数值区间并做资源预约；bitemporal 保存带时间的历史修订；Temporal 处理历法单位。MoonAllen 接受**未知端点的析取定性关系**，核心是 13 原子 composition、路径闭包、精确原子实现与预算化场景枚举。将它嵌入预约库或账本会把通用标注/媒体/工作流用户耦合到不需要的数据模型和依赖。独立无第三方依赖库可以由这些系统调用，但不宣称已完成具体第三方集成。

## 明确边界与发布复核

不做日期/时区/递推、预约资源、数值工期优化、账本存储、通用 SMT、性能跑分平台或安全认证。路径一致性不是完整 SAT；Unknown 不等于不可满足；见证不是实际排程。三种真实用户流程和 API 定义见 README 与 runnable examples。

发布前重复执行核心术语、公开代码反向检索和注册表重读；复核记录与结果保存在本地交付审计。若发现维护良好的直接替代或新冲突预留，不发布同题项目。当前判断受搜索索引、返回上限和相邻版本范围限制。


2026-10-14 发布前实查：MoonCakes llen 6、interval algebra 15、qualitative temporal 0、path consistency 21 个模块；复读返回的模块名、摘要及此前相邻源码证据，未新增直接同题实现。GitHub 三项仓库反查（allen language:MoonBit、interval algebra MoonBit、qualitative temporal MoonBit）及 realize_atomic language:MoonBit 代码反查均返回 0。已重新读取当前注册表的 MoonAllen 完整预留指纹和时序/约束相邻记录，没有发现新直接冲突。上述均为有返回上限和索引局限的记录，不是全生态不存在证明。
