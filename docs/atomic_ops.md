---
layout: docs
title: Atomic Operations
prev_section: rql_layer
next_section: indexes
permalink: /atomic_ops/
---

TODO write the docs TODO

Examples

{% highlight ruby %}
user = User.first

user.queue_atomic do |r|
  user.num_friends += 1
  user.friends << 'Mike'
end

user.save
{% endhighlight %}
