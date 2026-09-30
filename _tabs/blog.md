---
title: 博客
icon: fas fa-pen
order: 2
permalink: /blog/
---

记录我在软件开发、AI 应用与量化研究中的项目实践和技术思考。

## 最新文章

{% for post in site.posts %}
- [{{ post.title }}]({{ post.url | relative_url }})（{{ post.date | date: "%Y-%m-%d" }}）
{% endfor %}

## 专题

- [AI 协作实践]({{ '/blog/series/ai-agent-collaboration/' | relative_url }})
