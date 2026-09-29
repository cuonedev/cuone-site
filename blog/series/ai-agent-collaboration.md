---
title: AI 协作实践
permalink: /blog/series/ai-agent-collaboration/
---

记录多种 AI Agent 在开发流程中的协作问题、社区方案调研与验证过程。文章以个人实践为叙述视角，并区分公开资料、实际验证和待验证判断。

{% assign series_posts = site.posts | where: "series", page.title %}
{% if series_posts.size > 0 %}
<ul class="post-list">
{% for post in series_posts %}
  <li>
    <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y.%m.%d" }}</time>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
{% else %}
当前暂无公开文章。
{% endif %}
