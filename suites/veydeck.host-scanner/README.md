# 主机扫描套件

`veydeck.host-scanner` 用于快速扫描指定 IPv4 网段，发现在线主机并查看常见端口的响应情况，适合用于资产发现和网络连通性确认。

## 功能

- 扫描 `/24` 至 `/32` IPv4 CIDR 网段。
- 支持 TCP 端口探测、Banner 服务指纹识别和 ICMP 存活探测。
- 实时展示空闲、扫描中、存活、开放端口和无响应状态。
- 保存历史任务、开放端口和服务指纹报告。
- 展示容器网络模式、容器 IP 和 `NET_RAW` 能力状态。

## 交付资源

- `assets/suite-icon.png`：256×256 透明 PNG 套件 logo，用于套件中心和应用库展示。

## 国际化

`suite.yaml` 默认文案使用中文，并通过 `i18n.locales.en-US` 提供英文名称、摘要和应用入口标题。套件运行界面已接入 `@veydeck/suite-sdk` 的语言同步能力，主控语言切换后会同步更新套件内文案。

## 权限说明

后端服务声明 `operation-logs.write`，用于记录扫描提交、终态和删除操作。运行时身份与令牌由 Veydeck 安装器按实例注入。

本套件需要执行 ICMP 探测，因此 `compose.yaml` 显式声明：

```yaml
cap_add:
  - NET_RAW
```

该能力用于 ICMP ping。普通业务套件不应默认申请 `NET_RAW`，除非功能确实依赖原始网络报文能力。

## 构建镜像

```bash
cd ../veydeck-suite-host-scanner
./build-image.sh 0.1.0-alpha.1
```

源码由 `veydeck-suite-host-scanner` 独立维护，本仓库只保存套件交付目录和 `.vsp` 发布产物。

如果需要在其它节点启用该套件，请先推送镜像：

```bash
docker push veydeck/host-scanner:0.1.0-alpha.1
```

## 本地调试

```bash
docker network inspect veydeck-suite-network >/dev/null 2>&1 || docker network create veydeck-suite-network
docker compose -f compose.yaml config
docker compose -p veydeck-host-scanner -f compose.yaml up -d
docker compose -p veydeck-host-scanner -f compose.yaml logs --tail=100
docker compose -p veydeck-host-scanner -f compose.yaml down
```

## 打包

```bash
cd ../veydeck-suites
./scripts/package.sh suites/veydeck.host-scanner
```
