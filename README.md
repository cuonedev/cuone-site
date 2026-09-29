# Cuone 官网

Cuone 的统一官网。首期介绍三个进行中的项目，并发布 AI 协作实践文章；后续可逐步增加产品文档、公司信息和联系页面。

## 项目

| 项目 | 仓库 | 官网页面 |
|---|---|---|
| AI Agent 协作 | `cuo-aiteams` | `/projects/cuo-aiteams/` |
| 轻量通用 Agent | `cuo-agent` | `/projects/cuo-agent/` |
| 量化研究 | `cuo-quant` | `/projects/cuo-quant/` |

项目源码保留在各自仓库。官网只维护面向访客的介绍、链接和已审核公开的文章。

## 目录

```text
cuone-site/
├── .github/workflows/pages.yml       # GitHub Pages 自动构建与发布
├── _data/
│   ├── navigation.yml                # 顶部导航
│   └── projects.yml                  # 项目卡片信息
├── _includes/                        # 导航、页脚和项目卡片
├── _layouts/                         # 首页、普通页、项目页和文章页
├── _posts/                           # 已审核发布的博客文章
├── assets/
│   ├── css/site.scss                 # 网站样式
│   └── images/{projects,posts}/      # 项目图与文章配图
├── blog/
│   ├── index.md                      # 博客列表
│   └── series/ai-agent-collaboration.md
├── projects/
│   ├── index.md                      # 项目总览
│   ├── cuo-aiteams.md               # cuo-aiteams
│   ├── cuo-agent.md                  # cuo-agent
│   └── cuo-quant.md                  # cuo-quant
├── about.md                          # 丘亦与 Cuone 介绍
├── index.md                          # 官网首页
├── _config.yml                       # Jekyll 配置
├── Gemfile                           # GitHub Pages/Jekyll 依赖
└── README.md
```

## 内容维护

- 首页先展示 Cuone 简介、三个项目和最新文章。
- 博客文章统一放在 `_posts/`，通过 front matter 添加分类、标签和专题信息；专题页维护系列文章的顺序与简介。
- AI 协作系列和配图从 `cuo-aiteams` 工作项目中挑选审核后复制。系列规划、写作规范和未发布草稿继续留在原项目。
- `cuo-agent`、`cuo-quant` 的介绍按项目实际进度填写；量化项目只公开确认可以发布的资料。
- 产品文档和公司介绍等栏目等内容成熟后再补，不先放空页面。

## 本地预览与发布

使用 Ruby 和 Bundler 安装 `Gemfile` 中的依赖后，可运行 `bundle exec jekyll serve` 本地预览。推送到 `main` 后，GitHub Actions 会构建并发布到 GitHub Pages。

创建 GitHub 仓库时使用 `cuonedev/cuone-site`，将本目录作为仓库根目录。配置 Pages 和自定义域名后，根域名用于官网，VPS 使用独立二级域名。
