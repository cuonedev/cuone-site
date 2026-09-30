# Cuone Site

丘亦（Cuone）的个人技术站点与博客，记录 AI 应用构建、研发效能、软件工程和量化研究相关实践。本网站使用 Jekyll 和 Chirpy，通过 GitHub Actions 发布到 GitHub Pages。

## 内容位置

- `_posts/`：已审核发布的文章。
- `_drafts/`：未发布的文章草稿；GitHub Pages 普通构建不会发布这里的内容。
- `planning/series/`：按主题管理系列规划和进度，不会生成网站页面。
- `planning/series/<series-id>/promotion/`：按系列归档短描述、信息流配图等对外发布素材，不进入 Pages 构建；配图源稿与发布图成对保留 SVG 和 PNG。
- `AGENTS.md`、`写作与配图规范.md`、`.agents/skills/`：本站写作和配图规则。
- `_tabs/`：Chirpy 侧栏页面，包括项目、博客、归档、分类、标签和关于。
- `projects/`：各项目介绍页。
- `blog/series/`：文章专题页。
- `assets/images/`：项目图与文章正文配图；系列对外发布素材单独存放在对应规划目录中。
- `CNAME`：GitHub Pages 自定义域名 `cuone.net`。

## 本地预览

安装 Ruby 和 Bundler 依赖后运行 `bundle exec jekyll serve`。本机需要预览草稿时运行 `bundle exec jekyll serve --drafts`；该参数不会用于 GitHub Actions 发布构建。推送到 `main` 后，GitHub Actions 会构建并发布站点。

## 系列写作与发布

系列选题和进度记在 `planning/series/`；正在写的文章放在 `_drafts/`；审核定稿后移入 `_posts/` 并确认配图位于 `assets/images/posts/`。规划目录和规则文件已从 Pages 构建中排除。
