# Changelog

## [Unreleased]

### Changed

- 移除套件清单中的 `apiVersion` 固定值要求，按平台运行契约和最低平台版本校验兼容性。
- 套件所有服务统一由 Agent 协调启动与恢复，停用后不会随 Docker 自动启动。

## [0.1.0-alpha.1] - 2026-10-13

### Added

- 创建 Veydeck 主机扫描套件全新仓库。
- 支持 `/24` 至 `/32` IPv4 CIDR、ICMP 存活探测、TCP 端口探测与 Banner 服务识别。
- 提供实时扫描状态、任务历史、开放及关闭端口和服务指纹报告。
- 支持取消运行中的扫描，并在服务重启后正确终结中断任务。
- 提供基于 Veydeck UI、VDL Token 与 Suite Runtime SDK 的 Vue 3 界面和语义操作日志。
- 提供 `veydeck/host-scanner:0.1.0-alpha.1` Docker 镜像构建与手动发布流程。
