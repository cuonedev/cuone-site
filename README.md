# Cuone Site

Cuone 官网与技术博客，使用 Jekyll 和 Chirpy，通过 GitHub Actions 发布到 GitHub Pages。

## 内容位置

- `_posts/`：已审核发布的文章。
- `_tabs/`：Chirpy 侧栏页面，包括项目、博客、归档、分类、标签和关于。
- `projects/`：各项目介绍页。
- `blog/series/`：文章专题页。
- `assets/images/`：项目图与文章配图。
- `CNAME`：GitHub Pages 自定义域名 `cuone.net`。

## 本地预览

安装 Ruby 和 Bundler 依赖后运行 `bundle exec jekyll serve`。推送到 `main` 后，GitHub Actions 会构建并发布站点。
