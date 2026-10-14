# Veydeck Suites

`veydeck-suites` 是 Veydeck Compose 套件版本库，用于维护已发布套件的交付目录并生成 `.vsp` 套件包。

Veydeck 是一个可扩展的分布式 Linux 主机运维平台，用于统一管理一台或多台 Linux 主机，并支持通过套件按需扩展平台能力。

套件源码由独立仓库维护，本仓库不保存应用源码，也不构建 Docker 镜像。

## 目录结构

```text
veydeck-suites/
├── scripts/    # 套件打包脚本
├── suites/     # 套件交付目录
└── dist/   # 生成的 .vsp 包
```

交付目录：

```text
suites/<suiteId>/
```

## 当前套件

| 套件 | 分类 | 说明 |
| --- | --- | --- |
| `veydeck.host-scanner` | `tools` | 网段主机扫描和常用端口探测。 |
| `veydeck.packet` | `tools` | PCAP 流量解析、统计展示和数据包构造。 |
| `veydeck.protocol-simulation` | `tools` | 通过受控规则容器部署协议仿真实例，并查看状态与审计事件。 |

## 套件包

套件交付包使用 `.vsp` 后缀，内部仍是 gzip 压缩的 tar 归档。交付包根目录必须包含：

```text
suite.yaml
compose.yaml
README.md
```

推荐同时包含：

```text
.env.example
assets/suite-icon.png
CHANGELOG.md
```

`suite.yaml` 中的 `metadata.icon` 必须指向真实存在的 PNG 图标。套件图标统一使用 `assets/suite-icon.png`。

`suite.yaml` 必须通过 `compatibility.platformContractVersion` 声明平台运行契约版本。当前首个契约版本为 `1`：

```yaml
compatibility:
  platformContractVersion: 1
```

## 打包

打包单个套件：

```bash
./scripts/package.sh suites/veydeck.host-scanner
```

打包全部套件：

```bash
./scripts/package-all.sh
```

## 发布

`.vsp` 套件包通过 `Publish Suite Packages` workflow 发布到 GitHub Release。

发布标签按套件独立生成：

```text
<suiteId>-<version>
```

示例：

```text
veydeck.host-scanner-0.1.0-alpha.1
veydeck.packet-0.1.0-alpha.1
veydeck.protocol-simulation-0.1.0-alpha.1
```

## 源码仓库

| 套件 | 源码仓库 | 镜像 |
| --- | --- | --- |
| `veydeck.host-scanner` | `veydeck-suite-host-scanner` | `veydeck/host-scanner` |
| `veydeck.packet` | `veydeck-suite-packet` | `veydeck/packet` |
| `veydeck.protocol-simulation` | `veydeck-suite-protocol-simulation` | `veydeck/protocol-simulation`, `veydeck/protocol-simulation-engine` |

Docker 镜像由各套件源码仓库构建和发布。本仓库只在 `compose.yaml` 中引用已发布的固定版本镜像。

套件版本只以 `suite.yaml` 中的 `metadata.version` 为准。镜像标签是套件交付内容的一部分，任一引用镜像版本变化时，应同步更新套件版本并发布新的 Git tag / GitHub Release。

## 版本日志

每个套件的版本日志由对应源码仓库维护，本仓库只保存发布时同步过来的交付快照：

```text
suites/<suiteId>/CHANGELOG.md
```

仓库根目录的 `CHANGELOG.md` 只记录套件交付仓库自身的目录结构、脚本、workflow 和规范变化，不记录具体套件功能变更。

## 规范

1. 套件 ID 发布后不得修改。
2. 镜像必须固定版本标签，不使用 `latest`。
3. 交付包不包含套件源码目录。
4. 发布套件时必须同步对应源码仓库的 `CHANGELOG.md` 到套件交付目录。
5. Web 入口通过 `veydeck-suite-network` 和 Veydeck 代理访问。
6. 套件建议使用 VDL Token 和 Veydeck UI 组件保持视觉一致。必须遵守套件清单、权限、代理路径和安全约束。
7. 套件必须声明正整数平台运行契约版本，并确保该版本受到目标 Veydeck 版本支持。

## Agent Runtime 能力

套件后端在 `runtime.agent.capabilities` 中声明最小能力：

| 能力 | 用途 |
| --- | --- |
| `workloads.manage` | 管理当前套件实例拥有的受控工作负载。 |
| `captures.manage` | 管理当前套件工作负载的抓包任务。 |
| `operation-logs.write` | 向平台提交关键业务操作及终态事件。 |

`operation-logs.write` 只允许后端服务使用。Agent 根据实例令牌确定 suite ID、instance ID 和节点来源；套件不得声明平台用户名，也不得上报密码、令牌、命令、环境变量或业务内容正文。查询、进度和界面偏好不进入操作日志。
