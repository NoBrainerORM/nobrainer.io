---
layout: docs
title: Timestamps
prev_section: fields
next_section: serialization
permalink: /timestamps/
---

## Timestamps are enabled by default

NoBrainer timestamps all your documents by default.
Timestamps are performed by inserting the following in your model:

{% highlight ruby %}
field :created_at
field :updated_at

before_create { self.created_at = Time.now }
before_save   { self.updated_at = Time.now }
{% endhighlight %}

To prevent timestamps for a specific model, call `disable_timestamps` in your model.  For example:

{% highlight ruby %}
class User
  include NoBrainer::Document
  disable_timestamps
end
{% endhighlight %}

There is no `touch()` method implemented. Please make a request on Github
if you want it.
