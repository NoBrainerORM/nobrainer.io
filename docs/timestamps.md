---
layout: docs
title: Timestamps
prev_section: types
next_section: serialization
permalink: /timestamps/
---

## Enabling Timestamps

Include the `Timestamps` in your model to enable the timestamping mechanism as follow:

{% highlight ruby %}
class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
end
{% endhighlight %}

When including the `Timestamps` module, the following behavior is inserted in
the model:

{% highlight ruby %}
field :created_at, :type => Time
field :updated_at, :type => Time

before_create { self.created_at = Time.now }
before_save   { self.updated_at = Time.now }
{% endhighlight %}

Timestamps are not exactly implemented as described because database updates
are skipped when no attributes changed during a `save`.
The above behavior would have the effect of always changing the attributes
since callbacks are always triggered even when no attributes changed.
This means that the `updated_at` timestamp is only set when a database
update query is performed.
