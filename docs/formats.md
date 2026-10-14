# 数据交换与报告

## JSON v1 输入

```json
{"format":"moonallen/1","names":["a","b"],"constraints":[
  {"left":"a","right":"b","allowed":"b|m","label":"evidence"}
]}
```

三个顶层字段和每条 constraint 的四个字段全部必填。未知字段、错误类型、不支持的版本、未声明名称、重复名称、非法关系 token、过长标签都抛 `AllenError`。constraints 为累积交集，不是覆盖。空数组允许。`-` 允许表达已知矛盾。

文本入口 `parse_network_json` 在解析前检查 UTF-16 长度和括号深度（忽略字符串内括号并处理转义）。核心 JSON 解析器负责剩余 JSON 语法及 Unicode 验证。重复对象键采用 core 的最后一项覆盖语义；交换双方应保证键唯一。`network_from_json` 接收已分配的 Json 值，只检查 schema/网络规模；调用方负责 Json 值的外部解析预算。JSON 导出不承诺规范化字节签名或所有消费者的键排序规则。

## 两种不同导出

- `net.to_json()` / `net.to_dsl()`：**当前域快照**，自动生成 `snapshot` 来源标签。解码后矩阵相同，不保留原始来源身份。包括闭包推导和空对角域。
- `net.sources_json()`：**原始证据列表**，保留 Unicode 标签及重复来源。对传播结果解码会恢复输入的约束交集，而不是其闭包。

合并/诱导网络同样把当前矩阵物化为新证据，不将推导边冒充历史来源。`merge_networks` 按名称取并集、关系域取交集，名称数量和生成来源数仍受硬限制。`compare_domains` 允许不同位置顺序，但要求相同名称集合。

DSL 标签不支持引号/转义，整行注释之外没有行尾注释；需要空白、Unicode 或特殊符号来源标签时使用 JSON。DSL 的导出始终是域快照，不是逐字输入往返。

## 报告不是网络输入

`ClosureReport::to_json()` 包含 `status, operations, reduction_count, trace_complete, reductions, conflict, network`。状态分别是 `path-consistent`、`contradiction`、`unknown-operation-budget`。

`SolveReport::to_json()` 状态为 `satisfiable/unsatisfiable/unknown`，附节点/传播次数、最大深度、reason 以及见证（若有）。见证明确标记 `ordinal-not-duration`。这些诊断对象没有隐式网络解码；需要交换网络时取其中的 `network` 或调用网络导出。

DOT 仅输出白名单 ASCII 名称和库生成的关系 token，不插值原始标签。没有调用 Graphviz 的系统命令；渲染由消费者选择。文字/JSON 报告仍可能包含消费者输入的业务名称和标签，公开这些报告前应自行去敏。
