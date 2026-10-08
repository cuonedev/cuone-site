---
title: 多个 AI Agent 的 MCP 本机与局域网协作实践
date: 2026-09-30
authors: [cuone]
categories: ["AI 协作"]
tags: [Agent, MCP]
series: AI 协作实践
comments: false
toc: true
---

借助开源项目 `cross-agent-teams-mcp`，多个 AI Agent 可以通过 MCP 接入同一个通信服务，在本机或不同设备之间注册身份、发送消息并查看收件箱。本文以 Codex 和 OpenCode 为例，整理项目的安装配置与使用步骤：先配置本机通信，再扩展到局域网中的另一台设备。

下文命令固定使用 `cross-agent-teams-mcp@0.8.6`，便于复现。Agent 配置格式还会受 Codex、OpenCode 版本影响，实际操作前应核对各工具的最新文档。

示例中，设备 A 运行 MCP daemon 和本机 Agent，设备 B 运行远端 Agent。跨设备连接需要局域网互通并配置 daemon token。项目目前使用共享 token，且未提供 TLS 和逐 Agent 鉴权，因此只适合可信局域网内使用，不要将服务直接暴露到公网。

![Codex 和 OpenCode 通过本机 MCP 服务发送消息并从收件箱读取]({{ '/assets/images/posts/02-本机MCP消息链路.png' | relative_url }})

## 一、准备环境

在设备 A 和设备 B 上分别确认 Node.js、npm 及要使用的 Agent 已安装。打开终端检查：

```bash
node --version
npm --version
```

本文以设备 A 的局域网地址 `10.0.0.10` 为例，实际操作时替换成设备 A 的地址。两台设备需要处于可以互相访问的局域网，并允许设备 B 连接设备 A 的 TCP `9100` 端口。

准备一个高强度随机 token，供 daemon 和所有 Agent 配置共同使用。不要把 token 提交到项目文件或公开仓库；下文用环境变量 `XATS_TOKEN` 表示该值。

## 二、启动 MCP 服务

### 本机使用

在设备 A 的终端启动 daemon，并保持进程运行：

```bash
npx -y cross-agent-teams-mcp@0.8.6 daemon --device host-a --port 9100
```

服务默认监听 `127.0.0.1:9100`，只接受本机连接。在另一个终端检查健康状态：

```powershell
Invoke-RestMethod -Uri 'http://127.0.0.1:9100/health'
```

正常情况下，返回 JSON 中 `ok` 为 `true`。若检查失败，确认 daemon 仍在运行、端口没有被占用，再查看启动错误。

### 开启局域网访问

本机使用时 daemon 只监听回环地址。要让设备 B 接入，先停止原 daemon，在设备 A 设置 token 后重新启动。以下命令适用于 PowerShell：

```powershell
$env:XATS_TOKEN = '替换为你生成的高强度随机值'
npx -y cross-agent-teams-mcp@0.8.6 daemon --host 0.0.0.0 --port 9100 --token $env:XATS_TOKEN --device host-a
```

`--host 0.0.0.0` 会监听设备 A 的所有网络接口。项目要求非 loopback 监听必须提供 `--token`，缺少 token 时 daemon 会拒绝启动。若需要限制监听范围，可将 `0.0.0.0` 换成设备 A 的局域网 IP。

在设备 B 上检查是否能访问 daemon：

```powershell
Invoke-RestMethod -Uri 'http://10.0.0.10:9100/health'
```

如果访问失败，检查 IP 是否正确、两台设备是否处于可互通的局域网、系统防火墙是否允许 TCP `9100`，以及 daemon 是否正在运行。只开放验证所需端口，不要关闭整个防火墙。

## 三、配置本机 Agent

启用 token 后，本机请求也必须带上凭据。设备 A 上的 Codex 和 OpenCode 都配置为连接 `127.0.0.1`。

### Codex

在 Codex 配置文件 `~/.codex/config.toml` 中加入：

```toml
experimental_use_rmcp_client = true

[mcp_servers.cross-agent-teams-mcp]
type = "streamable-http"
url = "http://127.0.0.1:9100/mcp"
bearer_token_env_var = "XATS_TOKEN"
```

`experimental_use_rmcp_client = true` 必须位于 TOML 顶层。启动 Codex 的终端需要先设置 `XATS_TOKEN`；PowerShell 示例：

```powershell
$env:XATS_TOKEN = '替换为设备 A 上 daemon 使用的同一个 token'
```

### OpenCode

在 `~/.config/opencode/opencode.json` 的 `mcp` 对象中加入：

```json
{
  "mcp": {
    "cross-agent-teams-mcp": {
      "type": "remote",
      "url": "http://127.0.0.1:9100/mcp",
      "headers": {
        "Authorization": "Bearer 替换为设备A上daemon使用的同一个token"
      }
    }
  }
}
```

OpenCode 示例将 token 写在 MCP 请求头中。不要把含有真实 token 的配置文件提交到仓库；跨设备配置也应妥善保管。

如果文件已有其他 MCP 配置，只合并 `cross-agent-teams-mcp` 这一项。配置完成后重启 Codex 和 OpenCode，并确认它们都能看到项目提供的注册、发消息和查看收件箱工具。Codex 配置细节可参考项目的 [Codex CLI 配置说明](https://github.com/jtianling/cross-agent-teams-mcp/blob/main/docs/configs/codex-cli.md)。

## 四、本机 Agent 收发消息

在 Codex 会话中注册发送方：

```text
Register me to xats as planner on team local-demo, device host-a.
```

在 OpenCode 会话中注册接收方：

```text
Register me to xats as coder on team local-demo, device host-a.
```

在 `planner` 会话中发送消息：

```text
Send coder a message: 本机消息已收到，请回复“本机消息往返正常”。
```

在 `coder` 会话中查看收件箱并回复：

```text
What's in my inbox?
```

```text
Send planner a message: 本机消息往返正常。
```

最后回到 `planner` 查看收件箱，即完成一次本机消息往返。项目也支持向 team 或 role 广播，可在点对点消息正常后按需使用。

## 五、接入局域网中的另一台设备

在设备 B 上配置 Agent，将 MCP 地址改为设备 A 的局域网地址，并使用相同 token。跨设备注册需要提供设备标签；本文使用 `host-b`。设备标签加入 Agent 身份后，同一个 team 中不同设备上的同名 Agent 也能区分。

### 远端 Codex

在设备 B 的 `~/.codex/config.toml` 中配置：

```toml
experimental_use_rmcp_client = true

[mcp_servers.cross-agent-teams-mcp]
type = "streamable-http"
url = "http://10.0.0.10:9100/mcp"
bearer_token_env_var = "XATS_TOKEN"
```

启动 Codex 的终端设置与设备 A daemon 相同的 token：

```powershell
$env:XATS_TOKEN = '替换为设备 A 上 daemon 使用的同一个 token'
```

### 远端 OpenCode

在设备 B 的 `~/.config/opencode/opencode.json` 中，将服务地址改为设备 A 的局域网地址，并加入相同 token：

```json
{
  "mcp": {
    "cross-agent-teams-mcp": {
      "type": "remote",
      "url": "http://10.0.0.10:9100/mcp",
      "headers": {
        "Authorization": "Bearer 替换为设备A上daemon使用的同一个token"
      }
    }
  }
}
```

保存后重启对应 Agent，确认 MCP 工具正常加载。设备 A 上的 Agent 仍需保留带 token 的本机配置，因为 daemon 启用 token 后，本机请求同样需要认证。

## 六、跨设备收发消息

在设备 B 的 Agent 会话中注册远端身份：

```text
Register me to xats as reviewer on team local-demo, device host-b.
```

在设备 A 的 Agent 会话中，明确指定设备标签发送消息：

```text
Send reviewer:host-b a message: 局域网消息已收到，请回复“跨设备消息往返正常”。
```

在设备 B 的 `reviewer` 会话中查看收件箱并回复。跨设备寻址形式为 `Agent名称:设备标签`；裸 Agent 名称默认在调用者自己的 device 范围内解析。需要回复其他设备上的 Agent 时，也使用 `发送方名称:发送方设备标签`。收到回复后，即完成一次跨设备消息往返。

如需查看团队中的 Agent，可让 Agent 调用项目提供的列表工具，并核对每条记录的 `device` 字段。

## 七、消息送达与主动唤醒

通过 MCP 发出消息后，接收方可以从收件箱读取；是否会自动开始处理，则取决于 Agent 宿主及相应唤醒配置。项目针对不同宿主提供不同方式，Codex 的主动唤醒涉及额外的 app-server 配置。消息进入收件箱不等于接收方已被自动唤醒。

若接收方没有自动响应，可先在该 Agent 会话中主动查看收件箱，确认消息链路正常，再按项目官方说明检查宿主的唤醒配置。这样可以把 MCP 接入问题与自动唤醒问题分开排查。

## 使用边界

`cross-agent-teams-mcp` 提供了本机和跨设备消息协作能力。实际使用需要运行 daemon，并为各 Agent 配置 MCP Client；跨设备时还需设置局域网地址、token 和设备标签。

跨设备模式采用共享 Bearer token，目前没有 TLS 和逐 Agent 鉴权，因此应限制在可信局域网内使用。使用过程中，可根据实际需要进一步配置广播、唤醒和协作流程，并留意凭据管理及消息过程追踪方面的需求。

## 官方资料

- [`cross-agent-teams-mcp@0.8.6` npm 版本页](https://www.npmjs.com/package/cross-agent-teams-mcp/v/0.8.6)
- [项目官方中文 README](https://github.com/jtianling/cross-agent-teams-mcp/blob/main/README.zh-CN.md)
- [Codex CLI 配置说明](https://github.com/jtianling/cross-agent-teams-mcp/blob/main/docs/configs/codex-cli.md)
- [OpenCode 配置说明](https://github.com/jtianling/cross-agent-teams-mcp/blob/main/docs/configs/opencode.md)
- [OpenCode 官方 MCP 配置文档](https://opencode.ai/docs/mcp-servers/)

> **使用提示：**项目持续更新，操作前请核对官方文档中的最新参数与配置路径。不同操作系统、Agent 版本和网络环境可能需要相应调整。
