---
layout: page
title: Blog
position: 1

jumbo-title: Blog Archive
jumbo-subtitle: Random Musings of a Software Engineer
---
{% for category in site.categories %}
# {{ category[0] | capitalize }}
  {% for post in category[1] %}[{{ post.title }}]({{ post.url }}) - Posted on {{ post.date | date: "%B %-d, %Y" }}<br/>{% endfor %}
{% endfor %}