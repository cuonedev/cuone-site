# 编辑规划

系列规划集中放在 `planning/series/`，按主题维护选题、顺序和状态。规划目录被 Jekyll 排除，不会生成 GitHub Pages 页面。

## 状态含义

- `计划中`：方向已提出，尚未进入正文写作。
- `写作中`：正文在 `_drafts/` 中持续编辑。
- `已发布`：定稿已进入 `_posts/` 并部署到网站。

发布流程：规划 → `_drafts/` 写作与本地预览 → 审阅 → `_posts/` 发布。普通 GitHub Actions 构建不得传入 `--drafts`。
