# 协议仿真 (veydeck.protocol-simulation)

`veydeck.protocol-simulation` 用于通过具名 TCP/UDP 端点的受控工作负载部署协议仿真实例，并查看实例状态、结构化审计事件和整实例 PCAP。当前支持 HTTP、Redis、SMTP、POP3、IMAP、SSH、FTP、RDP、Telnet、MySQL、PostgreSQL、SMB、LDAP、DNS、MongoDB、Memcached、SNMP、MQTT 和 VNC；DNS 同时提供 TCP 与 UDP 端点，SNMP 使用 UDP 端点。

源码由 `veydeck-suite-protocol-simulation` 独立维护，本目录只保存套件交付文件和固定版本镜像引用。

## 镜像

- `veydeck/protocol-simulation:0.1.0-alpha.2`
- `veydeck/protocol-simulation-engine:0.1.0-alpha.2`

API/UI 镜像和 engine workload 镜像分别由独立 crate 构建并单独发布版本。当前套件与两个镜像引用统一为 `0.1.0-alpha.2`，功能变更记录在 `CHANGELOG.md` 的对应版本中；安装前需确认两个镜像均已发布或加载至部署节点。

交付时以下引用必须一致：

| 位置 | 引用 |
| --- | --- |
| `compose.yaml` 的服务 `image` | `veydeck/protocol-simulation:0.1.0-alpha.2` |
| `compose.yaml` 的 `VEYDECK_SIM_ENGINE_IMAGE` | `veydeck/protocol-simulation-engine:0.1.0-alpha.2` |
| `suite.yaml` 的 `runtime.images` | `veydeck/protocol-simulation-engine:0.1.0-alpha.2` |

Agent 只允许部署清单白名单中的 engine 镜像。API/UI 与 engine 应同步更新，以保持配置表单、导入校验和实际协议响应一致。

## 服务身份与能力边界

Banner 按协议体现为欢迎语、握手版本、查询返回的身份或能力信息；不是所有协议都会在连接后主动发送文本，也不是所有协议都公开产品版本。

- SMTP、POP3、IMAP、FTP 的欢迎语配置只填写正文，协议状态前缀和换行由引擎添加。SSH 使用完整版本行；Telnet 使用单行欢迎语，由引擎处理协商与换行。
- HTTP 普通响应和自定义路径响应使用一致的 Server 标头。Redis 通过原生 INFO 返回版本，启用认证时需先 AUTH，不主动发送欢迎语；Memcached 的 VERSION 与 STATS 返回一致版本。
- SMB 支持 SMB 2.0.2/2.1 协商及返回服务器名、域名的 NTLM challenge；不提供真实共享或认证会话。
- LDAP 提供 LDAPv3 匿名绑定和 RootDSE 搜索，返回命名上下文、厂商名称与版本；不提供具名认证或目录条目。
- DNS 在 TCP/UDP 上响应 A 查询，并通过 `version.bind`、`id.server` 的 CHAOS TXT 查询返回版本与服务器名。
- RDP 提供 X.224 标准安全协商并拒绝不支持的 TLS/NLA 请求，不提供口令认证或桌面会话。SSH、VNC 也以识别所需的版本交换或安全握手为边界。
- MySQL、PostgreSQL、MongoDB、Memcached、SNMP、MQTT 和 VNC 按协议提供版本、服务描述或能力响应，不提供完整数据库、缓存、消息代理或远程桌面实现。PostgreSQL 的精确版本需认证后查询；MQTT/RFB 协议版本不等于产品版本。

源码仓库 `veydeck-suite-protocol-simulation` 中的 `docs/protocol-discovery.md` 提供 19 种协议的客户端/Nmap 验收矩阵与复测命令。非常规映射端口的穷举探测可能耗时数分钟。

## 配套规则与更新

规则资产由 `veydeck-sim-rules` 维护，通过 `.vprp` 导入套件 API，与本仓库生成的 `.vsp` 套件包独立交付。

当前规则直接使用新的行为配置：Redis 不再使用 `banner` 或覆盖 AUTH/INFO 等原生命令；RDP 配置为 `{}`；SMB 不使用 `shares`；LDAP 不使用 `credentials`、`entries`，改为 RootDSE 身份字段；DNS 显式配置版本和服务器名。旧字段不做兼容转换。

实际更新部署时：

1. 从源码仓库构建并推送 API/UI、engine 两个镜像，按交付清单核对镜像引用。
2. 在各部署节点拉取更新后的镜像，并重建套件 API/UI 服务。
3. 导入已同步配置契约的规则包，替换规则中的旧字段。
4. 下线并重新部署已有仿真实例，使它们使用新的 engine 和规则配置。

推送镜像、修改 Compose 或重启 API 不会自动替换已经运行的仿真实例。重新打包 `.vsp` 也不会构建或推送镜像。

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
