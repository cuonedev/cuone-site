---
title: 跨 Agent 如何协作开发？
date: 2026-09-29
authors: [cuone]
categories: ["AI 协作"]
tags: [Agent, MCP]
series: AI 协作实践
series_url: /blog/series/ai-agent-collaboration/
project: cuo-aiteams
project_title: AI Agent 协作
project_url: /projects/cuo-aiteams/
permalink: /blog/multiple-ai-agents-how-to-collaborate/
---

在 AI 辅助开发过程中，模型会根据任务特点选择。方案分析、代码实现和审查对模型能力的侧重不同，调用成本也有差异。实际开发中会同时使用 Codex、OpenCode 等编码 Agent；它们在模型接入、交互方式和子 Agent 能力上各有特点，也已融入现有工作习惯。

单个 Agent 可以将任务拆分给子 Agent，再汇总执行结果，工具内部的协作已经可用。问题出现在工具边界：不同 Agent 之间无法自动共享任务背景、阶段结论和执行进度，工作也就不能从一个 Agent 直接交由另一个 Agent 继续处理。

## 跨 Agent 协作的断点

目前，跨工具交接仍依赖 Markdown 文档。分析阶段需要整理任务背景、结论和待办，交给负责后续工作的 Agent；代码完成后，审查意见也要再传递给相应工具中的 Agent。

Markdown 便于沉淀上下文和回溯过程，但它不是消息机制：文档不会通知接收方有新任务，也无法确认对方是否收到或开始处理。因此，信息整理、任务转交和进度确认仍依赖人工。

与同事协作时，Agent 还运行在不同的开发环境中。各自的 Agent 可以独立完成工作，但缺少共同的沟通渠道，跨环境的信息传递和进度确认仍由协作者完成。

因此，当前需要解决的是 Agent 间的任务通信和进度同步，并使协作者能够查看任务状态。

![多个 Agent 分担开发环节，但目前仍由 Markdown 和人工完成交接]({{ '/assets/images/posts/01-agent分工与人工交接.png' | relative_url }})

## 社区中的协作方案

针对 Agent 互通，社区已有几类探索：定义通信规范、使用工具内部的子 Agent、在不同会话间中继消息，以及通过独立服务管理 Agent 通信。这些方案位于不同层次，解决的问题也不完全相同。

- **Agent 间通信协议。** [A2A（Agent2Agent）](https://github.com/a2aproject/A2A) 希望不同 Agent 系统遵循共同协议进行互通。它提供的是协议规范，现有开发工具还需要实现协议或提供适配。
- **Agent 自带的团队功能。** 一些编码工具可以在自己的产品内部创建子 Agent、分配任务。这种方式适合工具内部协作，但不能据此推断不同工具里的 Agent 已经互通。
- **终端或本地会话中继。** [WezTerm Chat MCP](https://github.com/yangzy7513/wezterm-chat-mcp) 借助 WezTerm 窗格在不同会话间传递消息；[Modula Relay](https://github.com/modulastack/modula-relay) 使用本地 Unix socket 连接 Agent。它们依赖特定终端或本机进程模型，是否适用于跨设备协作要分别核对网络与部署能力。
- **独立的 Agent 通信服务。** [cross-agent-teams-mcp](https://github.com/jtianling/cross-agent-teams-mcp) 等项目可作为调研案例。各项目的工具支持、部署方式和消息接收能力，需要分别依据项目说明与实际验证确认。

需要区分通信服务与接入方式。MCP（Model Context Protocol，模型上下文协议）用于连接 Agent 与外部工具或服务；消息路由、任务广播和记录保存则由具体服务实现，MCP 本身不提供这些协作能力。

![人工整理 Markdown 交接与协作服务传递 Agent 消息的对照]({{ '/assets/images/posts/02-人工交接与消息协作.png' | relative_url }})

## 当前方案的约束

当前流程要求不同工具、不同开发环境中的 Agent 可以互通，支持将分析结论发送给指定的编码 Agent、同步任务进度并保留协作记录。Codex、OpenCode 等工具需要继续沿用，避免为了协作迁移到同一套产品。

接入方案还需要尽量减少对 Agent 本身的改动，并降低逐个工具配置的工作量。服务地址、Agent 身份和必要权限仍需配置；安装向导、配置自动生成和合理默认值可以减少人工操作，但不能完全消除配置要求。

## 优先验证 MCP 接入

Codex、OpenCode 等工具已支持通过 MCP 连接外部服务。优先验证 MCP，可以复用宿主已有的接入能力，减少对 Agent 的改动，也避免为每种工具单独开发通信接口。具体支持范围和配置方式仍需按工具版本测试。

在这一方案中，Agent 通过 MCP 调用协作服务；Agent 身份管理、消息路由和协作记录由服务实现。这些能力属于协作服务，不由 MCP 提供。

消息送达后，接收方如何获知并处理，也需要单独验证。有些 Agent 需要主动查看收件箱，部分项目则为特定宿主实现了唤醒适配；仅接入 MCP 并不能保证接收方自动响应。下一步将先在本机验证社区已有项目的消息发送、接收、进度跟踪和唤醒能力，再根据结果判断现有方案与当前需求的差距。

![待验证方案：MCP 接入与协作服务的职责分工，消息唤醒仍取决于宿主能力]({{ '/assets/images/posts/03-MCP接入与消息流转.png' | relative_url }})
