# 协议仿真 (veydeck.protocol-simulation)

`veydeck.protocol-simulation` 用于通过具名 TCP/UDP 端点的受控工作负载部署协议仿真实例，并查看实例状态、结构化审计事件和整实例 PCAP。当前支持 HTTP、Redis、SMTP、POP3、IMAP、SSH、FTP、RDP、Telnet、MySQL、PostgreSQL、SMB、LDAP、DNS、MongoDB、Memcached、SNMP、MQTT 和 VNC；DNS 同时提供 TCP 与 UDP 端点，SNMP 使用 UDP 端点。

源码由 `veydeck-suite-protocol-simulation` 独立维护，本目录只保存套件交付文件和固定版本镜像引用。

## 镜像

- `veydeck/protocol-simulation:0.1.0-alpha.1`
- `veydeck/protocol-simulation-engine:0.1.0-alpha.1`

API/UI 镜像和 engine workload 镜像分别由独立 crate 构建并单独发布版本。

## 打包

```bash
./scripts/package.sh suites/veydeck.protocol-simulation
```

## 交付内容

- `suite.yaml`：套件清单。
- `compose.yaml`：套件 API/UI 服务部署规则。
- `.env.example`：本地打包校验使用的 Compose 变量示例。
- `assets/suite-icon.png`：256×256 透明 PNG 套件图标。

清单声明 `workloads.manage`、`captures.manage` 和 `operation-logs.write`，并把 engine 镜像列入运行时白名单。Veydeck 安装器会为 API 服务生成实例隔离的 Agent 运行时挂载；交付 Compose 不包含节点模式判断。工作负载 API 使用 v1 多端点契约，抓包覆盖该工作负载的全部公开端点。
