---
layout: docs
title: Store accessor
permalink: /docs/store_accessor/
---

## What is store_accessor

Store gives you a way for storing hashes in a single field with accessors
to the Hash keys.

It is a portage of the ActiveRecord::Store which make gems using it compatible
with NoBrainer.

Please refer to the [ActiveRecord::Store documentation](https://api.rubyonrails.org/classes/ActiveRecord/Store.html)
but here is a basic way of using it:

{% highlight ruby %}
class User
  include NoBrainer::Document

  field :username
  store_accessor :settings, %i[theme]
end

u = User..new(params: {theme: 'dark', locale: 'en'}, username: 'anna')
u.theme # => 'dark'
u.params # => {"theme"=>"dark", "locale"=>"en"}
{% endhighlight %}
