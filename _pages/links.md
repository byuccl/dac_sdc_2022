---
layout: page
toc: false
title: Links
sidebar: true
icon: fas fa-box-open
---

## Sidebar Links

{% for page in site.pages %}
    {% if page.sidebar %}
* [{{ page.title }}]({% link {{ page.path }} %})
    {% endif %}
{% endfor %}

## Other Links


{% for page in site.pages %}
    {% unless page.sidebar %}
* [{{ page.title }}]({% link {{ page.path }} %})
    {% endunless %}
{% endfor %}

