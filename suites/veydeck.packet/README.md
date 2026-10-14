# 流量解析 (veydeck.packet)

本套件是用于 PCAP 流量文件解析、在线协议字段分析、网络流量多维统计以及可视化自定义数据包构造与导出的 Veydeck Compose 套件。

## 核心功能

1. **PCAP 流量文件上传与解析**：支持流式解析大文件（最大 20 万数据包），避免内存溢出，以高吞吐量写入 SQLite。
2. **多维流量统计**：提供协议分布统计、TOP 源与目的 IP 统计、TOP 端口分布等 ECharts 可视化图表。
3. **数据包详细信息展示**：双栏布局，以树状形式逐层展开 TCP/IP 各层字段，并配以十六进制 + ASCII 对齐显示。
4. **可视化数据包构造与修改**：
   - 提供 TCP SYN/ACK, UDP, ICMP Echo, DNS Query 等多种常用数据包模板。
   - 提供白名单机制下的 Layer 字段编辑器。
   - 修改已有包时置空 checksum 与 len 促使 Scapy 重构，保证包合法。
   - 支持批量构造、一键打包导出 PCAP。

## 配置与数据持久化

- 数据持久化：全部数据库及上传/生成的 PCAP 存储在容器内 `/data` 目录中。请在宿主机挂载持久化卷以保存数据。
- 默认端口：容器内使用 `8080` 端口。无需手动暴露，Veydeck 代理层将自动对其进行反向代理。

后端服务声明 `operation-logs.write`，用于记录 PCAP 上传、解析终态、删除和构建操作；实例令牌不会暴露给前端。

## 开发与打包

源码由 `veydeck-suite-packet` 独立维护，本仓库只保存套件交付目录和 `.vsp` 发布产物。

```bash
cd ../veydeck-suite-packet
./build-image.sh 0.1.0-alpha.1

cd ../veydeck-suites
./scripts/package.sh suites/veydeck.packet
```

说明：

- `frontend/dist` 由源码仓库前端构建生成，Dockerfile 会将其拷贝为容器内静态资源。
- 套件包后缀使用 `.vsp`，由 `scripts/package.sh` 生成。
