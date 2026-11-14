# Changelog

## [Unreleased]

## [0.1.0-alpha.2] - 2026-11-14

### Fixed

- 修复带尾部填充的抓包发送至数据包构造器时出现 Padding 未映射警告的问题，构造与导出保留填充字节，并避免将其计入业务负载。

### Added

- 支持从文件管理器导入抓包文件后自动选中新文件，解析完成后可直接查看数据包。

### Changed

- 移除套件清单中的 `apiVersion` 固定值要求，按平台运行契约和最低平台版本校验兼容性。
- 套件所有服务统一由 Agent 协调启动与恢复，停用后不会随 Docker 自动启动。

## [0.1.0-alpha.1] - 2026-10-13

### Added

- 创建 Veydeck 流量解析套件全新仓库。
- 支持 PCAP 流式上传、协议字段与十六进制检查、流量统计和 TCP 会话追踪。
- 支持 TLS/SSL、SSH、FTP、MQTT、HTTP/2 等协议识别与关键字段解析。
- 提供可视化数据包构造、实时预览、校验、修改及 PCAP 导出能力。
- 提供基于 Veydeck UI、VDL Token 与 Suite Runtime SDK 的 React 界面和语义操作日志。
- 提供 `veydeck/packet:0.1.0-alpha.1` Docker 镜像构建与手动发布流程。
