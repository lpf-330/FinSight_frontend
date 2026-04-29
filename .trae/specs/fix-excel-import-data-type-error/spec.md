# Excel导入页面数据类型错误修复 Spec

## Why
Excel导入页面打开时，浏览器控制台报错：
1. `Invalid prop: type check failed for prop "data". Expected Array, got Object`
2. `data2 is not iterable`
3. 多个 unhandled error 警告

问题原因是 `fetchImportHistory` 函数获取数据后，没有正确处理 API 返回的数据结构，导致 ElTable 组件接收到的 `data` prop 是一个对象而非数组。

## What Changes
- 修改 `fetchImportHistory` 函数，正确提取数组数据
- 增强数据类型校验，确保 `importHistory` 始终是数组

## Impact
- Affected code: `src/views/data/ExcelImport.vue`

## MODIFIED Requirements
### Requirement: fetchImportHistory 数据处理
API 可能返回多种数据结构格式（`{data: {list: []}}`、`{data: []}`、`[]`），代码应正确提取数组数据并做类型校验。

#### Scenario: 正常数据返回
- **WHEN** API 返回 `{data: {list: [...], total: 6}}` 或 `{data: [...]}` 或 `[]`
- **THEN** `importHistory` 被正确赋值为数组类型

#### Scenario: 异常数据返回
- **WHEN** API 返回非数组数据或请求失败
- **THEN** `importHistory` 被赋值为空数组 `[]`
